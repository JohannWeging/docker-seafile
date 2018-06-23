#!/bin/bash
set -e

export PYTHON='/usr/bin/python'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export DATADIR="/seafile"
export BASEPATH="/opt/haiwen"
export INSTALLPATH="${BASEPATH}/seafile-server-${SEAFILE_VERSION}"
export SEAFILE_DATA_DIR="${DATADIR}/seafile-data"
export CCNET_CONF_DIR="${BAES}/ccnet"
export SEAFILE_CONF_DIR="${DATADIR}/conf"
export SEAFILE_CENTRAL_CONF_DIR=${SEAFILE_CONF_DIR}
export SEAHUB_DATA_DIR="${BASEPATH}/seahub-data"
export PYTHONPATH=${INSTALLPATH}/seafile/lib/python2.6/site-packages:${INSTALLPATH}/seafile/lib64/python2.6/site-packages:${INSTALLPATH}/seahub:${INSTALLPATH}/seahub/thirdpart:${INSTALLPATH}/seafile/lib/python2.7/site-packages:${INSTALLPATH}/seafile/lib64/python2.7/site-packages:${PYTHONPATH:-}
export SEAFILE_PORT=${SEAFILE_PORT:-"8082"}

rm -f /tmp/lock.lock

mkdir -p ${DATADIR}
chown seafile:seafile ${DATADIR}

[ ! -e ${SEAFILE_DATA_DIR} ] && gosu seafile python ${INSTALLPATH}/setup-seafile-mysql.py auto \
    -n "${SEAFILE_NAME}" \
    -i "${SEAFILE_ADDRESS}" \
    -p "${SEAFILE_PORT}" \
    -d "${SEAFILE_DATA_DIR}" \
    -o "${MYSQL_SERVER}" \
    -t "${MYSQL_PORT:-3306}" \
    -u "${MYSQL_USER}" \
    -w "${MYSQL_USER_PASSWORD}" \
    -q "${MYSQL_USER_HOST:-"%"}" \
    -e 1 \
    -c "${CCNET_DB:-ccnet}" \
    -s "${SEAFILE_DB:-seafile}" \
    -b "${SEAHUB_DB:-seahub}"

sed -i "s/= ask_admin_email()/= \"${SEAFILE_ADMIN}\"/" ${INSTALLPATH}/check_init_admin.py
sed -i "s/= ask_admin_password()/= \"${SEAFILE_ADMIN_PW}\"/" ${INSTALLPATH}/check_init_admin.py

for SEADIR in "ccnet" "conf" "seahub-data"; do
    if [ -d /seafile/${SEADIR} ]; then
        ln -sf /seafile/${SEADIR} ${BASEPATH}/${SEADIR}
    fi
    if [ -d ${BASEPATH}/${SEADIR} ]; then
        mv ${BASEPATH}/${SEADIR} /seafile/${SEADIR}
        ln -sf /seafile/${SEADIR} ${BASEPATH}/${SEADIR}
    fi
done

ln -sf ${INSTALLPATH} /opt/haiwen/seafile-server-latest

gosu seafile ${INSTALLPATH}/seafile.sh start
sleep 5
gosu seafile ${INSTALLPATH}/seahub.sh start-fastcgi
sleep 5
[ ! -e ${SEAFILE_DATA_DIR} ] && gosu seafile python ${INSTALLPATH}/check_init_admin.py

nginx -c /etc/nginx/nginx.conf

while true; do
  sleep 10
  lockfile-create --use-pid --retry 1 /tmp/lock || continue
  for SEAFILE_PROC in "seafile-control" "ccnet-server" "seaf-server" "nginx:"; do
    pkill -0 -f "${SEAFILE_PROC}"
    sleep 1
  done
  lockfile-remove /tmp/lock
done
