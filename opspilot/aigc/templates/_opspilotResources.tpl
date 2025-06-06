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
{{- define "opspilot.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "micro" (dict
      "requests" (dict "cpu" "250m" "memory" "256Mi")
      "limits" (dict "cpu" "500m" "memory" "512Mi")
   )
  "small" (dict 
      "requests" (dict "cpu" "500m" "memory" "512Mi")
      "limits" (dict "cpu" "750m" "memory" "768Mi")
   )
  "medium" (dict 
      "requests" (dict "cpu" "500m" "memory" "1024Mi")
      "limits" (dict "cpu" "750m" "memory" "1536Mi")
   )
  "large" (dict 
      "requests" (dict "cpu" "1.0" "memory" "2048Mi")
      "limits" (dict "cpu" "1.5" "memory" "3072Mi")
   )
  "smallOpspilot" (dict
      "requests" (dict "cpu" "250m" "memory" "1024Mi")
      "limits" (dict "cpu" "250m" "memory" "1024Mi")
   )
  "mediumOpspilot" (dict
      "requests" (dict "cpu" "500m" "memory" "2048Mi")
      "limits" (dict "cpu" "500m" "memory" "2048Mi")
   )
  "largeOpspilot" (dict
      "requests" (dict "cpu" "1.0" "memory" "4Gi")
      "limits" (dict "cpu" "1.0" "memory" "4Gi")
   )
  "smallSkywalking" (dict
      "requests" (dict "cpu" "1.0" "memory" "8Gi")
      "limits" (dict "cpu" "1.0" "memory" "8Gi")
   )
  "mediumSkywalking" (dict
      "requests" (dict "cpu" "2.0" "memory" "16Gi")
      "limits" (dict "cpu" "2.0" "memory" "16Gi")
   )
  "largeSkywalking" (dict
      "requests" (dict "cpu" "4.0" "memory" "32Gi")
      "limits" (dict "cpu" "4.0" "memory" "32Gi")
   )
  "smallElasticsearch" (dict
      "requests" (dict "cpu" "1.0" "memory" "8Gi")
      "limits" (dict "cpu" "1.0" "memory" "8Gi")
   )
  "mediumElasticsearch" (dict
      "requests" (dict "cpu" "2.0" "memory" "16Gi")
      "limits" (dict "cpu" "2.0" "memory" "16Gi")
   )
  "largeElasticsearch" (dict
      "requests" (dict "cpu" "4.0" "memory" "32Gi")
      "limits" (dict "cpu" "4.0" "memory" "32Gi")
   )
  "smallPrometheus" (dict
      "requests" (dict "cpu" "1.0" "memory" "4Gi")
      "limits" (dict "cpu" "1.0" "memory" "4Gi")
   )
  "mediumPrometheus" (dict
      "requests" (dict "cpu" "2.0" "memory" "8Gi")
      "limits" (dict "cpu" "2.0" "memory" "8Gi")
   )
  "largePrometheus" (dict
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
