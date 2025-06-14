{{- define "helicone.helix.name" -}}
{{ include "helicone.name" . }}-helix
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helicone.helix.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.helix.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
