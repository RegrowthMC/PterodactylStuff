#!/bin/bash
cd /home/container

# Output Current Java Version
java -version

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Check auto update is on
if [ "${AUTO_UPDATE}" == "1" ]; then
	echo "Checking for updates..."

        LATEST_TAG=`curl -L "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${GITHUB_REPO}/releases/latest | jq -r .tag_name`
	CURRENT_TAG=`cat .currenttag 2>/dev/null`

	if [ "$LATEST_TAG" != "$CURRENT_TAG" ]; then
		echo "Update available!"
		echo "Updating from '$CURRENT_TAG' -> '$LATEST_TAG'"
                curl -L -s -0 ${SERVER_JARFILE} https://github.com/${GITHUB_REPO}/releases/latest/download/${GITHUB_ASSET}

		echo "$LATEST_TAG" > ".currenttag"
		echo "Updated!"
	else
		echo "No update available"
	fi
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
