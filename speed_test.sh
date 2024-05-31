#!/bin/bash

set -e

HERE="$(cd "$(dirname "$0")"; pwd)"

cpu="$(lscpu 2>/dev/null | grep '\bArchitecture:' | grep -o '[^: ]*$' || true)"
if [[ "${cpu:0:4}" = "armv" ]]; then
	# Running on an ARM machine.
	echo "Running on ARM ($cpu)."
elif [[ ! -f /.dockerenv ]]; then
	# Run this script within an ARM docker container.
	echo "Entering Docker container..."
	docker run --rm --init -it \
		--mount=type=bind,source="$HERE",target=/mmm \
		--platform linux/arm/v5 mmm "$0" "$@"
	exit 0
fi

# Read command line arguments.
build=
while [ $# != 0 ]; do
	case "$1" in
		--build )
			# Build before running speed test.
			build=true
			shift
			;;
		* )
			break
			;;
	esac
done

OPENSSL_VERSION="3.1.1"
OPENSSL_DIR="$HERE"/openssl
OPENSSL_EXE="$OPENSSL_DIR"/apps/openssl

# Check if we need to build OpenSSL first.
if [[ "$build" != "" ]] || [[ ! -x "$OPENSSL_EXE" ]]; then
	# Download and extract OpenSSL if we don't have it yet.
	if [[ ! -d "$OPENSSL_DIR" ]]; then
		if [[ ! -f openssl-"$OPENSSL_VERSION".tar.gz ]]; then
			echo
			echo "Downloading OpenSSL $OPENSSL_VERSION ..."
			wget https://www.openssl.org/source/openssl-"$OPENSSL_VERSION".tar.gz
		fi
		echo
		echo "Extracting OpenSSL $OPENSSL_VERSION ..."
		rm -rf "$OPENSSL_DIR"
		tar -xf openssl-"$OPENSSL_VERSION".tar.gz
		mv openssl-"$OPENSSL_VERSION" "$OPENSSL_DIR"
	fi

	# Patch OpenSSL with our ARM Assembly Montgomery Modular Multiplication implementation.
	cp -pf mmm_arm_assembly/* "$OPENSSL_DIR"/crypto/bn/
	if ! grep -m 1 '\barmv4-mmm[.]S\b' "$OPENSSL_DIR"/crypto/bn/build.info >/dev/null; then
		sed --in-place= 's/^\(\s*[$]BNASM_armv4=.*\)/\1 armv4-mmm.S/' "$OPENSSL_DIR"/crypto/bn/build.info
	fi

	echo
	echo "Building OpenSSL..."
	pushd "$OPENSSL_DIR" >/dev/null
	if [[ ! -f Makefile ]]; then
		./config --prefix="$OPENSSL_DIR" --openssldir="$OPENSSL_DIR" -march=armv4
	fi
	make build_libs apps/openssl
	popd >/dev/null
fi

# Use the OpenSSL we have built and not any system library.
export LD_LIBRARY_PATH="$OPENSSL_DIR"

function openssl() {
	"$OPENSSL_EXE" "$@"
}

echo -n "Using "
openssl version

echo
echo "Running RSA Speed Test with this new ARM Assembly MMM implementation..."
export MMM_MODE=0
openssl speed rsa

echo
echo "Running RSA Speed Test with default OpenSSL Assembly MMM implementation..."
export MMM_MODE=1
openssl speed rsa

echo
echo "Running RSA Speed Test with default OpenSSL C MMM implementation..."
export MMM_MODE=2
openssl speed rsa
