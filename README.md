# uNmINeD-GUI in Docker optimized for Unraid
uNmINeD is an easy to use and fast Minecraft world viewer and mapper tool. It can read Minecraft Java and Bedrock Edition world files and renders a browseable 2D overview map that you can export.

**ATTENTION:** Please always mount your world files as read only and it is strongly recommended to mount your worlds to the path /unmined/worlds/... in the container.

If you want to support the developer from uNmINeD then please consider Donating: [Click](https://www.patreon.com/bePatron?u=543858&redirect_uri=https%3A%2F%2Fgithub.com%2Fich777%2Fdocker-unmined)

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Main data path for the container | /unmined |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value | 000 |
| DATA_PERM | Data permissions for /unmined folder | 770 |

## Run example
```
docker run --name uNmINeD-GUI -d \
	-p 8080:8080 \
	--env 'CUSTOM_RES_W=1280' \
	--env 'CUSTOM_RES_H=850' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=000' \
	--env 'DATA_PERM=770' \
	--volume /path/to/unmined:/unmined \
	--volume /path/to/minecraft/worlds:/unmined/worlds:ro \
	ich777/unmined
```
### Webgui address: http://[SERVERIP]:[PORT]/vnc.html?autoconnect=true

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/