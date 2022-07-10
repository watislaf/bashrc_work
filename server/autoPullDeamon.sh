if [ -f "$BASH__WORK__DEAMON__PIDFILE" ] && kill -0 $(cat $BASH__WORK__DEAMON__PIDFILE) 2>/dev/null; then
  echo AutoPull already exists
  exit 1
fi
echo $$ >$BASH__WORK__DEAMON__PIDFILE

echo AutoPull started

while :; do
  echo work
  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  BASE=$(git merge-base @ "$UPSTREAM")

  if [ LOCAL = BASE ]; then
    echo "Need to pull"
    ubr
  fi
  sleep 5
done
