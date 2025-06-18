{{/*
Expand the name of the chart.
*/}}

{{- define "helicone.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
