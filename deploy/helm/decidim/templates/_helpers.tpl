{{/*
Expand the name of the chart.
*/}}
{{- define "decidim.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "decidim.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart label
*/}}
{{- define "decidim.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "decidim.labels" -}}
helm.sh/chart: {{ include "decidim.chart" . }}
{{ include "decidim.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "decidim.selectorLabels" -}}
app.kubernetes.io/name: {{ include "decidim.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "decidim.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "decidim.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image reference
*/}}
{{- define "decidim.image" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end }}

{{/*
Database URL — uses .Values.database.url if set, otherwise constructs from parts.
When CNPG is enabled, connects to the CNPG read-write service.
*/}}
{{- define "decidim.databaseUrl" -}}
{{- if .Values.database.url }}
{{- .Values.database.url }}
{{- else if .Values.cnpg.enabled }}
{{- $host := printf "%s-pg-rw" (include "decidim.fullname" .) }}
{{- $user := .Values.cnpg.owner }}
{{- $db := .Values.cnpg.database }}
{{- printf "postgres://%s@%s:5432/%s" $user $host $db }}
{{- else }}
{{- $host := .Values.database.host }}
{{- $port := .Values.database.port }}
{{- $user := .Values.database.username }}
{{- $pass := .Values.database.password }}
{{- $db := .Values.database.name }}
{{- printf "postgres://%s:%s@%s:%v/%s" $user $pass $host $port $db }}
{{- end }}
{{- end }}

{{/*
Redis URL
*/}}
{{- define "decidim.redisUrl" -}}
{{- if .Values.redis.url }}
{{- .Values.redis.url }}
{{- else if .Values.redis.enabled }}
{{- printf "redis://%s-redis-master:6379/0" .Release.Name }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Secret name for SECRET_KEY_BASE
*/}}
{{- define "decidim.secretName" -}}
{{- default (include "decidim.fullname" .) .Values.rails.existingSecret }}
{{- end }}
