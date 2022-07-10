if [ -f "$BASH__WORK__DEAMON__PIDFILE" ] && kill -0 $(cat $BASH__WORK__DEAMON__PIDFILE) 2>/dev/null; then
  echo AutoPull already exists
  exit 1
fi
echo $$ >$BASH__WORK__DEAMON__PIDFILE

echo AutoPull started

while :; do
  git fetch
  if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
    echo "Need to pull"
    ubr
  fi
  if [ ! -f "$BASH__WORK__DEAMON__PIDFILE" ]; then
    echo dead
    return 0
  fi
  sleep 5
done
