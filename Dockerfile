FROM debian:bookworm AS builder

ARG RR_TAG="v2.2"

RUN apt-get update -y \
	&& apt-get upgrade -y \
	&& apt-get install -y \
	build-essential \
	git \
	cmake \
	libcurl4-openssl-dev \
	libgme-dev \
	libogg-dev \
	libopenmpt-dev \
	libpng-dev \
	libsdl2-dev \
	libsdl2-mixer-dev \
	libvorbis-dev \
	libvpx-dev \
	libyuv-dev \
	nasm \
	ninja-build \
	p7zip-full \
	pkg-config \
	zlib1g-dev \
	&& apt-get clean

RUN adduser --disabled-password -gecos "" ringracers
USER ringracers

RUN git clone https://git.do.srb2.org/KartKrew/RingRacers /home/ringracers/rr_git
WORKDIR /home/ringracers/rr_git
RUN git checkout ${RR_TAG}
RUN cmake --preset ninja-release
RUN cmake --build --preset ninja-release

# --------------
FROM debian:bookworm AS assets

ARG RR_TAG="v2.2"
ARG ASSETS_URL="https://github.com/KartKrewDev/RingRacers/releases/download/${RR_TAG}/Dr.Robotnik.s-Ring-Racers-${RR_TAG}-Assets.zip"

RUN apt-get update -y \
	&& apt-get upgrade -y \
	&& apt-get install -y wget unzip \
	&& apt-get clean

RUN mkdir /RingRacers
WORKDIR /RingRacers
RUN wget ${ASSETS_URL}
RUN unzip "Dr.Robotnik.s-Ring-Racers-${RR_TAG}-Assets.zip"

# --------------

FROM debian:bookworm AS main

ARG RR_PORT="5029"
ARG RR_TAG="v2.2"
ARG ADVERTISE="Yes"

ENV RR_PORT=${RR_PORT}
ENV ADVERTISE=${ADVERTISE}

RUN apt-get update \
	&& apt-get install -y \
	libcurl4 \
	libgme0 \
	libogg0 \
	libpng16-16 \
	libsdl2-2.0-0 \
	libsdl2-mixer-2.0-0 \
	libvorbis0a \
	libvpx7 \
	libyuv0 \
	procps \
	tmux \
	&& apt-get clean

RUN adduser --disabled-password -gecos "" ringracers
USER ringracers

WORKDIR /home/ringracers/
COPY --chown=ringracers --from=assets  /RingRacers/data/* data/
COPY --chown=ringracers --from=assets  /RingRacers/models/* models/
COPY --chown=ringracers --from=assets  /RingRacers/bios.pk3 bios.pk3
COPY --chown=ringracers --from=assets  /RingRacers/models.dat models.dat
COPY --chown=ringracers --from=builder /home/ringracers/rr_git/build/ninja-release/bin/ringracers_${RR_TAG} ringracers

EXPOSE ${RR_PORT}/udp

COPY --chown=ringracers entrypoint.sh ./
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ./entrypoint.sh
