#!/bin/bash

# Elasticsearch 地址和索引名称
ES_URL="http://localhost:9200"
INDEX_NAME="manage_zone"


# JSON 数据
JSON_DATA='{
  "id": "opspilot-ft2",
  "name": "Opspilot Ft2",
  "app": "opspilot",
  "env": "ft2",
  "delayedMin": 10,
  "serviceBlackList": [],
  "apiBlackList": [],
  "exceptionBlackList": [],
  "sort": 99,
  "datasource": {
    "apm": {
      "type": "skywalking",
      "enable": true,
      "app": "",
      "env": "",
      "endpoint": "http://10.158.215.92:12800/graphql",
      "endpoint2": "http://10.158.215.42:9200",
      "group": ["ft2@opspilot"],
      "mode": "full",
      "traceAnalysis": true,
      "interval": 60,
      "concurrency": 10,
      "ak": "",
      "sk": ""
    },
    "frontend": {
      "type": "skywalking",
      "enable": true,
      "app": "",
      "env": "",
      "endpoint": "http://10.158.215.92:12800/graphql",
      "endpoint2": "http://10.158.215.42:9200",
      "group": ["ft2"],
      "mode": "full",
      "traceAnalysis": true,
      "ak": "",
      "sk": ""
    }
  }
}'

# 发送请求
curl -XPOST "$ES_URL/$INDEX_NAME/_doc" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA"