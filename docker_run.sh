#!/bin/bash

set -e

HERE="$(cd "$(dirname "$0")"; pwd)"

docker run --rm --init -it \
	--mount=type=bind,source="$HERE",target=/mmm \
	--platform linux/arm/v5 mmm "$@"
