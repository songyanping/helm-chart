#!/bin/bash

# Elasticsearch 地址和索引名称
ES_URL="http://elasticsearch.simple.com:80"
INDEX_NAME="aigc_config"


# JSON 数据
JSON_DATA1='{
             "id": "ab3624cd-df56-43fa-becf-d61f5571a1dm",
             "name": "阿里云text-embedding-v3",
             "api_base_url": "https://dashscope.aliyuncs.com/api/v1/services/embeddings/text-embedding/text-embedding",
             "model_name": "text-embedding-v3",
             "llm_api_key": "sk-84cfe7bfadc34a918e003a732a4051a5",
             "is_embedding_model": true,
             "is_enable": true,
             "is_default": true,
             "create_time": "2025-10-09T16:41:38.659957465+08:00",
             "update_time": "2025-10-09T16:41:38.659957631+08:00"
           }'

JSON_DATA2='{
             "id": "ab3624cd-df56-43fa-becf-d61f5571a1ds",
             "name": "gpt-5-chat",
             "api_base_url": "http://10.123.42.50:3000/v1",
             "model_name": "gpt-5-chat",
             "llm_api_key": "sk-N5z4G9F1wBdYGTLQDdBf24C4E9E742Aa9618D1D1F2EeAdE5",
             "is_embedding_model": false,
             "is_enable": true,
             "is_default": true,
             "create_time": "2025-10-09T16:41:38.659957465+08:00",
             "update_time": "2025-10-09T16:41:38.659957631+08:00"
           }'

# 发送请求
curl -XPOST "$ES_URL/$INDEX_NAME/_doc" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA1"

curl -XPOST "$ES_URL/$INDEX_NAME/_doc" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA2"