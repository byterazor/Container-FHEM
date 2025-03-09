FROM alpine as dummy
# first line ist just that docker can build it... buildah can do without this line ...

#
# This image provides a more secure environment for running fhem than the 
# vendor provided one. 
#
# It does not rely on running apt-get update/upgrade within the container but 
# it is expected that every night a new version is build updating fhem and all 
# its dependencies.
#
LABEL maintainer="dmeyer@federationhq.de"
LABEL version="0.1"
LABEL build_date=$ARG{BUILD_DATE}
LABEL license="MIT"


#
# this image is only required for the build stage as it provides 
# an easy way to drop build dependencies in the main image
#
FROM debian:bookworm-slim as builder

# Ensure we have a build environment
RUN apt-get -q -y update && apt-get -q -y install git subversion build-essential pkg-config libtool libusb-dev autoconf locales-all

RUN cd /usr/src; git clone https://github.com/xypron/sispmctl.git
RUN cd /usr/src/sispmctl;./autogen.sh && ./configure --enable-webless
RUN cd /usr/src/sispmctl;make; ls -al

RUN export LC_CTYPE=en_US.UTF-8;svn co https://svn.fhem.de/fhem/trunk/fhem
RUN git clone https://gitea.federationhq.de/byterazor/FHEM-NEWSISPM.git /NEWSISPM
RUN git clone https://gitea.federationhq.de/byterazor/FHEM-NTFY.git /FHEM-NTFY
RUN git clone https://gitea.federationhq.de/byterazor/FHEM-Lightcontrol.git /FHEM-Lightcontrol
RUN git clone https://github.com/PatricSperling/FHEM_SST.git /SST

# patch LA_Metric to support any apikey
RUN sed 's/.*apikey does not.*//' -i /fhem/FHEM/70_LaMetric2.pm
RUN sed 's/.*apikey \!.*//' -i /fhem/FHEM/70_LaMetric2.pm
#
# the main fhem image
#
FROM debian:bookworm-slim

RUN apt-get -qy update 
RUN apt-get -qy install tini bash tzdata ca-certificates curl gnupg locales jq nmap sqlite3 wget unzip mariadb-client i2c-tools 

# configure locales and tzdata
RUN sed -i '/de_DE.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG de_DE.UTF-8  
ENV LANGUAGE de_DE:de  
ENV LC_ALL de_DE.UTF-8  
RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
ENV TZ Europe/Berlin

#install fhem dependencies from debian repository
RUN apt-get -qqy install --no-install-recommends \
    libdbd-sqlite3-perl \
    libarchive-extract-perl \
    libarchive-zip-perl \
    libcgi-pm-perl \
    libcpanel-json-xs-perl \
    libdbd-mariadb-perl \
    libdbd-mysql-perl \
    libdbd-pg-perl \
    libdbd-pgsql \
    libdbd-sqlite3 \
    libdbd-sqlite3-perl \
    libdbi-perl \
    libdevice-serialport-perl \
    libdevice-usb-perl \
    libgd-graph-perl \
    libgd-text-perl \
    libimage-imlib2-perl \
    libimage-info-perl \
    libimage-librsvg-perl \
    libio-all-perl \
    libio-file-withpath-perl \
    libio-interface-perl \
    libio-socket-inet6-perl \
    libjson-perl \
    libjson-pp-perl \
    libjson-xs-perl \
    liblist-moreutils-perl \
    libmail-gnupg-perl \
    libmail-imapclient-perl \
    libmail-sendmail-perl \
    libmime-base64-perl \
    libmime-lite-perl \
    libnet-server-perl \
    libsocket6-perl \
    libterm-readline-perl-perl \
    libtext-csv-perl \
    libtext-diff-perl \
    libtext-iconv-perl \
    libtimedate-perl \
    libutf8-all-perl \
    libwww-curl-perl \
    libwww-perl \
    libxml-libxml-perl \
    libxml-parser-lite-perl \
    libxml-parser-perl \
    libxml-simple-perl \
    libxml-stream-perl \
    libxml-treebuilder-perl \
    libxml-xpath-perl \
    libxml-xpathengine-perl \
    libyaml-libyaml-perl \
    libyaml-perl \
    perl-base \
    libalgorithm-merge-perl \
    libauthen-bitcard-perl \
    libauthen-captcha-perl \
    libauthen-cas-client-perl \
    libauthen-dechpwd-perl \
    libauthen-htpasswd-perl \
    libauthen-krb5-admin-perl \
    libauthen-krb5-perl \
    libauthen-krb5-simple-perl \
    libauthen-libwrap-perl \
    libauthen-ntlm-perl \
    libauthen-oath-perl \
    libauthen-pam-perl \
    libauthen-passphrase-perl \
    libauthen-radius-perl \
    libauthen-sasl-cyrus-perl \
    libauthen-sasl-perl \
    libauthen-sasl-saslprep-perl \
    libauthen-scram-perl \
    libauthen-simple-cdbi-perl \
    libauthen-simple-dbi-perl \
    libauthen-simple-dbm-perl \
    libauthen-simple-http-perl \
    libauthen-simple-kerberos-perl \
    libauthen-simple-ldap-perl \
    libauthen-simple-net-perl \
    libauthen-simple-pam-perl \
    libauthen-simple-passwd-perl \
    libauthen-simple-perl \
    libauthen-simple-radius-perl \
    libauthen-simple-smb-perl \
    libauthen-smb-perl \
    libauthen-tacacsplus-perl \
    libauthen-u2f-perl \
    libauthen-u2f-tester-perl \
    libclass-dbi-mysql-perl \
    libclass-isa-perl \
    libclass-loader-perl \
    libcommon-sense-perl \
    libconvert-base32-perl \
    libcpan-meta-yaml-perl \
    libcrypt-blowfish-perl \
    libcrypt-cast5-perl \
    libcrypt-cbc-perl \
    libcrypt-ciphersaber-perl \
    libcrypt-cracklib-perl \
    libcrypt-des-ede3-perl \
    libcrypt-des-perl \
    libcrypt-dh-gmp-perl \
    libcrypt-dh-perl \
    libcrypt-dsa-perl \
    libcrypt-ecb-perl \
    libcrypt-eksblowfish-perl \
    libcrypt-format-perl \
    libcrypt-gcrypt-perl \
    libcrypt-generatepassword-perl \
    libcrypt-hcesha-perl \
    libcrypt-jwt-perl \
    libcrypt-mysql-perl \
    libcrypt-openssl-bignum-perl \
    libcrypt-openssl-dsa-perl \
    libcrypt-openssl-ec-perl \
    libcrypt-openssl-pkcs10-perl \
    libcrypt-openssl-random-perl \
    libcrypt-openssl-rsa-perl \
    libcrypt-openssl-x509-perl \
    libcrypt-passwdmd5-perl \
    libcrypt-pbkdf2-perl \
    libcrypt-random-seed-perl \
    libcrypt-random-source-perl \
    libcrypt-rc4-perl \
    libcrypt-rijndael-perl \
    libcrypt-rsa-parse-perl \
    libcrypt-saltedhash-perl \
    libcrypt-simple-perl \
    libcrypt-smbhash-perl \
    libcrypt-smime-perl \
    libcrypt-ssleay-perl \
    libcrypt-twofish-perl \
    libcrypt-u2f-server-perl \
    libcrypt-unixcrypt-perl \
    libcrypt-unixcrypt-xs-perl \
    libcrypt-urandom-perl \
    libcrypt-util-perl \
    libcrypt-x509-perl \
    libcryptx-perl \
    libdata-dump-perl \
    libdatetime-format-strptime-perl \
    libdatetime-perl \
    libdevel-size-perl \
    libdigest-bcrypt-perl \
    libdigest-bubblebabble-perl \
    libdigest-crc-perl \
    libdigest-elf-perl \
    libdigest-hmac-perl \
    libdigest-jhash-perl \
    libdigest-md2-perl \
    libdigest-md4-perl \
    libdigest-md5-file-perl \
    libdigest-perl-md5-perl \
    libdigest-sha-perl \
    libdigest-sha3-perl \
    libdigest-ssdeep-perl \
    libdigest-whirlpool-perl \
    libdpkg-perl \
    libencode-perl \
    liberror-perl \
    libev-perl \
    libextutils-makemaker-cpanfile-perl \
    libfile-copy-recursive-perl \
    libfile-fcntllock-perl \
    libfinance-quote-perl \
    libgnupg-interface-perl \
    libhtml-strip-perl \
    libhtml-treebuilder-xpath-perl \
    libio-socket-inet6-perl \
    libio-socket-ip-perl \
    libio-socket-multicast-perl \
    libio-socket-portstate-perl \
    libio-socket-socks-perl \
    libio-socket-ssl-perl \
    libio-socket-timeout-perl \
    liblinux-inotify2-perl \
    libmath-round-perl \
    libmodule-pluggable-perl \
    libmojolicious-perl \
    libmoose-perl \
    libmoox-late-perl \
    libmp3-info-perl \
    libmp3-tag-perl \
    libnet-address-ip-local-perl \
    libnet-bonjour-perl \
    libnet-jabber-perl \
    libnet-oauth-perl \
    libnet-oauth2-perl \
    libnet-sip-perl \
    libnet-snmp-perl \
    libnet-ssleay-perl \
    libnet-telnet-perl \
    libnet-xmpp-perl \
    libnmap-parser-perl \
    librivescript-perl \
    librpc-xml-perl \
    libsnmp-perl \
    libsnmp-session-perl \
    libsoap-lite-perl \
    libsocket-perl \
    libswitch-perl \
    libsys-hostname-long-perl \
    libsys-statistics-linux-perl \
    libterm-readkey-perl \
    libterm-readline-perl-perl \
    libtime-period-perl \
    libtypes-path-tiny-perl \
    liburi-escape-xs-perl \
    perl


# install fhem dependencies from builder image
COPY --from=builder  /usr/src/sispmctl/src/.libs/*.so* /usr/lib/
COPY --from=builder  /usr/src/sispmctl/src/.libs/sispmctl /usr/bin/
COPY --from=builder  /fhem /opt/fhem
COPY --from=builder  /NEWSISPM/FHEM/* /opt/fhem/FHEM/
COPY --from=builder  /FHEM-NTFY/FHEM/* /opt/fhem/FHEM/
COPY --from=builder  /FHEM-Lightcontrol/FHEM/* /opt/fhem/FHEM/
COPY --from=builder  /SST/FHEM/* /opt/fhem/FHEM/
COPY --from=builder  /SST/www/* /opt/fhem/www/

RUN cd /opt/fhem; contrib/commandref_join.pl

# update libraries
RUN ldconfig

# fhem runs under the fhem user
RUN adduser -u 34342 --disabled-login fhem
RUN chown -R fhem:fhem /opt/fhem 

# add entrypoint and ensure executability
ADD scripts/entryPoint.sh /entryPoint.sh
RUN chmod +x /entryPoint.sh

USER fhem

ENTRYPOINT ["/usr/bin/tini", "--", "/entryPoint.sh"]