#!/bin/bash

kubectl -n opspilot port-forward service/elasticsearch 9200:9200