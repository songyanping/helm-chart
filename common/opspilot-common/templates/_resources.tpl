{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return a resource request/limit object based on a given preset.
These presets are for basic testing and not meant to be used in production
{{ include "common.resources.preset" (dict "type" "nano") -}}
*/}}
{{- define "common.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "100m" "memory" "256Mi")
      "limits" (dict "cpu" "200m" "memory" "512Mi")
   )
  "medium" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "200m" "memory" "512Mi")
      "limits" (dict "cpu" "500m" "memory" "1024Mi")
   )
  "large" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "500m" "memory" "1024Mi")
      "limits" (dict "cpu" "1" "memory" "2048Mi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}


{{- define "common.general.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "100m" "memory" "512Mi")
      "limits" (dict "cpu" "200m" "memory" "1024Mi")
   )
  "medium" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "200m" "memory" "1024Mi")
      "limits" (dict "cpu" "500m" "memory" "2048Mi")
   )
  "large" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "500m" "memory" "2048Mi")
      "limits" (dict "cpu" "1" "memory" "4096Mi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "common.memory.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "100m" "memory" "1024Mi")
      "limits" (dict "cpu" "200m" "memory" "2048Mi")
   )
  "medium" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "200m" "memory" "2048Mi")
      "limits" (dict "cpu" "500m" "memory" "4096Mi")
   )
  "large" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "500m" "memory" "4096Mi")
      "limits" (dict "cpu" "1" "memory" "8192Mi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "opspilot.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "250m" "memory" "1024Mi")
      "limits" (dict "cpu" "250m" "memory" "1024Mi")
   )
  "medium" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "500m" "memory" "2048Mi")
      "limits" (dict "cpu" "500m" "memory" "2048Mi")
   )
  "large" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "1.0" "memory" "4Gi")
      "limits" (dict "cpu" "1.0" "memory" "4Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}


{{- define "skywalking.ui.resources.preset" -}}
{{/* the same resources for different sacle */}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "200m" "memory" "512Mi")
      "limits" (dict "cpu" "200m" "memory" "512Mi")
   )
  "medium" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "200m" "memory" "512Mi")
      "limits" (dict "cpu" "200m" "memory" "512Mi")
   )
  "large" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "200m" "memory" "512Mi")
      "limits" (dict "cpu" "200m" "memory" "512Mi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "skywalking.oap.resources.preset" -}}
{{/* cpu:mem=1:8 */}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 2
      "requests" (dict "cpu" "500m" "memory" "4Gi")
      "limits" (dict "cpu" "500m" "memory" "4Gi")
   )
  "medium" (dict
      "replicaCount" 4
      "requests" (dict "cpu" "1.0" "memory" "8Gi")
      "limits" (dict "cpu" "1.0" "memory" "8Gi")
   )
  "large" (dict
      "replicaCount" 8
      "requests" (dict "cpu" "1" "memory" "16Gi")
      "limits" (dict "cpu" "1" "memory" "16Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.data.resources.preset" -}}
{{/* cpu:jvm-mem:lucene-mem=1:8:8 */}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 2
      "heapSize" "4096m"
      "requests" (dict "cpu" "500m" "memory" "8Gi")
      "limits" (dict "cpu" "500m" "memory" "8Gi")
   )
  "medium" (dict
      "replicaCount" 4
      "heapSize" "8192m"
      "requests" (dict "cpu" "1.0" "memory" "16Gi")
      "limits" (dict "cpu" "1.0" "memory" "16Gi")
   )
  "large" (dict
      "replicaCount" 8
      "heapSize" "16384m"
      "requests" (dict "cpu" "2.0" "memory" "32Gi")
      "limits" (dict "cpu" "2.0" "memory" "32Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.coordinating.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "heapSize" "512m"
      "requests" (dict "cpu" "200m" "memory" "1Gi")
      "limits" (dict "cpu" "200m" "memory" "1Gi")
   )
  "medium" (dict
      "replicaCount" 2
      "heapSize" "2048m"
      "requests" (dict "cpu" "500m" "memory" "4Gi")
      "limits" (dict "cpu" "500m" "memory" "4Gi")
   )
  "large" (dict
      "replicaCount" 4
      "heapSize" "4096m"
      "requests" (dict "cpu" "1.0" "memory" "8Gi")
      "limits" (dict "cpu" "1.0" "memory" "8Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.ingest.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "heapSize" "1024m"
      "requests" (dict "cpu" "100m" "memory" "2Gi")
      "limits" (dict "cpu" "100m" "memory" "2Gi")
   )
  "medium" (dict
      "replicaCount" 2
      "heapSize" "1536m"
      "requests" (dict "cpu" "300m" "memory" "3Gi")
      "limits" (dict "cpu" "300m" "memory" "3Gi")
   )
  "large" (dict
      "replicaCount" 4
      "heapSize" "2048m"
      "requests" (dict "cpu" "500m" "memory" "4Gi")
      "limits" (dict "cpu" "500m" "memory" "4Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.master.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "heapSize" "512m"
      "requests" (dict "cpu" "200m" "memory" "1Gi")
      "limits" (dict "cpu" "200m" "memory" "1Gi")
   )
  "medium" (dict
      "replicaCount" 2
      "heapSize" "1024m"
      "requests" (dict "cpu" "300m" "memory" "2Gi")
      "limits" (dict "cpu" "300m" "memory" "2Gi")
   )
  "large" (dict
      "replicaCount" 3
      "heapSize" "2048m"
      "requests" (dict "cpu" "500m" "memory" "4Gi")
      "limits" (dict "cpu" "500m" "memory" "4Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "prometheus.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "small" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "1.0" "memory" "4Gi")
      "limits" (dict "cpu" "1.0" "memory" "4Gi")
   )
  "medium" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "2.0" "memory" "8Gi")
      "limits" (dict "cpu" "2.0" "memory" "8Gi")
   )
  "large" (dict
      "replicaCount" 1
      "requests" (dict "cpu" "4.0" "memory" "16Gi")
      "limits" (dict "cpu" "4.0" "memory" "16Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}