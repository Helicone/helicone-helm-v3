{{- define "helicone.name" -}}
{{- $name := default .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "helicone.ai-gateway.name" -}}
{{ include "helicone.name" . }}
{{- end }}

{{/*
Service Account name
*/}}
{{- define "helicone.ai-gateway.serviceAccountName" -}}
{{- if .Values.aiGateway.serviceAccount.enabled }}
{{- .Values.aiGateway.serviceAccount.name | default (include "helicone.ai-gateway.name" .) }}
{{- else }}
{{- "default" }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helicone.ai-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.ai-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
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
Annotations
*/}}
{{- define "helicone.annotations" -}}
{{- if .Values.global }}
{{- if .Values.global.annotations }}
{{- toYaml .Values.global.annotations }}
{{- end }}
{{- end }}
{{- end }}

{{- define "helicone.ai-gateway.env" -}}
- name: AI_GATEWAY__DATABASE__URL
  valueFrom:
    secretKeyRef:
      name: ai-gateway-secrets
      key: {{ if .Values.externalSecrets.enabled }}db_url{{ else }}dbUrl{{ end }}
- name: PGSSLROOTCERT
  valueFrom:
    secretKeyRef:
      name: ai-gateway-secrets
      key: {{ if .Values.externalSecrets.enabled }}db_cert{{ else }}dbCert{{ end }}
- name: AI_GATEWAY__MINIO__ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: ai-gateway-secrets
      key: {{ if .Values.externalSecrets.enabled }}minio_access_key{{ else }}aiGwS3AccessKey{{ end }}
- name: AI_GATEWAY__MINIO__SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: ai-gateway-secrets
      key: {{ if .Values.externalSecrets.enabled }}minio_secret_key{{ else }}aiGwS3SecretKey{{ end }}
{{- with .Values.aiGateway.extraEnvVars }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}
