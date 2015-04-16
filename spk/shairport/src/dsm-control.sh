#!/bin/sh

# Package
PACKAGE="shairport"
DNAME="ShairPort"

# Others
PORT="4242"
SHAIRPORT="shairport-sync"
INSTALL_DIR="/usr/local/${PACKAGE}"
PATH="${INSTALL_DIR}/bin:${PATH}"
DAEMON="${INSTALL_DIR}/bin/${SHAIRPORT}"
VAR_DIR="${INSTALL_DIR}/var"
PID_FILE="${VAR_DIR}/${PACKAGE}.pid"

start_daemon ()
{
    start-stop-daemon -S -q -m -b -p ${PID_FILE} -x ${DAEMON} -- --port=${PORT} 2> /dev/null
}

stop_daemon ()
{
    start-stop-daemon -K -q -p ${PID_FILE} -x ${DAEMON}
    wait_for_status 1 20 || start-stop-daemon -K -s 9 -q -p ${PID_FILE}
}

daemon_status ()
{
    start-stop-daemon -K -q -t -p ${PID_FILE}
}

wait_for_status ()
{
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && return
        let counter=counter-1
        sleep 1
    done
    return 1
}

case $1 in
    start)
        if daemon_status
        then
            echo ${DNAME} is already running
            exit 0
        else
            echo Starting ${DNAME} ...
            start_daemon
            exit $?
        fi
        ;;
    stop)
        if daemon_status
    then
            echo Stopping ${DNAME} ...
            stop_daemon
            exit $?
        else
            echo ${DNAME} is not running
            exit 0
        fi
        ;;
    restart)
        stop_daemon
        start_daemon
        exit $?
        ;;
    status)
        if daemon_status
        then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    *)
        exit 1
        ;;
esac

