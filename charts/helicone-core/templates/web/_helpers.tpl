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

# TODO Break this down further into smaller templates.
{{- define "helicone.web.env" -}}
{{ include "helicone.env.clickhouseUrl" . }}
{{ include "helicone.env.clickhouseUser" . }}
{{ include "helicone.env.clickhousePassword" . }}
{{ include "helicone.env.dbHost" . }}
{{ include "helicone.env.dbPort" . }}
{{ include "helicone.env.dbUser" . }}
{{ include "helicone.env.dbPassword" . }}
{{ include "helicone.env.dbName" . }}
{{ include "helicone.env.s3AccessKey" . }}
{{ include "helicone.env.s3SecretKey" . }}
{{ include "helicone.env.s3BucketName" . }}
{{ include "helicone.env.s3Endpoint" . }}
{{ include "helicone.env.betterAuthSecret" . }}
{{ include "helicone.env.betterAuthUrl" . }}
{{ include "helicone.env.siteUrl" . }}
{{ include "helicone.env.betterAuthTrustedOrigins" . }}
{{ include "helicone.env.stripeSecretKey" . }}
{{ include "helicone.env.azureApiKey" . }}
{{ include "helicone.env.azureApiVersion" . }}
{{ include "helicone.env.azureDeploymentName" . }}
{{ include "helicone.env.azureBaseUrl" . }}
{{ include "helicone.env.openaiApiKey" . }}
{{ include "helicone.env.enablePromptSecurity" . }}
{{ include "helicone.env.databaseUrl" . }}
{{ include "helicone.env.enableCronJob" . }}
{{ include "helicone.env.env" . }}
{{ include "helicone.env.nextPublicBetterAuth" . }}
{{ include "helicone.env.smtpHost" . }}
{{ include "helicone.env.smtpPort" . }}
{{ include "helicone.env.smtpSecure" . }}
{{ include "helicone.env.nodeEnv" . }}
{{ include "helicone.env.vercelEnv" . }}
{{ include "helicone.env.s3ForcePathStyle" . }}
{{ include "helicone.env.nextPublicHeliconeJawnService" . }}
{{ include "helicone.env.nextPublicApiBasePath" . }}
{{ include "helicone.env.nextPublicBasePath" . }}
{{ include "helicone.env.dbDriver" . }}
{{ include "helicone.env.dbSsl" . }}
{{ include "helicone.env.nextPublicIsOnPrem" . }}
{{ include "helicone.env.flywayUrl" . }}
{{ include "helicone.env.flywayUser" . }}
{{- end }}
