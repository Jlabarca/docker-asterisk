#!/bin/bash
set -ex

mkdir -p /usr/src/asterisk
cd /usr/src/asterisk
export ASTERISK_VERSION="16.4.0"
# 1.5 jobs per core works out okay
: ${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}

echo -e "\e[34m ---> Downloading Asterisk\e[0m"
curl -sL http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz |
    tar --strip-components 1 -xz

echo -e "\e[34m ---> Building Asterisk\e[0m"
./bootstrap.sh
./contrib/scripts/get_mp3_source.sh
./contrib/scripts/install_prereq install
./configure --with-pjproject-bundled --with-resample --with-jansson-bundled

make menuselect/menuselect menuselect-tree menuselect.makeopts
menuselect/menuselect --disable BUILD_NATIVE \
--enable BETTER_BACKTRACES  \
--enable codec_opus \
--enable func_odbc \
--enable res_odbc \
--enable res_pjsip \
--enable res_ari \
menuselect.makeopts

echo -e "\e[34m ---> Downloading Core Sounds\e[0m"
# download more sounds
for i in CORE-SOUNDS-EN; do
    for j in ULAW ALAW G722 G729 GSM SLN16; do
        menuselect/menuselect --enable $i-$j menuselect.makeopts
    done
done

echo -e "\e[34m ---> Installing Asterisk\e[0m"
make -j ${JOBS} all
make install
chown -R asterisk:asterisk /var/*/asterisk
chmod -R 750 /var/spool/asterisk
mkdir -p /etc/asterisk/

# copy default configs
make basic-pbx

#add codec g729
wget http://asterisk.hosting.lv/bin/codec_g729-ast160-gcc4-glibc-x86_64-core2.so -O codec_g729.so
mv codec_g729.so /usr/lib/asterisk/modules/

# set runuser and rungroup
sed -i -E 's/^;(run)(user|group)/\1\2/' /etc/asterisk/asterisk.conf

rm -rf /usr/src/asterisk
cp -a /etc/asterisk/conf /etc/asterisk/