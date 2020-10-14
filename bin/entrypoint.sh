#!/usr/bin/env bash

set -e


cd /opt/odoo

# Update Odoo conf with env variables 
conf=$(cat /etc/odoo/odoo.conf | envsubst)
echo "$conf" > /etc/odoo/odoo.conf
#chown odoo /etc/odoo/odoo.conf


case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            exec odoo "$@"
        fi
        ;;
    -*)
        exec odoo "$@"
        ;;
    *)
        exec "$@"
esac

exit 1
