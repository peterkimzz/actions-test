BRANCH="main"
DRY_RUN=false
PATCH_RUN=false
INC=0;
PATCH=0;
usage() {
  echo -e "\nUsage: $0 --branch \"main\" --version=\"20.09\" --dry-run" \
          "\n" \
          "\n\t--branch - source of the branch where the tag comes from, defaults to main" \
          "\n\t--version - version to release, defaults to current yy.mm" \
          "\n\t--patch - adds a patch incrementer after dd, i.e yy.mm.dd-p" \
          "\n\t--dry-run - check tag without push" \
          "\n\t--help - prints usages"  >&2
  exit 1
}

while [ "$1" != "" ]; do
    echo "no input"
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        --version)
            VER=$VALUE
            ;;
        --branch)
            BRANCH=$VALUE
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --patch)
            PATCH_RUN=true
            ;;
        --help)
            usage
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            exit 1
            ;;
    esac
    shift
done

echo "fetching latest tags from remote...";
FETCH=`git fetch --all 2> /dev/null`

if [ -z $VER ]; then
    VER=`date +'%y.%m'`;
    echo "release version not supplied, defaulting to $VER";
else
    echo "release version supplied - $VER";
fi

CURR_TAG=`git tag -l --sort=-version:refname "$VER*" | head -n 1 2>/dev/null`;
if [ -z $CURR_TAG ]; then
    echo "No prior tags found, using default incrementer";
else
    echo "prior tags ($CURR_TAG) found, checking incrementer";
    IFS='.-' read -r -a array <<< "$CURR_TAG"
    VER="${array[0]}.${array[1]}"
    INC=${array[2]}
    PATCH=${array[3]:-0}
    if [ $PATCH_RUN == false ]; then
        INC=$(($INC + 1))
    fi
    echo "setting incrementer to $INC";
    echo "setting patch to $PATCH";
fi

NEW_TAG="$VER.$INC"
if [ $PATCH_RUN == true ]; then
    echo "patch run is true identified"
    PATCH=$(($PATCH + 1))
    NEW_TAG="$NEW_TAG-$PATCH"
fi
if [ $DRY_RUN = true ]; then
    echo "dry run enabled, new tag is ($NEW_TAG)"
else
    echo "creating new tag ($NEW_TAG) from ($BRANCH)"
    git push origin refs/remotes/origin/$BRANCH:refs/tags/$NEW_TAG
fi
