#!/bin/bash
set -e

DATA_DIR="/var/lib/mysql"
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-""}
MYSQL_DATABASE=${MYSQL_DATABASE:-""}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}

mysql_pid=
mysql=( mysql --protocol=socket -uroot )

_install_db()
{
  mkdir -p "${DATA_DIR}"
  chown -R mysql:mysql "${DATA_DIR}"
  mysql_install_db --user=mysql --datadir="${DATA_DIR}"
}

_start_mysql()
{
  "$@" --user=mysql --skip-networking & mysql_pid="$!"
  for i in {30..0}; do
    if echo 'SELECT 1' | "${mysql}" &> /dev/null; then
      break
    fi
    echo 'MySQL init process in progress...'
    sleep 1
  done
  if [ "$i" = 0 ]; then
    echo >&2 'MySQL init process failed.'
    exit
  fi
}

_stop_mysql()
{
  if ! kill -s TERM "${mysql_pid}" || ! wait "${mysql_pid}"; then
    echo >&2 'MySQL init process failed.'
    exit 1
  fi
}

_init_config()
{
  echo 'SET @@SESSION.SQL_LOG_BIN=0;' | "${mysql[@]}"
  echo 'DELETE FROM mysql.user;' | "${mysql[@]}"
}

_init_root_user()
{
  echo "CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" | "${mysql[@]}"
  echo "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;" | "${mysql[@]}"
  echo "FLUSH PRIVILEGES;" | "${mysql[@]}"
}

_init_database()
{
  echo "DROP DATABASE IF EXISTS test;" | "${mysql[@]}"
  if [ ${MYSQL_DATABASE} ]; then
    echo "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} ;" | "${mysql[@]}"
  fi
}

_init_user()
{
  if [ "${MYSQL_DATABASE}" ]; then mysql+=( "$MYSQL_DATABASE" ); fi

  if [ "${MYSQL_USER}" -a "${MYSQL_PASSWORD}" ]; then
    echo "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ;" | "${mysql[@]}"
    if [ "${MYSQL_DATABASE}" ]; then
      echo "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' ;" | "${mysql[@]}"
    fi
    echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
  fi

  echo 'Init user done.'
}

_init_data()
{
  echo 'Init mysql config...'
  _init_config

  echo 'Init root user...'
  _init_root_user
  mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )

  echo 'Init database...'
  _init_database

  echo 'Init user...'
  _init_user

  echo 'Init data done.'
}

_init_mysql()
{
  if [ ! -d "${DATA_DIR}/mysql" ]; then
    echo 'Initializing base data...'
    _install_db

    echo 'Starting mysql service...'
    _start_mysql $@

    echo 'Initializing mysql data...'
    _init_data

    echo 'Stopping mysql service...'
    _stop_mysql
  fi
  echo 'MySQL Init done.'
}

_main()
{
  if [ "$1" = 'mysqld' ]; then
    echo 'Initializing MySQL...'
    _init_mysql $@
  fi

  echo 'Start mysql...'
  exec $@
}

_main $@
