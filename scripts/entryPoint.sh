#!/bin/bash

write_config_file()
{
    FILE=$1
    ENGINE=$2
    DATABASE=$3
    USER=$4
    PASS=$5
    HOST=$6

    if [ -n $HOST ]; then
        HOST=";host=${HOST}"
    fi

    echo '%dbconfig= (' >> $FILE;
    echo "      connection => \"${ENGINE}:dbname=${DATABASE}${HOST}\"," >> $FILE
    echo "      user => \"$USER\"," >> $FILE
    echo "      password => \"$PASS\"" >> $FILE
    echo ');' >> $FILE

}

CONFIGDBFILE=/opt/fhem/configDB.conf
LOGDBFILE=/opt/fhem/db.conf


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
    
    write_config_file "${CONFIGDBFILE}" "SQLite" "${CONFIG_DATABASE}" "" "";

elif [ "${CONFIG_DATABASE_ENGINE}" == "mysql" ]; then

    if [ -z ${CONFIG_DATABASE_HOST} ]; then
        CONFIG_DATABASE_HOST="localhost"
    fi

    if [ -z ${CONFIG_DATABASE_USER} ]; then
        echo "please provide CONFIG_DATABASE_USER "
        exit 255
    fi

    if [ -z ${CONFIG_DATABASE_PASS} ]; then
        echo "please provide CONFIG_DATABASE_PASS"
        exit 255
    fi

    write_config_file "${CONFIGDBFILE}" "mysql", "${CONFIG_DATABASE}" "${CONFIG_DATABASE_USER}" "${CONFIG_DATABASE_PASS}" "${CONFIG_DATABASE_HOST}"

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

    write_config_file "${LOGDBFILE}" "SQLite" "${LOG_DATABASE}" "" ""

elif [ "${LOG_DATABASE_ENGINE}" == "mysql" ]; then
    
    if [ -z ${LOG_DATABASE_HOST} ]; then
        CONFIG_DATABASE_HOST="localhost"
    fi

    if [ -z ${LOG_DATABASE_USER} ]; then
        echo "please provide LOG_DATABASE_USER "
        exit 255
    fi

    if [ -z ${LOG_DATABASE_PASS} ]; then
        echo "please provide LOG_DATABASE_PASS "
        exit 255
    fi

    write_config_file "${LOGDBFILE}" "mysql" "${LOG_DATABASE}" "${LOG_DATABASE_USER}" "${LOG_DATABASE_PASS}" "${LOG_DATABASE_HOST}"

else
    echo "unknown database engine provided in LOG_DATABASE_ENGINE"
    exit 255
fi


export FHEM_GLOBALATTR="nofork=1 updateInBackground=1 logfile=/dev/stdout"
cd /opt/fhem || exit 255
./fhem.pl configDB