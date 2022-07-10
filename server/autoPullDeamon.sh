git fetch
if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
    echo "NEED UPDATE PLEASE"

fi;
