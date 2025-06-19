{{- define "helicone.name" -}}
{{- $name := default .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
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
  Environment variables and secrets
*/}}
{{- define "helicone.env.clickhouseHost" -}}
- name: CLICKHOUSE_HOST
  value: {{ .Values.helicone.config.clickhouseHost | default (printf "http://%s:8123" (include "clickhouse.name" .)) | quote }}
{{- end }}

{{- define "helicone.env.clickhouseUser" -}}
- name: CLICKHOUSE_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.clickhouseSecretsName | default (printf "%s-secrets" (include "clickhouse.name" .)) | quote }}
      key: {{ .Values.helicone.config.clickhouseUserKey | default "user" | quote }}
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

{{- define "helicone.env.s3SecretKey" -}}
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

{{- define "helicone.env.s3Endpoint" -}}
- name: S3_ENDPOINT
{{- if .Values.helicone.minio.enabled }}
  value: {{ .Values.helicone.config.s3Endpoint | default (printf "http://%s:%s" (include "minio.name" .) (.Values.helicone.minio.service.port | toString)) | quote }}
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
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.s3SecretsName | default "helicone-secrets" | quote }}
      key: {{ .Values.helicone.config.s3BucketNameKey | default "bucket_name" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.dbHost" -}}
- name: DB_HOST
{{- if .Values.global.postgresql.enabled }}
  value: {{ .Values.helicone.config.dbHost | default (printf "%s-postgresql" .Release.Name) | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.dbSecretsName | default "aurora-postgres-credentials" | quote }}
      key: {{ .Values.helicone.config.dbHostKey | default "host" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.dbPort" -}}
- name: DB_PORT
{{- if .Values.global.postgresql.enabled }}
  value: {{ .Values.helicone.config.dbPort | default "5432" | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.helicone.config.dbSecretsName | default "aurora-postgres-credentials" | quote }}
      key: {{ .Values.helicone.config.dbPortKey | default "port" | quote }}
{{- end }}
{{- end }}

{{- define "helicone.env.dbName" -}}
- name: DB_NAME
{{- if .Values.global.postgresql.enabled }}
  value: {{ .Values.helicone.config.dbName | default .Values.global.postgresql.auth.database | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: aurora-postgres-credentials
      key: database
{{- end }}
{{- end }}

{{- define "helicone.env.dbUser" -}}
- name: DB_USER
{{- if .Values.global.postgresql.enabled }}
  value: {{ .Values.global.postgresql.auth.username | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: aurora-postgres-credentials
      key: username
{{- end }}
{{- end }}

{{- define "helicone.env.dbPassword" -}}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
{{- if .Values.global.postgresql.enabled }}
      name: helicone-secrets
      key: postgres-password
{{- else }}
      name: aurora-postgres-credentials
      key: password
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


{{- define "helicone.env.supabaseUrl" -}}
- name: SUPABASE_URL
  value: {{ .Values.helicone.config.supabaseUrl | default "http://helicone-postgresql:5432" | quote }}
{{- end }}

{{- define "helicone.env.databaseUrl" -}}
- name: DATABASE_URL
  value: {{ .Values.helicone.config.databaseUrl | default "postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%20search_path%3Dpublic,extensions" | quote }}
{{- end }}

# TODO This is tech debt as a result of Jawn still having the Supabase database url in the config.
{{- define "helicone.env.supabaseDatabaseUrl" -}}
- name: SUPABASE_DATABASE_URL
  value: {{ .Values.helicone.config.supabaseDatabaseUrl | default "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%20search_path%3Dpublic,extensions" | quote }}
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

# TODO Move these definitions to the web chart (and refactor accordingly).
{{- define "helicone.env.siteUrl" -}}
- name: SITE_URL
  value: {{ .Values.helicone.config.siteUrl | default "https://heliconetest.com" | quote }}
{{- end }}

{{- define "helicone.env.helixProxyHeliconeApiKey" -}}
- name: PROXY__HELICONE__API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-helix-secrets
      key: proxy_helicone_api_key
{{- end }}

# TODO It doesn't make sense for the API keys of the LLMs to be defined separately for helix.
{{- define "helicone.env.helixOpenaiApiKey" -}}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-helix-secrets
      key: openai_api_key
{{- end }}

{{- define "helicone.env.helixAnthropicApiKey" -}}
- name: ANTHROPIC_API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-helix-secrets
      key: anthropic_api_key
{{- end }}

{{- define "helicone.env.helixGeminiApiKey" -}}
- name: GEMINI_API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-helix-secrets
      key: gemini_api_key
{{- end }}

{{- define "helicone.env.helixHeliconeApiKey" -}}
- name: HELICONE_API_KEY
  valueFrom:
    secretKeyRef:
      name: helicone-helix-secrets
      key: helicone_api_key
{{- end }}

{{- define "helicone.env.flywayUrl" -}}
- name: FLYWAY_URL
  value: {{ .Values.helicone.config.flywayUrl | default "jdbc:postgresql://$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%20search_path%3Dpublic,extensions" | quote }}
{{- end }}

{{- define "helicone.env.flywayUser" -}}
- name: FLYWAY_USER
  value: {{ .Values.helicone.config.flywayUser | default "postgres" | quote }}
{{- end }}

{{- define "helicone.env.flywayPassword" -}}
- name: FLYWAY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: helicone-secrets
      key: postgres-password
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

{{- define "helicone.env.databaseUrlComposed" -}}
- name: DATABASE_URL
  value: "postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSL)&options=-c%20search_path%3Dpublic,extensions"
{{- end }}

{{- define "helicone.env.nextPublicIsOnPrem" -}}
- name: NEXT_PUBLIC_IS_ON_PREM
  value: "true"
{{- end }}