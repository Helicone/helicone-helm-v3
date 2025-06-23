{{- define "helicone.aigateway.name" -}}
{{ include "helicone.name" . }}-aigateway
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helicone.aigateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.aigateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
