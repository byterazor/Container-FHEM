#!/bin/bash

if [ -z ${USECONFIGDB} ]; then
    CFG=/opt/fhem/fhem.cfg

else

    CFG=configDB

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
    fi

fi

if [ -n "${USELOGDB}" ]; then

    if [ -z ${LOG_DATABASE_ENGINE} ]; then
        LOG_DATABASE_ENGINE=sqlite

        if [ -z ${LOG_DATABASE} ]; then
            LOG_DATABASE="/opt/fhem/logdb.db"
        fi

    fi

    if [ -z ${LOG_DATABASE} ]; then
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
    fi

fi

export FHEM_GLOBALATTR="nofork=1 updateInBackground=1 logfile=/dev/stdout"
cd /opt/fhem || exit 255
./fhem.pl ${CFG}