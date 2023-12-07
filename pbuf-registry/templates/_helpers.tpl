{{/*
Expand the name of the chart.
*/}}
{{- define "pbuf-registry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pbuf-registry.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pbuf-registry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pbuf-registry.labels" -}}
helm.sh/chart: {{ include "pbuf-registry.chart" . }}
{{ include "pbuf-registry.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pbuf-registry.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pbuf-registry.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pbuf-registry.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pbuf-registry.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Environment variables helper
*/}}
{{- define "pbuf-registry.env" -}}
- name: DATA_DATABASE_DSN
  valueFrom:
    secretKeyRef:
      name: {{ include "pbuf-registry.fullname" . }}
      key: DATA_DATABASE_DSN
- name: SERVER_STATIC_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "pbuf-registry.fullname" . }}
      key: SERVER_STATIC_TOKEN
- name: SERVER_GRPC_TLS_ENABLED
  value: "{{ .Values.service.grpc.tls.enabled }}"
- name: SERVER_GRPC_TLS_CERTFILE
  value: /app/certs/server-cert.pem
- name: SERVER_GRPC_TLS_KEYFILE
  value: /app/certs/server-key.pem
- name: SERVER_GRPC_AUTH_ENABLED
  value: "{{ .Values.service.grpc.auth.enabled }}"
- name: SERVER_GRPC_AUTH_TYPE
  value: "{{ .Values.service.grpc.auth.type }}"
- name: SERVER_HTTP_AUTH_ENABLED
  value: "{{ .Values.service.http.auth.enabled }}"
- name: SERVER_HTTP_AUTH_TYPE
  value: "{{ .Values.service.http.auth.type }}"
{{- end }}

{{/*
Volume mounts
*/}}
{{- define "pbuf-registry.volumeMounts" -}}
- mountPath: /app/certs/server-cert.pem
  name: secret
  readOnly: true
  subPath: server-cert.pem
- mountPath: /app/certs/server-key.pem
  name: secret
  readOnly: true
  subPath: server-key.pem
{{- end }}