pidfile=/path/to/pidfile
if [ -f "$pidfile" ] && kill -0 `cat $pidfile` 2>/dev/null; then
    echo AutoPull already exists
    exit 1
fi
echo $$ > $pidfile

echo AutoPull started

while :; do
  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "$UPSTREAM")
  BASE=$(git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
  elif [ $LOCAL = $BASE ]; then
    echo "Need to pull"
  elif [ $REMOTE = $BASE ]; then
    echo "Need to push"
  else
    echo "Diverged"
  fi

  sleep 5
done
