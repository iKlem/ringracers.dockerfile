Unofficial "Dr. Robotnik's Ring Racers" Dockerfile
---

> **Note**: This repository doesn't contains any final image, you can follow the guide below.

### Build image

> **Note**: The built image will use the "master" branch of RR on the [KartKrew repository](https://git.do.srb2.org/KartKrew/RingRacers)

Clone this repository and move into it, then run this command with the arguments you need :
```sh
docker build \
	--build-arg="RR_TAG=v2.2" \
	--build-arg="RR_PORT=5029" \
	--build-arg="ADVERTISE=Yes" \
	-t=ringracers-server .
```

All availables build arguments, :

|  Key      |  Values                                                  |  Default |
|-----------|----------------------------------------------------------|----------|
| RR_TAG    | Version of the game to run to, format : "vX.Y"           | "v2.2"   |
| RR_PORT   | Port you want to use                                     | "5029"   |
| ADVERTISE | If you want to advertise the server on "ms.kartkrew.org" | "Yes"    |

> **Note**: Only the RR_TAG is useful for building the image, it is not for running the container

### Run container
Run this command after building the image :
```sh
docker run -i -t -d \
	--name=ringracers.server \
	-v "/path/to/some/folder/on/host:/home/ringracers/.ringracers/" \
	-e RR_PORT=5029 \
	-e ADVERTISE=Yes \
	-p 5029:5029/udp \
	--health-cmd='./entrypoint.sh monitor' \
	--health-interval=30s \
	--health-start-period=5s \
	ringracers-server
```

You can change the healthcheck values if you want to restart the server if it has crashed.  
You'll need to match the `RR_PORT` (you can set it during build or during running) to the port in the `-p 5029:5029/udp` argument, the one to the right in the argument.  

### Access game console
You can acces the game console with this command : `docker exec -i -t ringracers.server tmux attach`  
To detach from the console without closing the server, press `Ctrl+B` then `D` (see tmux manual on this).

### Credits
[KartKrew](https://www.kartkrew.org) for their amazing work on the game.  
[AceyT](https://github.com/AceyT) for some of his help during the stream when we had to make this Dockerfile (checkout his version for [ARMv8](https://github.com/AceyT/ringracers-dockerfile))  
