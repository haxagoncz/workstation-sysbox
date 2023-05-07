#!/bin/sh

PASS=${ADMIN_PASSWORD:-admin}
USER="admin"

echo "$USER:$PASS" | chpasswd
