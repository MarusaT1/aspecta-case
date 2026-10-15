{{/* Common name for the release */}}
{{- define "webapp.fullname" -}}
{{ .Release.Name }}-webapp
{{- end -}}

{{/* Common labels applied to every object */}}
{{- define "webapp.labels" -}}
app.kubernetes.io/part-of: webapp
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{/* Selector labels for a given component (backend | frontend) */}}
{{- define "webapp.selectorLabels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end -}}
