#!/bin/bash
export DISPLAY=:99
export XDG_RUNTIME_DIR=/tmp/xdg
export XAUTHORITY=${DATA_DIR}/.Xauthority

CUR_V="$(ls ${DATA_DIR}/uNmINeD-* 2>/dev/null | cut -d '-' -f2 | sed 's/\.tar\.gz//g' | sort -V | tail -1)"
LAT_V="$(wget -qO- https://unmined.net/downloads/ | grep "Download" | grep "zip" | awk '{print $2}' | sort -V | tail -1)"

if [ -z "$LAT_V" ]; then
  if [ ! -z "$CUR_V" ]; then
    echo "---Can't get latest version of uNmINeD-GUI falling back to v$CUR_V---"
    LAT_V="$CUR_V"
  else
    echo "---Something went wrong, can't get latest version of uNmINeD-GUI, putting container into sleep mode---"
    sleep infinity
  fi
fi

echo "---Version Check---"
if [ -z "$CUR_V" ]; then
	echo "---uNmINeD-GUI not found! Please wait, installing...---"
	cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/uNmINeD-${LAT_V}.tar.gz "https://unmined.net/download/unmined-gui-linux-x64-sc/" ; then
		echo "---Sucessfully downloaded uNmINeD-GUI---"
	else
		echo "---Something went wrong, can't download uNmINeD-GUI, putting container in sleep mode---"
		rm -rf ${DATA_DIR}/uNmINeD-${LAT_V}.tar.gz
		sleep infinity
	fi
	tar -C ${DATA_DIR} --overwrite --strip-components=1 -xf ${DATA_DIR}/uNmINeD-${LAT_V}.tar.gz
elif [ "$CUR_V" != "$LAT_V" ]; then
	UPDATED_UNMINED_CLI="true"
	echo "---Version missmatch, installed v$CUR_V, downloading and installing latest v$LAT_V...---"
	rm -rf ${DATA_DIR}/uNmINeD-${CUR_V}.tar.gz
	cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/uNmINeD-${LAT_V}.tar.gz "https://unmined.net/download/unmined-gui-linux-x64-sc/" ; then
		echo "---Sucessfully downloaded uNmINeD-GUI---"
	else
		echo "---Something went wrong, can't download uNmINeD-GUI, putting container in sleep mode---"
		rm -rf ${DATA_DIR}/uNmINeD-${LAT_V}.tar.gz
		sleep infinity
	fi
	tar -C ${DATA_DIR} --overwrite --strip-components=1 -xf ${DATA_DIR}/uNmINeD-${LAT_V}.tar.gz
elif [ "$CUR_V" == "$LAT_V" ]; then
	echo "---uNmINeD-GUI v$CUR_V up-to-date---"
fi

if [ ! -f ${DATA_DIR}/unmined-cli ]; then
	echo "uNmINeD-CLI not found! Please wait, installing..."
	cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/uNmINeD-CLI.tar.gz "https://unmined.net/download/unmined-cli-linux-x64-sc/" ; then
		echo "---Sucessfully downloaded uNmINeD-CLI---"
	else
		echo "---Something went wrong, can't download uNmINeD-CLI, continuing---"
		rm -rf ${DATA_DIR}/uNmINeD-CLI.tar.gz
	fi
	tar -C ${DATA_DIR} --overwrite --strip-components=1 -xf ${DATA_DIR}/uNmINeD-CLI.tar.gz --wildcards unmined-cli*/unmined-cli unmined-cli*/README.md
	rm -f ${DATA_DIR}/uNmINeD-CLI.tar.gz
elif [ "$UPDATED_UNMINED_CLI" == "true" ]; then
	echo "---Updating uNmINeD-CLI, please wait...---"
	cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/uNmINeD-CLI.tar.gz "https://unmined.net/download/unmined-cli-linux-x64-sc/" ; then
		echo "---Sucessfully downloaded uNmINeD-CLI---"
	else
		echo "---Something went wrong, can't download uNmINeD-CLI, continuing---"
	fi
	tar -C ${DATA_DIR} --overwrite --strip-components=1 -xf ${DATA_DIR}/uNmINeD-CLI.tar.gz --wildcards unmined-cli*/unmined-cli unmined-cli*/README.md
	rm -f ${DATA_DIR}/uNmINeD-CLI.tar.gz
fi


echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
cd ${DATA_DIR}
chmod -R ${DATA_PERM} $(ls -I worlds ${DATA_DIR}/) 2>/dev/null
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	if [ "${RUNASROOT}" == "true" ]; then
		chmod 600 /root/.vnc/passwd
	else
		chmod 600 ${DATA_DIR}/.vnc/passwd
	fi
fi
screen -wipe 2&>/dev/null

echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W} ]; then
	CUSTOM_RES_W=1280
fi
if [ -z "${CUSTOM_RES_H} ]; then
	CUSTOM_RES_H=850
fi

if [ "${CUSTOM_RES_W}" -le 1279 ]; then
	echo "---Width to low must be a minimum of 1280 pixels, correcting to 1280...---"
    CUSTOM_RES_W=1280
fi
if [ "${CUSTOM_RES_H}" -le 849 ]; then
	echo "---Height to low must be a minimum of 850 pixels, correcting to 850...---"
    CUSTOM_RES_H=850
fi

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting uNmINeD-GUI---"
cd ${DATA_DIR}
${DATA_DIR}/unmined 2>/dev/null