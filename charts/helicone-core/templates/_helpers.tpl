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
# TODO This should probably be grouped with the selector label template or some other template.

app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
  Environment variables and secrets
*/}}
{{- define "helicone.env.clickhouseHost" -}}
- name: CLICKHOUSE_HOST
  value: "http://{{ include "clickhouse.name" . }}:8123"
{{- end -}}

{{- define "helicone.env.clickhouseUser" -}}
- name: CLICKHOUSE_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "clickhouse.name" . }}-secrets
      key: user
{{- end -}}

{{- define "s3.name" -}}
  {{ include "helicone.name" . }}-s3
{{- end }}


# TODO Make this configurable
{{- define "helicone.env.betterAuthTrustedOrigins" -}}
- name: BETTER_AUTH_TRUSTED_ORIGINS
  value: "https://heliconetest.com,http://heliconetest.com"
{{- end }}

{{/*
  Minio and S3 logic
*/}}
# TODO This conditional logic will incur tech debt which needs to be refactored.
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

{{- define "helicone.env.dbHost" -}}
- name: DB_HOST
{{- if .Values.postgresql.enabled }}
  value: {{ printf "%s-postgresql" .Release.Name | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: aurora-postgres-credentials
      key: host
{{- end }}
{{- end -}}

{{- define "helicone.env.dbPort" -}}
- name: DB_PORT
{{- if .Values.postgresql.enabled }}
  value: "5432"
{{- else }}
  valueFrom:
    secretKeyRef:
      name: aurora-postgres-credentials
      key: port
{{- end }}
{{- end -}}

{{- define "helicone.env.dbName" -}}
- name: DB_NAME
{{- if .Values.postgresql.enabled }}
  value: {{ .Values.global.postgresql.auth.database | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: aurora-postgres-credentials
      key: database
{{- end }}
{{- end -}}

{{- define "helicone.env.dbUser" -}}
- name: DB_USER
{{- if .Values.postgresql.enabled }}
  value: {{ .Values.global.postgresql.auth.username | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
      name: aurora-postgres-credentials
      key: username
{{- end }}
{{- end -}}

{{- define "helicone.env.dbPassword" -}}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
{{- if .Values.postgresql.enabled }}
      name: helicone-secrets
      key: postgres-password
{{- else }}
      name: aurora-postgres-credentials
      key: password
{{- end }}
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
  value: {{ .Values.helicone.config.openaiApiKey | default "sk-" | quote }}
{{- end }}

{{- define "helicone.env.enablePromptSecurity" -}}
- name: ENABLE_PROMPT_SECURITY
  value: {{ .Values.helicone.config.enablePromptSecurity | default false | quote }}
{{- end }}


# TODO This is a temporary solution to get the supabase url working. It will incur tech debt if we don't refactor to support other types of connection strings that don't end with postgresql.
{{- define "helicone.env.supabaseUrl" -}}
- name: SUPABASE_URL
  value: "http://{{ printf "%s-postgresql" .Release.Name }}:5432"
{{- end }}

# TODO This is tech debt as a result of jawn still having the 
{{- define "helicone.env.supabaseDatabaseUrl" -}}
- name: SUPABASE_DATABASE_URL
  value: "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%20search_path%3Dpublic,extensions"
{{- end }}

{{- define "helicone.env.enableCronJob" -}}
- name: ENABLE_CRON_JOB
  value: "true"
{{- end }}

# TODO This is a temporary solution to get the supabase database url working. It will incur tech debt if we don't refactor to support other types of connection strings.
{{- define "helicone.env.databaseUrl" -}}
- name: DATABASE_URL
  value: "postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable&options=-c%20search_path%3Dpublic,extensions"
{{- end }}

# TODO Not sure why this is needed within any of the deployments.
{{- define "helicone.env.env" -}}
- name: ENV
  value: "development"
{{- end }}

{{- define "helicone.env.betterAuthUrl" -}}
- name: BETTER_AUTH_URL
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
