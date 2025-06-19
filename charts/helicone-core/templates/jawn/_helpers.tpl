{{- define "jawn.name" -}}
{{ include "helicone.name" . }}-jawn
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helicone.jawn.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jawn.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

# TODO Break this down further into smaller templates.
{{ define "helicone.jawn.env" -}}
{{- include "helicone.env.clickhouseHost" . | nindent 12 }}
{{- include "helicone.env.clickhouseUser" . | nindent 12 }}
{{- include "helicone.env.dbHost" . | nindent 12 }}
{{- include "helicone.env.dbPort" . | nindent 12 }}
{{- include "helicone.env.dbUser" . | nindent 12 }}
{{- include "helicone.env.dbPassword" . | nindent 12 }}
{{- include "helicone.env.dbName" . | nindent 12 }}
{{- include "helicone.env.s3AccessKey" . | nindent 12 }}
{{- include "helicone.env.s3SecretKey" . | nindent 12 }}
{{- include "helicone.env.s3BucketName" . | nindent 12 }}
{{- include "helicone.env.s3Endpoint" . | nindent 12 }}
{{- include "helicone.env.betterAuthSecret" . | nindent 12 }}
{{- include "helicone.env.betterAuthUrl" . | nindent 12 }}
{{- include "helicone.env.betterAuthTrustedOrigins" . | nindent 12 }}
{{- include "helicone.env.stripeSecretKey" . | nindent 12 }}
{{- include "helicone.env.azureApiKey" . | nindent 12 }}
{{- include "helicone.env.azureApiVersion" . | nindent 12 }}
{{- include "helicone.env.azureDeploymentName" . | nindent 12 }}
{{- include "helicone.env.azureBaseUrl" . | nindent 12 }}
{{- include "helicone.env.openaiApiKey" . | nindent 12 }}
{{- include "helicone.env.enablePromptSecurity" . | nindent 12 }}
{{- include "helicone.env.supabaseUrl" . | nindent 12 }}
{{- include "helicone.env.supabaseDatabaseUrl" . | nindent 12 }}
{{- include "helicone.env.enableCronJob" . | nindent 12 }}
{{- include "helicone.env.databaseUrl" . | nindent 12 }}
{{- include "helicone.env.env" . | nindent 12 }}
{{- include "helicone.env.nextPublicBetterAuth" . | nindent 12 }}
{{- end }}