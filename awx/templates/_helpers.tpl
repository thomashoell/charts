{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "awx.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "awx.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "awx.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "awx.ingress.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Common volume mounts
*/}}
{{- define "awx.volumeMounts" -}}
- name: settings
  mountPath: "/etc/tower/settings.py"
  subPath: settings.py
  readOnly: true
- name: confd
  mountPath: "/etc/tower/conf.d/"
  readOnly: true
- name: secret-key
  mountPath: "/etc/tower/SECRET_KEY"
  subPath: SECRET_KEY
  readOnly: true
{{- end -}}

{{/*
Common volume definitions
*/}}
{{- define "awx.volumes" -}}
- name: settings
  configMap:
    name: {{ include "awx.fullname" . }}-settings
    items:
      - key: settings.py
        path: settings.py
- name: secret-key
  secret:
    secretName: {{ include "awx.fullname" . }}-secret-key
    items:
      - key: SECRET_KEY
        path: SECRET_KEY
- name: confd
  secret:
    secretName: {{ include "awx.fullname" . }}-confd
{{- end -}}

{{/*
Create PostgreSQL container image/tag depending on whether postgres chart is enabled or not
*/}}
{{- define "postgres-image" -}}
{{- if .Values.postgresql.enabled -}}
{{/*The following lines are necessary to avoid having the image tag treated as a float like bitnami/postgresql:%!s(float64=9.6)*/}}
{{- $imageTag := .Values.postgresql.image.tag | quote -}}
{{- printf "%s:%s" .Values.postgresql.image.repository $imageTag | replace "\"" "" -}}
{{- else -}}
{{- printf "%s:%s" "bitnami/postgresql" "latest" -}}
{{- end -}}
{{- end -}}

{{/*
Create PostgreSQL host name depending on whether an external database is used or not
*/}}
{{- define "awx-db-host" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "postgresql" -}}
{{- else -}}
{{- .Values.db.host -}}
{{- end -}}
{{- end -}}

{{/*
Create PostgreSQL port depending on whether an external database is used or not
*/}}
{{- define "awx-db-port" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.service.port -}}
{{- else -}}
{{- .Values.db.port -}}
{{- end -}}
{{- end -}}

{{/*
Create PostgreSQL database name depending on whether an external database is used or not
*/}}
{{- define "awx-db-name" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.postgresqlDatabase -}}
{{- else -}}
{{- .Values.db.name -}}
{{- end -}}
{{- end -}}

{{/*
Create PostgreSQL database name depending on whether an external database is used or not
*/}}
{{- define "awx-db-user" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.postgresqlUsername -}}
{{- else -}}
{{- .Values.db.user -}}
{{- end -}}
{{- end -}}

{{/*
Create PostgreSQL database name depending on whether an external database is used or not
*/}}
{{- define "awx-db-password" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.postgresqlPassword -}}
{{- else -}}
{{- .Values.db.password -}}
{{- end -}}
{{- end -}}