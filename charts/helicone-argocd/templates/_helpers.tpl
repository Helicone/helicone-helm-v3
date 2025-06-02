{{/*
Expand the name of the chart.
*/}}

{{- define "helicone.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.

TODO, make sure this is the ONLY fullname named template in this chart for consistencies sake
*/}}
{{- define "helicone.fullname" -}}
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
{{- define "helicone.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helicone.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helicone.labels" -}}
helm.sh/chart: {{ include "helicone.chart" . }}
{{ include "helicone.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }} {{- end }}

{{- define "helicone.env.datadogEnabled" -}}
- name: DATADOG_ENABLED
  value: "false"
{{- end -}}

{{- define "helicone.env.clickhouseHost" -}}
- name: CLICKHOUSE_HOST
  value: "http://{{ include "clickhouse.name" . }}:8123"
{{- end -}}

{{- define "helicone.env.clickhouseUser" -}}
- name: CLICKHOUSE_USER
  valueFrom:
    secretKeyRef:
      name: helicone-clickhouse-secrets
      key: user
{{- end -}}

{{- define "s3.name" -}}
{{ include "helicone.name" . }}-s3
{{- end }}

{{- define "helicone.env.s3AccessKey" -}}
- name: S3_ACCESS_KEY
{{- if eq .Values.helicone.minio.enabled true }}
  valueFrom:
    secretKeyRef:
      name: helicone-minio-secrets
      key: root_user
{{- else }}
  valueFrom:
    secretKeyRef:
      name: helicone-secrets
      key: access_key
{{- end }}
{{- end -}}

{{- define "helicone.env.s3SecretKey" -}}
- name: S3_SECRET_KEY
{{- if eq .Values.helicone.minio.enabled true }}
  valueFrom:
    secretKeyRef:
      name: helicone-minio-secrets
      key: root_password
{{- else }}
  valueFrom:
    secretKeyRef:
      name: helicone-secrets
      key: secret_key
{{- end }}
{{- end -}}

{{- define "helicone.env.s3Endpoint" -}}
- name: S3_ENDPOINT
{{- if eq .Values.helicone.minio.enabled true }}
  value: "http://{{ include "minio.name" . }}:{{ .Values.helicone.minio.service.port }}"
{{- else }}
  valueFrom:
    secretKeyRef:
      name: helicone-secrets
      key: endpoint
{{- end }}
{{- end -}}

{{- define "helicone.env.s3BucketName" -}}
- name: S3_BUCKET_NAME
{{- if eq .Values.helicone.minio.enabled true }}
  value: {{ index .Values.helicone.minio.setup.buckets 0 | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: helicone-secrets
      key: bucket_name
{{- end }}
{{- end -}}


{{/* ------------------------------------------------------------------ */}}
{{/* Generic Postgres env helpers                                      */}}
{{/* ------------------------------------------------------------------ */}}
{{- define "helicone.env.dbHost" -}}
- name: DB_HOST
  value: {{ printf "%s-postgresql" .Release.Name | quote }}
{{- end -}}

{{- define "helicone.env.dbPort" -}}
- name: DB_PORT
  value: "5432"
{{- end -}}

{{- define "helicone.env.dbName" -}}
- name: DB_NAME
  value: {{ .Values.global.postgresql.auth.database | quote }}
{{- end -}}

{{- define "helicone.env.dbUser" -}}
- name: DB_USER
  value: {{ .Values.global.postgresql.auth.username | quote }}
{{- end -}}

{{- define "helicone.env.dbPassword" -}}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: helicone-secrets
      key: postgres-password
{{- end -}}

{{- define "clickhouse.name" -}}
{{ include "helicone.name" . }}-clickhouse
{{- end }}

{{- define "kafka.name" -}}
{{ include "helicone.name" . }}-kafka
{{- end }}

{{- define "redis.name" -}}
{{ include "helicone.name" . }}-redis
{{- end }}

{{- define "helicone.worker.env" -}}
{{ include "helicone.env.dbHost" . }}
{{ include "helicone.env.dbPort" . }}
{{ include "helicone.env.dbName" . }}
{{ include "helicone.env.dbUser" . }}
{{ include "helicone.env.dbPassword" . }}
{{ include "helicone.env.clickhouseUser" . }}
{{ include "helicone.env.clickhouseHost" . }}
{{ include "helicone.env.s3AccessKey" . }}
{{ include "helicone.env.s3SecretKey" . }}
{{ include "helicone.env.s3BucketName" . }}
{{ include "helicone.env.s3Endpoint" . }}
{{ include "helicone.env.datadogEnabled" . }}
{{- end }}

{{- define "helicone.env.betterAuthSecret" -}}
- name: BETTER_AUTH_SECRET
  valueFrom:
    secretKeyRef:
      name: helicone-web-secrets
      key: BETTER_AUTH_SECRET
{{- end }}

{{- define "helicone.env.stripeSecretKey" -}}
- name: STRIPE_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-web-secrets
      key: STRIPE_SECRET_KEY
{{- end }}

{{- define "helicone.env.clickhouseHostDocker" -}}
- name: CLICKHOUSE_HOST_DOCKER
  value: "$(CLICKHOUSE_HOST)"
{{- end }}

{{- define "helicone.env.clickhousePort" -}}
- name: CLICKHOUSE_PORT
  value: "8123"
{{- end }}

{{- define "helicone.env.smtpHost" -}}
- name: SMTP_HOST
  value: "helicone-mailhog"
{{- end }}

{{- define "helicone.env.smtpPort" -}}
- name: SMTP_PORT
  value: "1025"
{{- end }}

{{- define "helicone.env.smtpSecure" -}}
- name: SMTP_SECURE
  value: "false"
{{- end }}

{{- define "helicone.env.nodeEnv" -}}
- name: NODE_ENV
  value: "development"
{{- end }}

{{- define "helicone.env.vercelEnv" -}}
- name: VERCEL_ENV
  value: "development"
{{- end }}

{{- define "helicone.env.nextPublicBetterAuth" -}}
- name: NEXT_PUBLIC_BETTER_AUTH
  value: "true"
{{- end }}

{{- define "helicone.env.s3ForcePathStyle" -}}
- name: S3_FORCE_PATH_STYLE
  value: "true"
{{- end }}

{{- define "helicone.env.azureApiKey" -}}
- name: AZURE_API_KEY
  value: "anything"
{{- end }}

{{- define "helicone.env.azureApiVersion" -}}
- name: AZURE_API_VERSION
  value: "anything"
{{- end }}

{{- define "helicone.env.azureDeploymentName" -}}
- name: AZURE_DEPLOYMENT_NAME
  value: "anything"
{{- end }}

{{- define "helicone.env.azureBaseUrl" -}}
- name: AZURE_BASE_URL
  value: "anything"
{{- end }}

{{- define "helicone.env.openaiApiKey" -}}
- name: OPENAI_API_KEY
  value: "sk-"
{{- end }}

{{- define "helicone.env.enablePromptSecurity" -}}
- name: ENABLE_PROMPT_SECURITY
  value: "false"
{{- end }}

{{- define "helicone.env.supabaseUrl" -}}
- name: SUPABASE_URL
  value: "http://helicone-postgresql:5432"
{{- end }}

{{- define "helicone.env.supabaseDatabaseUrl" -}}
- name: SUPABASE_DATABASE_URL
  value: "postgres://postgres:$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%20search_path%3Dpublic,extensions"
{{- end }}

{{- define "helicone.env.enableCronJob" -}}
- name: ENABLE_CRON_JOB
  value: "true"
{{- end }}

{{- define "helicone.env.databaseUrl" -}}
- name: DATABASE_URL
  value: "postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%20search_path%3Dpublic,extensions"
{{- end }}

{{- define "helicone.env.env" -}}
- name: ENV
  value: "development"
{{- end }}
