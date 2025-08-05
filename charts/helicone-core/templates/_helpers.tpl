{{- define "helicone.name" -}}
{{- $name := default .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
AI Gateway specific naming
*/}}
{{- define "helicone.ai-gateway.name" -}}
{{ include "helicone.name" . }}-ai-gateway
{{- end }}

{{/*
AI Gateway selector labels
*/}}
{{- define "helicone.ai-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.ai-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

# TODO Place the correct environment variables in the correct location. This requires refactoring the other charts as well.
# - Move to other helpers.tpl files and refactor accordingly.

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
Labels
*/}}
{{- define "helicone.labels" -}}
helm.sh/chart: {{ include "helicone.chart" . }}
{{ include "helicone.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}

app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Helm annotations
*/}}
{{- define "helicone.annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- end }}

{{/*
  Environment variables and secrets
*/}}
{{/*
ClickHouse hostname for migration scripts (just hostname, no protocol/port)
*/}}
{{- define "helicone.env.clickhouseHost" -}}
- name: CLICKHOUSE_HOST
{{- if .Values.helicone.clickhouse.enabled }}
  value: {{ include "clickhouse.name" . | quote }}
{{- else }}
{{- $url := .Values.helicone.config.externalClickhouseUrl | default .Values.helicone.config.clickhouseHost | required "When clickhouse.enabled is false, either helicone.config.externalClickhouseUrl or helicone.config.clickhouseHost must be provided" }}
{{- $hostname := $url | replace "https://" "" | replace "http://" "" }}
  value: {{ $hostname | quote }}
{{- end }}
{{- end }}

{{/*
ClickHouse URL for application clients (full URL with protocol and port)
*/}}
{{- define "helicone.env.clickhouseUrl" -}}
- name: CLICKHOUSE_URL
{{- if .Values.helicone.clickhouse.enabled }}
  value: {{ printf "http://%s:8123" (include "clickhouse.name" .) | quote }}
{{- else }}
  value: {{ .Values.helicone.config.externalClickhouseUrl | default .Values.helicone.config.clickhouseHost | required "When clickhouse.enabled is false, either helicone.config.externalClickhouseUrl or helicone.config.clickhouseHost must be provided" | quote }}
{{- end }}
{{- end }}

{{/*
ClickHouse host for Jawn application (URL format for Node.js client)
*/}}
{{- define "helicone.env.clickhouseHostForJawn" -}}
- name: CLICKHOUSE_HOST
{{- if .Values.helicone.clickhouse.enabled }}
  value: {{ printf "http://%s:8123" (include "clickhouse.name" .) | quote }}
{{- else }}
  value: {{ .Values.helicone.config.externalClickhouseUrl | default .Values.helicone.config.clickhouseHost | required "When clickhouse.enabled is false, either helicone.config.externalClickhouseUrl or helicone.config.clickhouseHost must be provided" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.clickhouseUser" -}}
- name: CLICKHOUSE_USER
{{- if .Values.helicone.clickhouse.enabled }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.clickhouseSecretsName | default (printf "%s-secrets" (include "clickhouse.name" .)) | quote }}
      key: {{ .Values.helicone.config.clickhouseUserKey | default "user" | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.externalClickhouseSecretName | default "helicone-external-clickhouse-secrets" | quote }}
      key: {{ .Values.helicone.config.externalClickhouseUsernameKey | default "username" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.clickhousePassword" -}}
{{- if not .Values.helicone.clickhouse.enabled }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.externalClickhouseSecretName | default "helicone-external-clickhouse-secrets" | quote }}
      key: {{ .Values.helicone.config.externalClickhousePasswordKey | default "password" | quote }}
{{- end }}
{{- end }}

{{- define "s3.name" -}}
  {{ include "helicone.name" . }}-s3
{{- end }}


{{- define "helicone.env.betterAuthTrustedOrigins" -}}
- name: BETTER_AUTH_TRUSTED_ORIGINS
  value: {{ .Values.helicone.config.betterAuthTrustedOrigins | default "https://heliconetest.com,http://heliconetest.com" | quote }}
{{- end }}

{{/*
  Minio and S3 logic
*/}}
# TODO This conditional logic will incur tech debt which needs to be refactored.
{{- define "helicone.env.s3AccessKey" -}}
{{- if not (and .Values.helicone.s3 .Values.helicone.s3.serviceAccount .Values.helicone.s3.serviceAccount.enabled) }}
- name: S3_ACCESS_KEY
{{- if .Values.helicone.minio.enabled }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.minioSecretsName | default "helicone-minio-secrets" | quote }}
      key: {{ .Values.helicone.config.minioAccessKeyKey | default "root_user" | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.s3SecretsName | default "helicone-secrets" | quote }}
      key: {{ .Values.helicone.config.s3AccessKeyKey | default "access_key" | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "helicone.env.s3SecretKey" -}}
{{- if not (and .Values.helicone.s3 .Values.helicone.s3.serviceAccount .Values.helicone.s3.serviceAccount.enabled) }}
- name: S3_SECRET_KEY
{{- if .Values.helicone.minio.enabled }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.minioSecretsName | default "helicone-minio-secrets" | quote }}
      key: {{ .Values.helicone.config.minioSecretKeyKey | default "root_password" | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.s3SecretsName | default "helicone-secrets" | quote }}
      key: {{ .Values.helicone.config.s3SecretKeyKey | default "secret_key" | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "helicone.env.s3Endpoint" -}}
- name: S3_ENDPOINT
{{- if .Values.helicone.minio.enabled }}
  value: {{ .Values.helicone.config.s3Endpoint | default (printf "http://%s:%s" (include "minio.name" .) (.Values.helicone.minio.service.port | toString)) | quote }}
{{- else if and .Values.helicone.s3 .Values.helicone.s3.serviceAccount .Values.helicone.s3.serviceAccount.enabled }}
  value: {{ .Values.helicone.s3.endpoint | default "https://s3.amazonaws.com" | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.s3SecretsName | default "helicone-secrets" | quote }}
      key: {{ .Values.helicone.config.s3EndpointKey | default "endpoint" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.s3BucketName" -}}
- name: S3_BUCKET_NAME
{{- if .Values.helicone.minio.enabled }}
  value: {{ .Values.helicone.config.s3BucketName | default (index .Values.helicone.minio.setup.buckets 0) | quote }}
{{- else if and .Values.helicone.s3 .Values.helicone.s3.serviceAccount .Values.helicone.s3.serviceAccount.enabled }}
  value: {{ .Values.helicone.s3.bucketName | default "helm-request-response-storage" | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.s3SecretsName | default "helicone-secrets" | quote }}
      key: {{ .Values.helicone.config.s3BucketNameKey | default "bucket_name" | quote }}
{{- end }}
{{- end }}

{{- define "clickhouse.name" -}}
{{ include "helicone.name" . }}-clickhouse
{{- end }}

{{- define "kafka.name" -}}
{{ include "helicone.name" . }}-kafka
{{- end }}

{{- define "redis.name" -}}
{{ include "helicone.name" . }}-redis
{{- end }}

{{- define "minio.name" -}}
{{ include "helicone.name" . }}-minio
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

{{- define "helicone.env.dbHost" -}}
- name: DB_HOST
{{- if .Values.helicone.cloudnativepg.enabled }}
  value: {{ printf "%s-rw" .Values.helicone.cloudnativepg.cluster.name | quote }}
{{- else if .Values.helicone.web.cloudSqlProxy.enabled }}
  value: "localhost"
{{- else }}
  value: {{ .Values.helicone.config.dbHost | required "When cloudnativepg.enabled is false, helicone.config.dbHost must be provided" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.dbPort" -}}
- name: DB_PORT
{{- if .Values.helicone.web.cloudSqlProxy.enabled }}
  value: {{ include "helicone.cloudSqlProxy.port" . | quote }}
{{- else }}
  value: {{ .Values.helicone.config.dbPort | default "5432" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.dbName" -}}
- name: DB_NAME
{{- if .Values.helicone.cloudnativepg.enabled }}
  value: {{ .Values.helicone.cloudnativepg.cluster.bootstrap.initdb.database | quote }}
{{- else }}
  value: {{ .Values.helicone.config.dbName | required "When cloudnativepg.enabled is false, helicone.config.dbName must be provided" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.dbUser" -}}
- name: DB_USER
{{- if .Values.helicone.cloudnativepg.enabled }}
  value: {{ .Values.helicone.cloudnativepg.cluster.bootstrap.initdb.owner | quote }}
{{- else }}
  value: {{ .Values.helicone.config.dbUser | required "When cloudnativepg.enabled is false, helicone.config.dbUser must be provided" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.dbPassword" -}}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
{{- if .Values.helicone.cloudnativepg.enabled }}
      name: helicone-app-credentials
      key: password
{{- else }}
      name: {{ .Values.helicone.config.dbPasswordSecretName | default "postgres-credentials" | quote }}
      key: {{ .Values.helicone.config.dbPasswordSecretKey | default "password" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.db.connectionString" -}}
{{- if .Values.helicone.cloudnativepg.enabled }}
{{- printf "%s:$(DB_PASSWORD)@%s-rw:$(DB_PORT)/%s?sslmode=disable&options=-c%%20search_path%%3Dpublic,extensions" .Values.helicone.cloudnativepg.cluster.bootstrap.initdb.owner .Values.helicone.cloudnativepg.cluster.name .Values.helicone.cloudnativepg.cluster.bootstrap.initdb.database }}
{{- else if .Values.helicone.web.cloudSqlProxy.enabled }}
{{- printf "$(DB_USER):$(DB_PASSWORD)@localhost:%s/$(DB_NAME)?sslmode=disable&options=-c%%20search_path%%3Dpublic,extensions" (include "helicone.cloudSqlProxy.port" .) }}
{{- else }}
{{- printf "$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%%20search_path%%3Dpublic,extensions" }}
{{- end }}
{{- end }}

{{- define "helicone.env.databaseUrl" -}}
- name: DATABASE_URL
{{- if .Values.helicone.cloudnativepg.enabled }}
  value: {{ printf "postgresql://%s" (include "helicone.db.connectionString" .) | quote }}
{{- else }}
  value: {{ .Values.helicone.config.databaseUrl | default (printf "postgresql://%s" (include "helicone.db.connectionString" .)) | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.flywayUrl" -}}
- name: FLYWAY_URL
{{- if .Values.helicone.cloudnativepg.enabled }}
  value: {{ printf "jdbc:postgresql://%s-rw:5432/%s?sslmode=disable&options=-c%%20search_path%%3Dpublic,extensions" .Values.helicone.cloudnativepg.cluster.name .Values.helicone.cloudnativepg.cluster.bootstrap.initdb.database | quote }}
{{- else if .Values.helicone.web.cloudSqlProxy.enabled }}
  value: {{ printf "jdbc:postgresql://localhost:%s/$(DB_NAME)?sslmode=disable&options=-c%%20search_path%%3Dpublic,extensions" (include "helicone.cloudSqlProxy.port" .) | quote }}
{{- else }}
  value: {{ .Values.helicone.config.flywayUrl | default (printf "jdbc:postgresql://$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%%20search_path%%3Dpublic,extensions") | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.flywayUser" -}}
- name: FLYWAY_USER
{{- if .Values.helicone.cloudnativepg.enabled }}
  value: {{ .Values.helicone.cloudnativepg.cluster.bootstrap.initdb.owner | quote }}
{{- else }}
  value: {{ .Values.helicone.config.dbUser | required "When cloudnativepg.enabled is false, helicone.config.dbUser must be provided" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.flywayPassword" -}}
- name: FLYWAY_PASSWORD
  valueFrom:
    secretKeyRef:
{{- if .Values.helicone.cloudnativepg.enabled }}
      name: helicone-app-credentials
      key: password
{{- else }}
      name: {{ .Values.helicone.config.dbPasswordSecretName | default "postgres-credentials" | quote }}
      key: {{ .Values.helicone.config.dbPasswordSecretKey | default "password" | quote }}
{{- end }}
{{- end }}

# Supabase environment variables are tech debt as a result of Jawn still having the Supabase database url in the config.
{{- define "helicone.env.supabaseUrl" -}}
- name: SUPABASE_URL
  value: "http://$(DB_HOST):$(DB_PORT)"
{{- end }}

{{- define "helicone.env.supabaseDatabaseUrl" -}}
- name: SUPABASE_DATABASE_URL
  value: "$(DATABASE_URL)"
{{- end }}

{{- define "helicone.env.clickhouseHostDocker" -}}
- name: CLICKHOUSE_HOST_DOCKER
  value: "$(CLICKHOUSE_URL)"
{{- end }}

{{- define "helicone.env.clickhousePort" -}}
- name: CLICKHOUSE_PORT
{{- if .Values.helicone.clickhouse.enabled }}
  value: "8123"
{{- else }}
  value: {{ .Values.helicone.config.externalClickhousePort | default .Values.helicone.config.clickhousePort | required "When clickhouse.enabled is false, either helicone.config.externalClickhousePort or helicone.config.clickhousePort must be provided" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.smtpHost" -}}
- name: SMTP_HOST
  value: "helicone-mailhog"
{{- end }}

# TODO Move these into the same template such that they can be grouped together (define and include).
{{- define "helicone.env.smtpPort" -}}
- name: SMTP_PORT
  value: {{ .Values.helicone.config.smtpPort | default "1025" | quote }}
{{- end }}

{{- define "helicone.env.smtpSecure" -}}
- name: SMTP_SECURE
  value: {{ .Values.helicone.config.smtpSecure | default "false" | quote }}
{{- end }}

{{- define "helicone.env.nodeEnv" -}}
- name: NODE_ENV
  value: {{ .Values.helicone.config.nodeEnv | default "development" | quote }}
{{- end }}

{{- define "helicone.env.vercelEnv" -}}
- name: VERCEL_ENV
  value: {{ .Values.helicone.config.vercelEnv | default "development" | quote }}
{{- end }}

{{- define "helicone.env.nextPublicBetterAuth" -}}
- name: NEXT_PUBLIC_BETTER_AUTH
  value: {{ .Values.helicone.config.nextPublicBetterAuth | default "true" | quote }}
{{- end }}

{{- define "helicone.env.s3ForcePathStyle" -}}
- name: S3_FORCE_PATH_STYLE
  value: {{ .Values.helicone.config.s3ForcePathStyle | default "true" | quote }}
{{- end }}

{{- define "helicone.env.azureApiKey" -}}
- name: AZURE_API_KEY
  value: {{ .Values.helicone.config.azureApiKey | default "anything" | quote }}
{{- end }}

{{- define "helicone.env.azureApiVersion" -}}
- name: AZURE_API_VERSION
  value: {{ .Values.helicone.config.azureApiVersion | default "anything" | quote }}
{{- end }}

{{- define "helicone.env.azureDeploymentName" -}}
- name: AZURE_DEPLOYMENT_NAME
  value: {{ .Values.helicone.config.azureDeploymentName | default "anything" | quote }}
{{- end }}

{{- define "helicone.env.azureBaseUrl" -}}
- name: AZURE_BASE_URL
  value: {{ .Values.helicone.config.azureBaseUrl | default "anything" | quote }}
{{- end }}

{{- define "helicone.env.openaiApiKey" -}}
- name: OPENAI_API_KEY
  value: {{ .Values.helicone.config.openaiApiKey | default "sk-" | quote }}
{{- end }}

{{- define "helicone.env.enablePromptSecurity" -}}
- name: ENABLE_PROMPT_SECURITY
  value: {{ .Values.helicone.config.enablePromptSecurity | default "false" | quote }}
{{- end }}

{{- define "helicone.env.enableCronJob" -}}
- name: ENABLE_CRON_JOB
  value: {{ .Values.helicone.config.enableCronJob | default "true" | quote }}
{{- end }}


{{- define "helicone.env.env" -}}
- name: ENV
  value: {{ .Values.helicone.config.env | default "development" | quote }}
{{- end }}

{{- define "helicone.env.betterAuthUrl" -}}
- name: BETTER_AUTH_URL
  value: {{ .Values.helicone.config.siteUrl | default "https://heliconetest.com" | quote }}
{{- end }}

{{/*
Cloud SQL Auth Proxy helpers
*/}}
{{- define "helicone.cloudSqlProxy.enabled" -}}
{{- .Values.helicone.web.cloudSqlProxy.enabled -}}
{{- end }}

{{- define "helicone.cloudSqlProxy.connectionName" -}}
{{- .Values.helicone.web.cloudSqlProxy.connectionName | required "When cloudSqlProxy.enabled is true, connectionName must be provided" -}}
{{- end }}

{{- define "helicone.cloudSqlProxy.port" -}}
{{- .Values.helicone.web.cloudSqlProxy.port | default 5432 -}}
{{- end }}

{{- define "helicone.cloudSqlProxy.image" -}}
{{- printf "%s:%s" .Values.helicone.web.cloudSqlProxy.image.repository .Values.helicone.web.cloudSqlProxy.image.tag -}}
{{- end }}

{{- define "helicone.cloudSqlProxy.args" -}}
{{- $args := list -}}
{{- $args = append $args (printf "-instances=%s=tcp:0.0.0.0:%d" (include "helicone.cloudSqlProxy.connectionName" .) (include "helicone.cloudSqlProxy.port" . | int)) -}}
{{- if not .Values.helicone.web.cloudSqlProxy.useWorkloadIdentity -}}
{{- $args = append $args "-credential_file=/secrets/cloudsql/key.json" -}}
{{- end -}}
{{- range .Values.helicone.web.cloudSqlProxy.extraArgs -}}
{{- $args = append $args . -}}
{{- end -}}
{{- $args | toJson -}}
{{- end }}

# TODO Move these definitions to the web chart (and refactor accordingly).
{{- define "helicone.env.siteUrl" -}}
- name: SITE_URL
  value: {{ .Values.helicone.config.siteUrl | default "https://heliconetest.com" | quote }}
{{- end }}

# TODO It doesn't make sense for the API keys of the LLMs to be defined separately for ai-gateway.
{{- define "helicone.env.aiGatewayOpenaiApiKey" -}}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-ai-gateway-secrets
      key: openai_api_key
{{- end }}

{{- define "helicone.env.aiGatewayAnthropicApiKey" -}}
- name: ANTHROPIC_API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-ai-gateway-secrets
      key: anthropic_api_key
{{- end }}

{{- define "helicone.env.aiGatewayGeminiApiKey" -}}
- name: GEMINI_API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-ai-gateway-secrets
      key: gemini_api_key
{{- end }}

{{- define "helicone.env.aiGatewayHeliconeApiKey" -}}
- name: HELICONE_API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-ai-gateway-secrets
      key: helicone_api_key
{{- end }}

{{/*
Web deployment specific environment variables
*/}}
{{- define "helicone.env.nextPublicHeliconeJawnService" -}}
- name: NEXT_PUBLIC_HELICONE_JAWN_SERVICE
  value: {{ .Values.helicone.jawn.publicUrl | quote }}
{{- end }}

{{- define "helicone.env.nextPublicApiBasePath" -}}
- name: NEXT_PUBLIC_API_BASE_PATH
  value: "/api2"
{{- end }}

{{- define "helicone.env.nextPublicBasePath" -}}
- name: NEXT_PUBLIC_BASE_PATH
  value: "/api2/v1"
{{- end }}

{{- define "helicone.env.dbDriver" -}}
- name: DB_DRIVER
  value: "postgres"
{{- end }}

{{- define "helicone.env.dbSsl" -}}
- name: DB_SSL
  value: "disable"
{{- end }}

{{- define "helicone.env.nextPublicIsOnPrem" -}}
- name: NEXT_PUBLIC_IS_ON_PREM
  value: "true"
{{- end }}