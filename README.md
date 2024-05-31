# Montgomery Modular Multiplication algorithm implemented in ARM Assembly

![animation](mmm.gif)

OpenSSL is used as the base source code to insert this optimized ARM Assembly implementation of the Montgomery Modular Multiplication algorithm.

The OpenSSL RSA cryptographic algorithm (which uses the MMM algorithm) is used to the the performance of this MMM implementation and to compare it against the ARM Assembly and C code implementations that are included with OpenSSL.

## Building and Running

There is one script that builds and runs a speed test of RSA cryotographic operations.
```
./speed_test.sh
```

This script can be run in one of two kinds of environemnts:
* An Unix machine that OpenSSL supports with a real ARMv4 or later processor.
* Any kind of machine with a bash shell and Docker virtualization software. Docker will emulate the ARM processor.

The `speed_test.sh` script will on its first run do the following:
* Download OpenSSL 3.1.1 source code (the latest version at the time) .
* Patch the source code to include this MMM ARM Assembly implementation.
* Configure and build the OpenSSL libraries and the command line tools.

Then, and on all subsequent runs it will run the OpenSSL build-in RSA speed tests once for each of the followin MMM algorithm implementations:
* This MMM ARM Assembly code.
* Open SSL OpenSSL's default ARM Assembly code.
* OpenSSL's default C code.

The Docker emulation environment is included for convenience so that a real ARM machine is not required. However, the performance results in the Docker emulated environment may not be representative of that of a real ARM processor.

Here is a sample run on a Raspberry Pi Zero W with a 1GHz, single-core ARM CPU.
```
$ ./speed_test.sh
Running on ARM (armv6l).

Using OpenSSL 3.1.1 30 May 2023 (Library: OpenSSL 3.1.1 30 May 2023)

Running RSA Speed Test with this new ARM Assembly MMM implementation...
Doing 512 bits private rsa's for 10s: 7508 512 bits private RSA's in 9.59s
Doing 512 bits public rsa's for 10s: 84692 512 bits public RSA's in 9.60s
Doing 1024 bits private rsa's for 10s: 1297 1024 bits private RSA's in 9.67s
Doing 1024 bits public rsa's for 10s: 25822 1024 bits public RSA's in 9.66s
Doing 2048 bits private rsa's for 10s: 187 2048 bits private RSA's in 9.47s
Doing 2048 bits public rsa's for 10s: 6838 2048 bits public RSA's in 9.46s
Doing 3072 bits private rsa's for 10s: 62 3072 bits private RSA's in 9.77s
Doing 3072 bits public rsa's for 10s: 3141 3072 bits public RSA's in 9.60s
Doing 4096 bits private rsa's for 10s: 27 4096 bits private RSA's in 9.74s
Doing 4096 bits public rsa's for 10s: 1789 4096 bits public RSA's in 9.62s
Doing 7680 bits private rsa's for 10s: 5 7680 bits private RSA's in 11.28s
Doing 7680 bits public rsa's for 10s: 513 7680 bits public RSA's in 9.57s
Doing 15360 bits private rsa's for 10s: 1 15360 bits private RSA's in 17.43s
Doing 15360 bits public rsa's for 10s: 131 15360 bits public RSA's in 9.72s
version: 3.1.1
built on: Tue Aug  1 21:20:39 2023 UTC
options: bn(64,32)
compiler: gcc -fPIC -pthread -Wa,--noexecstack -Wall -O3 -march=armv4 -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_BUILDING_OPENSSL -DNDEBUG
CPUINFO: OPENSSL_armcap=0x0
                  sign    verify    sign/s verify/s
rsa  512 bits 0.001277s 0.000113s    782.9   8822.1
rsa 1024 bits 0.007456s 0.000374s    134.1   2673.1
rsa 2048 bits 0.050642s 0.001383s     19.7    722.8
rsa 3072 bits 0.157581s 0.003056s      6.3    327.2
rsa 4096 bits 0.360741s 0.005377s      2.8    186.0
rsa 7680 bits 2.256000s 0.018655s      0.4     53.6

Running RSA Speed Test with default OpenSSL Assembly MMM implementation...
Doing 512 bits private rsa's for 10s: 6925 512 bits private RSA's in 9.62s
Doing 512 bits public rsa's for 10s: 78708 512 bits public RSA's in 9.64s
Doing 1024 bits private rsa's for 10s: 1203 1024 bits private RSA's in 9.65s
Doing 1024 bits public rsa's for 10s: 24117 1024 bits public RSA's in 9.62s
Doing 2048 bits private rsa's for 10s: 179 2048 bits private RSA's in 9.69s
Doing 2048 bits public rsa's for 10s: 6546 2048 bits public RSA's in 9.65s
Doing 3072 bits private rsa's for 10s: 57 3072 bits private RSA's in 9.57s
Doing 3072 bits public rsa's for 10s: 2978 3072 bits public RSA's in 9.66s
Doing 4096 bits private rsa's for 10s: 26 4096 bits private RSA's in 9.99s
Doing 4096 bits public rsa's for 10s: 1692 4096 bits public RSA's in 9.67s
Doing 7680 bits private rsa's for 10s: 5 7680 bits private RSA's in 11.98s
Doing 7680 bits public rsa's for 10s: 487 7680 bits public RSA's in 9.64s
Doing 15360 bits private rsa's for 10s: 1 15360 bits private RSA's in 18.56s
Doing 15360 bits public rsa's for 10s: 123 15360 bits public RSA's in 9.67s
version: 3.1.1
built on: Tue Aug  1 21:20:39 2023 UTC
options: bn(64,32)
compiler: gcc -fPIC -pthread -Wa,--noexecstack -Wall -O3 -march=armv4 -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_BUILDING_OPENSSL -DNDEBUG
CPUINFO: OPENSSL_armcap=0x0
                  sign    verify    sign/s verify/s
rsa  512 bits 0.001389s 0.000122s    719.9   8164.7
rsa 1024 bits 0.008022s 0.000399s    124.7   2507.0
rsa 2048 bits 0.054134s 0.001474s     18.5    678.3
rsa 3072 bits 0.167895s 0.003244s      6.0    308.3
rsa 4096 bits 0.384231s 0.005715s      2.6    175.0
rsa 7680 bits 2.396000s 0.019795s      0.4     50.5

Running RSA Speed Test with default OpenSSL C MMM implementation...
Doing 512 bits private rsa's for 10s: 4029 512 bits private RSA's in 9.67s
Doing 512 bits public rsa's for 10s: 48547 512 bits public RSA's in 9.67s
Doing 1024 bits private rsa's for 10s: 505 1024 bits private RSA's in 6.64s
Doing 1024 bits public rsa's for 10s: 15459 1024 bits public RSA's in 9.23s
Doing 2048 bits private rsa's for 10s: 122 2048 bits private RSA's in 9.71s
Doing 2048 bits public rsa's for 10s: 4722 2048 bits public RSA's in 9.44s
Doing 3072 bits private rsa's for 10s: 39 3072 bits private RSA's in 9.58s
Doing 3072 bits public rsa's for 10s: 2148 3072 bits public RSA's in 9.52s
Doing 4096 bits private rsa's for 10s: 19 4096 bits private RSA's in 9.87s
Doing 4096 bits public rsa's for 10s: 1367 4096 bits public RSA's in 9.67s
Doing 7680 bits private rsa's for 10s: 4 7680 bits private RSA's in 12.80s
Doing 7680 bits public rsa's for 10s: 381 7680 bits public RSA's in 9.68s
Doing 15360 bits private rsa's for 10s: 1 15360 bits private RSA's in 23.92s
Doing 15360 bits public rsa's for 10s: 98 15360 bits public RSA's in 9.67s
version: 3.1.1
built on: Tue Aug  1 21:20:39 2023 UTC
options: bn(64,32)
compiler: gcc -fPIC -pthread -Wa,--noexecstack -Wall -O3 -march=armv4 -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_BUILDING_OPENSSL -DNDEBUG
CPUINFO: OPENSSL_armcap=0x0
                  sign    verify    sign/s verify/s
rsa  512 bits 0.002400s 0.000199s    416.6   5020.4
rsa 1024 bits 0.013149s 0.000597s     76.1   1674.9
rsa 2048 bits 0.079590s 0.001999s     12.6    500.2
rsa 3072 bits 0.245641s 0.004432s      4.1    225.6
rsa 4096 bits 0.519474s 0.007074s      1.9    141.4
rsa 7680 bits 3.200000s 0.025407s      0.3     39.4
```
