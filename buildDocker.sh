#!/bin/bash

programeName="build idempiere docker"
export project=pawn
export tag=refs/heads/pawn1908149524
export coreVer=

usage()
{
  echo "Usage: $programeName [ -p | --proj | --project idempiere project example pawn ]
  						[ -t | --tab | release tag on github when build binary ]
	"
  exit 2
}

### getopt: https://www.shellscript.sh/tips/getopt/
PARSED_ARGUMENTS=$(getopt -a -n "$programeName" -o p:t:v: --long project:,proj:,tag:,ver: -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

echo "arguments is $PARSED_ARGUMENTS"
eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -p | --project | --proj)   project="$2"      ; shift 2 ;;
	  -t | --tag)   tag="$2"      ; shift 2 ;;
    -v | --ver)   coreVer="$2"      ; shift 2 ;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *) echo "Unexpected option: $1 - this should not happen."
       usage ;;
  esac
done

set -e

export binaryFile=idempiereServer.${project}.gtk.linux.x86_64.tar.gz
export repo=vn.hieplq.build
export gitBinaryAccount=hieplq

ver=$( basename $tag )
binaryFileVer=${ver}_${binaryFile}


if [ -f $binaryFileVer ]; then
	echo reuse binary file $binaryFileVer
else
	ASSET_ID=$(curl -s -H "Authorization: token $AUTH_TOKEN" \
       -H "Accept: application/vnd.github.v3.raw" \
       https://api.github.com/repos/$gitBinaryAccount/$repo/releases/tags/$tag \
       | jq --arg name "$binaryFile" '.assets[] | select(.name == $name).id')

	wget --auth-no-challenge --header='Accept:application/octet-stream' https://$AUTH_TOKEN:@api.github.com/repos/$gitBinaryAccount/$repo/releases/assets/$ASSET_ID -O $binaryFile

	mv $binaryFile "$binaryFileVer"
fi

docker -D build -t motive/idempiere$coreVer-$ver --build-arg BINARY_FILE=$binaryFileVer .