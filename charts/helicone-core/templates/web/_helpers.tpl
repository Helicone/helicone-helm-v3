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
