#!/bin/bash


if [ -z ${CONFIG_DATABASE_ENGINE} ]; then
    CONFIG_DATABASE_ENGINE=sqlite

    if [ -z ${CONFIG_DATABASE} ]; then
        CONFIG_DATABASE="/opt/fhem/configDB.db"
    fi

fi

if [ -z ${CONFIG_DATABASE} ]; then
    echo "please provide CONFIG_DATABASE name"
    exit 255
fi

if [ "${CONFIG_DATABASE_ENGINE}" == "sqlite" ]; then
    echo "`cat <<EOF
    %dbconfig= (
        connection => "SQLite:dbname=${CONFIG_DATABASE}",
        user => "",
        password => ""
    );
    EOF 
    `" >> /opt/fhem/configDB.conf;
elif [ "${CONFIG_DATABASE_ENGINE}" == "mysql" ]; then

    if [ -z ${CONFIG_DATABASE_USER} ]; then
        echo "please provide CONFIG_DATABASE_USER "
        exit 255
    fi

    if [ -z ${CONFIG_DATABASE_PASS} ]; then
        echo "please provide CONFIG_DATABASE_PASS"
        exit 255
    fi

    echo "`cat <<EOF
    %dbconfig= (
        connection => "mysql:dbname=${CONFIG_DATABASE}",
        user => "${CONFIG_DATABASE_USER}",
        password => "${CONFIG_DATABASE_PASS}"
    );
    EOF
    `" >> /opt/fhem/configDB.conf;
else
    echo "unknown database engine provided in CONFIG_DATABASE_ENGINE"
    exit 255
fi

if [ -z ${LOG_DATABASE_ENGINE} ]; then
    LOG_DATABASE_ENGINE=sqlite

    if [ -z ${LOG_DATABASE} ]; then
        LOG_DATABASE="/opt/fhem/logdb.db"
    fi

fi

if [ -z ${LOG_DATABASE} ]; then
    echo "please provide LOG_DATABASE name"
    exit 255
fi


if [ "${LOG_DATABASE_ENGINE}" == "sqlite" ]; then
    echo "`cat <<EOF
    %dbconfig= (
        connection => "SQLite:dbname=${LOG_DATABASE}",
        user => "",
        password => ""
    );
    EOF
    `" >> /opt/fhem/db.conf;
elif [ "${LOG_DATABASE_ENGINE}" == "mysql" ] then

    if [ -z ${LOG_DATABASE_USER} ]; then
        echo "please provide LOG_DATABASE_USER "
        exit 255
    fi

    if [ -z ${LOG_DATABASE_PASS} ]; then
        echo "please provide LOG_DATABASE_PASS "
        exit 255
    fi

    echo "`cat <<EOF
    %dbconfig= (
        connection => "mysql:dbname=${LOG_DATABASE}",
        user => "${LOG_DATABASE_USER}",
        password => "${LOG_DATABASE_PASS}"
    );
    EOF
    `" >> /opt/fhem/db.conf;
else
    echo "unknown database engine provided in LOG_DATABASE_ENGINE"
    exit 255
fi


export FHEM_GLOBALATTR="nofork=1 updateInBackground=1 logfile=/dev/stdout"
cd /opt/fhem || exit 255
./fhem.pl confgDB