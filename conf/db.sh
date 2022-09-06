#!/bin/bash

psql -h postgresql-primary.default.svc.cluster.local -U postgres -c "CREATE USER $POSTGRES_REPLICATION_USERNAME WITH REPLICATION ENCRYPTED PASSWORD '$POSTGRES_REPLICATION_PASSWORD'"
psql -h postgresql-primary.default.svc.cluster.local -U postgres -f /script/init-db.sql
