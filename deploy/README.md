# Decidim GovBR — Deploy de staging com Skaffold + Helm

Stack de deploy de staging para a instância Decidim, usando **Skaffold** para build da imagem a partir do fonte e **Helm** para o deploy no Kubernetes.

> **Desenvolvimento local:** use o `docker-compose.yml` na raiz (`docker compose up --build`). O Skaffold/Helm é destinado apenas ao deploy de staging.

## Estrutura

```
(raiz do repositório)
├── Dockerfile                   # Imagem única (dev via compose, staging via skaffold)
├── docker-compose.yml           # Ambiente de desenvolvimento local
├── skaffold.yaml                # Orquestra build + deploy staging
└── deploy/
    ├── README.md                # Este arquivo
    └── helm/decidim/
        ├── Chart.yaml         # Chart metadata
        ├── values.yaml        # Valores default
        └── templates/
            ├── _helpers.tpl       # Template helpers
            ├── deployment.yaml
            ├── service.yaml
            ├── ingress.yaml
            ├── configmap.yaml
            ├── secret.yaml
            ├── serviceaccount.yaml
            ├── pvc.yaml           # Volume persistente para uploads
            ├── redis.yaml         # Redis (cache/filas)
            ├── cnpg-cluster.yaml  # PostgreSQL via CloudNativePG
            └── NOTES.txt
```

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) com BuildKit habilitado
- [Skaffold](https://skaffold.dev/docs/install/) v2+
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configurado com acesso ao cluster
- [Helm](https://helm.sh/docs/intro/install/) v3+
- Operador [CloudNativePG](https://cloudnative-pg.io/) instalado no cluster (o PostgreSQL é provisionado como um `Cluster` CR)
- Ingress controller (nginx), se for usar o Ingress habilitado

### Instalar Skaffold

```bash
# macOS
brew install skaffold

# Linux
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
sudo install skaffold /usr/local/bin/
```

## Uso

### Deploy staging (one-shot)

A partir da raiz do repositório (o `skaffold.yaml` fica na raiz):

```bash
skaffold run
```

Isso vai:
1. Buildar a imagem Docker a partir do fonte do monorepo (`Dockerfile` da raiz, com assets pré-compilados)
2. Instalar o chart Helm no namespace `decidim-staging`, provisionando PostgreSQL (CloudNativePG), Redis e PVC para uploads
3. Deployar o Decidim no namespace `decidim-staging`
4. Port-forward `localhost:3000` → serviço `decidim-staging` no cluster

O container roda `db:prepare` no boot, então migrations (e seeds em banco novo) são aplicadas automaticamente.

### Limpar tudo

```bash
skaffold delete
```

## Configuração

### Variáveis importantes

| Variável | Descrição | Como setar |
|---|---|---|
| `rails.secretKeyBase` | Chave de sessão do Rails (auto-gerada se vazia) | `--set-rails.secretKeyBase=...` |
| `database.url` | URL completa do banco (sobrepõe o CNPG) | `--set-database.url=...` |
| `ingress.hosts[0].host` | Domínio da instância | Editar `values.yaml` |
| `storage.provider` | Backend de uploads | `local`, `amazon`, `google`, `microsoft` |

### Usar PostgreSQL externo

```yaml
# values.yaml
cnpg:
  enabled: false
database:
  url: "postgres://user:pass@external-host:5432/decidim"
```

### SMTP para emails

Adicione em `values.yaml`:

```yaml
env:
  - name: SMTP_ADDRESS
    value: "smtp.example.com"
  - name: SMTP_PORT
    value: "587"
  - name: SMTP_USERNAME
    valueFrom:
      secretKeyRef:
        name: smtp-credentials
        key: username
  - name: SMTP_PASSWORD
    valueFrom:
      secretKeyRef:
        name: smtp-credentials
        key: password
```

### Customizar recursos

```yaml
# values.yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: "2"
    memory: 2Gi

replicaCount: 3
```

## Perfis Skaffold

Não há perfis: o pipeline único faz build production-style e deploy de staging. Iteração local é feita com `docker compose up --build`.

## Troubleshooting

### Ver logs

```bash
kubectl logs -n decidim-staging -l app.kubernetes.io/name=decidim -f
```

### Verificar status do deploy

```bash
kubectl get pods -n decidim-staging
kubectl get svc -n decidim-staging
helm list -n decidim-staging
```

### Acessar o banco

```bash
kubectl exec -n decidim-staging -it $(kubectl get pods -n decidim-staging -l cnpg.io/cluster=decidim-staging-pg -o name | head -1) -- \
  psql -U decidim -d decidim_production
```

### Rodar migrations

O container já roda `db:prepare` no boot. Para forçar manualmente:

```bash
kubectl exec -n decidim-staging -it $(kubectl get pods -n decidim-staging -l app.kubernetes.io/name=decidim -o name | head -1) -- \
  bundle exec rails db:migrate
```
