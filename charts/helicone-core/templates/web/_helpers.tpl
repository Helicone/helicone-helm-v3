{{- define "web.name" -}}
{{ include "helicone.name" . }}-web
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helicone.web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

# {{/*
# Web deployment specific environment variables
# */}}
# {{- define "helicone.env.nextPublicHeliconeJawnService" -}}
# - name: NEXT_PUBLIC_HELICONE_JAWN_SERVICE
#   value: {{ .Values.helicone.jawn.publicUrl | quote }}
# {{- end }}

# {{- define "helicone.env.nextPublicApiBasePath" -}}
# - name: NEXT_PUBLIC_API_BASE_PATH
#   value: "/api2"
# {{- end }}

# {{- define "helicone.env.nextPublicBasePath" -}}
# - name: NEXT_PUBLIC_BASE_PATH
#   value: "/api2/v1"
# {{- end }}

# {{- define "helicone.env.dbDriver" -}}
# - name: DB_DRIVER
#   value: "postgres"
# {{- end }}

# {{- define "helicone.env.dbSsl" -}}
# - name: DB_SSL
#   value: "disable"
# {{- end }}

# {{- define "helicone.env.databaseUrlComposed" -}}
# - name: DATABASE_URL
#   value: "postgresql://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSL)&options=-c%20search_path%3Dpublic,extensions"
# {{- end }}

# {{- define "helicone.env.nextPublicIsOnPrem" -}}
# - name: NEXT_PUBLIC_IS_ON_PREM
#   value: "true"
# {{- end }}

# # TODO Break this down further into smaller templates.
# {{- define "helicone.web.env" -}}
# {{ include "helicone.env.clickhouseHost" . }}
# {{ include "helicone.env.clickhouseHostDocker" . }}
# {{ include "helicone.env.clickhouseUser" . }}
# {{ include "helicone.env.dbHost" . }}
# {{ include "helicone.env.dbPort" . }}
# {{ include "helicone.env.dbUser" . }}
# {{ include "helicone.env.dbPassword" . }}
# {{ include "helicone.env.dbName" . }}
# {{ include "helicone.env.s3AccessKey" . }}
# {{ include "helicone.env.s3SecretKey" . }}
# {{ include "helicone.env.s3BucketName" . }}
# {{ include "helicone.env.s3Endpoint" . }}
# {{ include "helicone.env.betterAuthSecret" . }}
# {{ include "helicone.env.betterAuthUrl" . }}
# {{ include "helicone.env.betterAuthTrustedOrigins" . }}
# {{ include "helicone.env.stripeSecretKey" . }}
# {{ include "helicone.env.azureApiKey" . }}
# {{ include "helicone.env.azureApiVersion" . }}
# {{ include "helicone.env.azureDeploymentName" . }}
# {{ include "helicone.env.azureBaseUrl" . }}
# {{ include "helicone.env.openaiApiKey" . }}
# {{ include "helicone.env.enablePromptSecurity" . }}
# {{ include "helicone.env.supabaseUrl" . }}
# {{ include "helicone.env.supabaseDatabaseUrl" . }}
# {{ include "helicone.env.databaseUrl" . }}
# {{ include "helicone.env.enableCronJob" . }}
# {{ include "helicone.env.env" . }}
# {{ include "helicone.env.nextPublicBetterAuth" . }}
# {{ include "helicone.env.clickhousePort" . }}
# {{ include "helicone.env.smtpHost" . }}
# {{ include "helicone.env.smtpPort" . }}
# {{ include "helicone.env.smtpSecure" . }}
# {{ include "helicone.env.nodeEnv" . }}
# {{ include "helicone.env.vercelEnv" . }}
# {{ include "helicone.env.s3ForcePathStyle" . }}
# {{ include "helicone.env.nextPublicHeliconeJawnService" . }}
# {{ include "helicone.env.nextPublicApiBasePath" . }}
# {{ include "helicone.env.nextPublicBasePath" . }}
# {{ include "helicone.env.dbDriver" . }}
# {{ include "helicone.env.dbSsl" . }}
# {{ include "helicone.env.databaseUrlComposed" . }}
# {{ include "helicone.env.nextPublicIsOnPrem" . }}
# {{- end }}