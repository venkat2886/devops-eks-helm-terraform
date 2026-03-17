{{- define "sample-app.name" -}}
sample-app
{{- end -}}

{{- define "sample-app.fullname" -}}
{{ include "sample-app.name" . }}
{{- end -}}