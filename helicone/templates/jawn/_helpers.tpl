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
