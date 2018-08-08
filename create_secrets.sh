#!/usr/bin/env bash

echo " > recreating secrets"

if [ ! -f secrets.env ]; then
    echo " > missing secrets.env file - cannot create k8s secrets"
    exit 1
fi

if ([ "${1}" == "" ] || [ "${1}" == "env-vars" ]); then
    kubectl delete secret env-vars
    kubectl create secret generic env-vars --from-env-file secrets.env
fi

if ([ "${1}" == "" ] || [ "${1}" == "etc-ckan-default" ]); then
    source secrets.env
    export CKAN_BEAKER_SESSION_SECRET="${CKAN_BEAKER_SESSION_SECRET}"
    export CKAN_APP_INSTANCE_UUID="${CKAN_APP_INSTANCE_UUID}"
    export CKAN_SQLALCHEMY_URL="postgresql://postgres:${POSTGRES_PASSWORD}@db/ckan"
    export CKAN_SITE_URL="https://www.odata.org.il/"
    export CKAN_SOLR_URL="http://solr:8983/solr/"
    export CKAN_REDIS_URL="redis://redis:6379/0"
    export CKAN_STORAGE_PATH="/var/lib/ckan/data"
    export CKAN_MAX_RESOURCE_SIZE="500"
    export CKAN_DEBUG=false
    rm -rf k8s/etc-ckan-default
    mkdir -p k8s/etc-ckan-default
    export COMMENT="-- This file contains secrets, do not commit / expose publicly! --"
    ./templater.sh who.ini.template > k8s/etc-ckan-default/who.ini
    export COMMENT="-- This file contains secrets, do not commit / expose publicly! --"
    ./templater.sh development.ini.template > k8s/etc-ckan-default/development.ini
    kubectl delete secret etc-ckan-default
    kubectl create secret generic etc-ckan-default --from-file k8s/etc-ckan-default/
    rm -rf k8s/etc-ckan-default/
else
    echo "WARNING: skipping etc-ckan-default"
fi

kubectl describe secret env-vars
kubectl describe secret etc-ckan-default

