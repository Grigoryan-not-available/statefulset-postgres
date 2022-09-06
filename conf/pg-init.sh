#!/bin/bash

PGDATA=/var/lib/postgresql/data/pgdata
PODINFO_LABELS_FILE=/etc/podinfo/labels

if [ ! -d $PGDATA ] 
then
  echo "The postgresql data directory $PGDATA does not exist."

  if [ ! -e $PODINFO_LABELS_FILE ]
  then
    echo "  The podinfo file $PODINFO_LABELS_FILE does not exist. Did you create a downward API volume?" 
    echo "  Exitting with a failure."
    exit 1
  fi

  cat $PODINFO_LABELS_FILE

  if grep -q 'statefulset.kubernetes.io/pod-name="postgresql-sts-0"' $PODINFO_LABELS_FILE
  then
    echo "  Identified this Pod to be the static primary: postgresql-sts-0."
    echo "  Executing initdb..."
    initdb --username postgres --pwfile <(echo $POSTGRES_PASSWORD)
    if [ $? -ne 0 ] 
    then
      echo "  Failed to execute initdb."
      exit 1
    fi
  else
    echo "  Identified this Pod to a secondary."
    echo "  Executing pg_basebackup..."
    /usr/local/bin/pg_basebackup -h postgresql-primary.default.svc.cluster.local -U replicator -p 5432 -D $PGDATA -Fp -Xs -R
    if [ $? -ne 0 ] 
    then
      echo "  Failed to execute pg_basebackup."
      exit 1
    fi
  fi
  echo "  Done."  
else
  echo "Found the postgresql data directory at $PGDATA."
fi

echo "Starting PostgreSQL..."
chmod 700 -R /var/lib/postgresql/data/pgdata
/usr/local/bin/postgres -c config_file=/etc/postgresql/postgresql.conf -D $PGDATA

