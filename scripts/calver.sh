version=""
yearweek=""
year=`date +%Y`
weeknumber=`date +%V` # ISO Standard week number

# sanitize inputs
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)  

    case "$KEY" in
            --head)              
              head=${VALUE} ;;

            --override_version)     
              override_version=${VALUE} ;;

            *)
              echo "ERROR: unknown parameter \"$KEY\""
              exit 1 ;;
    esac
done

echo "fetching latest tags from remote...";
FETCH=`git fetch --all 2> /dev/null`

tags='git tag | sort -g'
printf $tags;

# this prevents from having 1801 at the last week of the year 2019. It should be 1901.
if [[ ${weeknumber} -eq 1 ]] && [[ `date -u -d ${forced_date} +%-d` -gt 20 ]]; then
  year=$(expr ${year} + 1)
fi

# this prevents from having 1053 at the last week of the year 2010. It should be 0953.
if [[ ${weeknumber} -ge 52 ]] && [[ `date -u -d ${forced_date} +%-d` -le 7 ]]; then
    year=$(expr ${year} - 1)
fi

yearweek="${year:2:2}${weeknumber}"

if [ -z ${override_version} ]; then
    lastest=`git tag | sort -g | tail -1`
    latestHead=`echo $lastest | cut -d. -f1`
    latestYearweek=`echo $lastest | cut -d. -f2`
    latestBuild=`echo $lastest | cut -d. -f3`

    printf "$latestHead\n"
    printf "$latestYearweek\n"
    printf "$latestBuild\n"

    printf "latest $latestHead.$latestYearweek.$latestBuild\n"

    if [ -z ${lastest} ]; then
        head="0"
        build="0"
        echo "- Warning: There is no tag. set to default.";
    else
        if [ -z ${head} ]; then
            if [ -z ${latestHead} ]; then
              head="0"
              echo "- Warning: no head value. set to 0 by default.";
            else
              head=$latestHead
            fi
        fi

        if [ -z ${latestBuild} ]; then
            build="0"
            echo "- Warning: no build value. set to 0 by default."
        else
            build=$(($latestBuild + 1))
        fi

        if [ "$yearweek" != "$latestYearweek" ]; then
            build="0"      
            echo "- Warning: yearweek is changed"
        fi
    fi

    version="$head.$yearweek.$build"
else
    echo "- Warning: head, build, suffix values will be ignored"
    version=${override_version}
fi

printf "version: $version\n"

# git tag "staging-$version"
# git push origin --tags
