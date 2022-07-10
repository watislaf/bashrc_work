pidfile=${BASH__REMOTE_UPDATER_DIRNAME}/server/deamonPidFile.txt
if [ -f "$pidfile" ] && kill -0 $(cat $pidfile) 2>/dev/null; then
  echo AutoPull already exists
  exit 1
fi
echo $$ >$pidfile

echo AutoPull started

while :; do
  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  BASE=$(git merge-base @ "$UPSTREAM")

  if [ LOCAL = BASE ]; then
    echo "Need to pull"
    ubr
  fi
  sleep 5
done
