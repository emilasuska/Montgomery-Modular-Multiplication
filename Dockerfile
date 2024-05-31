# Build the `mmm` docker image once:
#   docker build --tag mmm .
#
# Run within a docker container:
#   docker run --rm --init -it --mount=type=bind,source=.,target=/mmm --platform linux/arm/v5 mmm

FROM arm32v5/debian

RUN --mount=type=bind,source=.,target=/mmm \
	cd /mmm && \
	apt update && \
	apt install -y wget build-essential

WORKDIR /mmm
