{{- define "helicone.ai-gateway.name" -}}
{{ include "helicone.name" . }}-ai-gateway
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helicone.ai-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.ai-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
