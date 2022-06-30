version=""
yearweek=""
year=`date +%y`
weeknumber=`date +%V`

echo "fetching latest tags from remote...";

# FETCH=`git fetch --all 2> /dev/null`;
# LATEST_TAG=`git tag | sort -g | tail -1`;

# if [ -z $LATEST_TAG]; then
#   echo "there is no tag";;
# else
#   echo $LATEST_TAG;
# fi

if [ -z $LATEST_TAG ]; then
    echo $year
    echo $weeknumber
    VER=`date +'0.%y%V'`;
    echo "release version not supplied, defaulting to $VER";
else
    echo "release version supplied - $LATEST_TAG";
fi
