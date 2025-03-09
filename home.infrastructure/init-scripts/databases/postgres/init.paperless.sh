#!/bin/bash

psql <<EOF
    create database $PAPERLESS_POSTGRES_DATABASE;
    create user $PAPERLESS_POSTGRES_USER with encrypted password '$PAPERLESS_POSTGRES_PASSWORD';
    revoke all privileges on database $PAPERLESS_POSTGRES_DATABASE from public;
    grant all privileges on database $PAPERLESS_POSTGRES_DATABASE to $PAPERLESS_POSTGRES_USER;
EOF