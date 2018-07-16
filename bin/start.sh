#!/usr/bin/env bash

bin/recreate_templates.sh
docker-compose up -d --build
