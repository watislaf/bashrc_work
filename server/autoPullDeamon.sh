pidfile=${BASH__REMOTE_UPDATER_DIRNAME}/server/deamonPidFile.txt
if [ -f "$pidfile" ] && kill -0 $(cat $pidfile) 2>/dev/null; then
  echo AutoPull already exists
  exit 1
fi
echo $$ >$pidfile

echo AutoPull started

while :; do
  UPSTREAM___=${1:-'@{u}'}
  LOCAL___=$(git rev-parse @)
  BASE___=$(git merge-BASE @ "$UPSTREAM___")

  if [ $LOCAL___ = $BASE___ ]; then
    echo "Need to pull"
    ubr
  fi
  sleep 5
done
