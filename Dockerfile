# syntax=docker/dockerfile:1
ARG ruby_version=3.4.7
ARG node_version=22
ARG ENVIRONMENT=production

# ── Node (only for copying binaries) ─────────────────────────────────
FROM node:${node_version}-bookworm-slim AS node

# ── Build & Runtime ──────────────────────────────────────────────────
FROM ruby:${ruby_version}-slim-bookworm AS build
ARG ENVIRONMENT

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Copy Node.js from the node image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin
COPY --from=node /opt/ /opt/

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    git \
    libssl-dev \
    zlib1g-dev \
    libicu-dev \
    libpq-dev \
    libyaml-dev \
    imagemagick \
    libvips42 \
    p7zip-full \
    tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Fix Git dubious ownership issue
RUN git config --global --add safe.directory /decidim

RUN gem install bundler --version '>= 2.4.20'

WORKDIR /decidim

# ── JS dependencies (cached layer) ───────────────────────────────────
# Copia o package.json do dummy app (é ele quem será usado de fato para
# compilar assets). Instalar o package.json da raiz seria trabalho perdido.
COPY spec/decidim_dummy_app/package.json .
COPY spec/decidim_dummy_app/package-lock.json* ./
RUN npm install

# ── Ruby dependencies (cached layer) ─────────────────────────────────
COPY Gemfile .
COPY Gemfile.lock* ./

# Copy all decidim gemspecs
COPY decidim.gemspec ./
COPY vendor/modules/ vendor/modules/
COPY decidim-core/decidim-core.gemspec decidim-core/
COPY decidim-admin/decidim-admin.gemspec decidim-admin/
COPY decidim-api/decidim-api.gemspec decidim-api/
COPY decidim-system/decidim-system.gemspec decidim-system/
COPY decidim-proposals/decidim-proposals.gemspec decidim-proposals/
COPY decidim-meetings/decidim-meetings.gemspec decidim-meetings/
COPY decidim-budgets/decidim-budgets.gemspec decidim-budgets/
COPY decidim-surveys/decidim-surveys.gemspec decidim-surveys/
COPY decidim-forms/decidim-forms.gemspec decidim-forms/
COPY decidim-pages/decidim-pages.gemspec decidim-pages/
COPY decidim-comments/decidim-comments.gemspec decidim-comments/
COPY decidim-debates/decidim-debates.gemspec decidim-debates/
COPY decidim-accountability/decidim-accountability.gemspec decidim-accountability/
COPY decidim-assemblies/decidim-assemblies.gemspec decidim-assemblies/
COPY decidim-conferences/decidim-conferences.gemspec decidim-conferences/
COPY decidim-initiatives/decidim-initiatives.gemspec decidim-initiatives/
COPY decidim-blogs/decidim-blogs.gemspec decidim-blogs/
COPY decidim-design/decidim-design.gemspec decidim-design/
COPY decidim-dev/decidim-dev.gemspec decidim-dev/
COPY decidim-generators/decidim-generators.gemspec decidim-generators/
COPY decidim-demographics/decidim-demographics.gemspec decidim-demographics/
COPY decidim-ai/decidim-ai.gemspec decidim-ai/
COPY decidim-elections/decidim-elections.gemspec decidim-elections/
COPY decidim-collaborative_texts/decidim-collaborative_texts.gemspec decidim-collaborative_texts/
COPY decidim-templates/decidim-templates.gemspec decidim-templates/
COPY decidim-participatory_processes/decidim-participatory_processes.gemspec decidim-participatory_processes/
COPY decidim-verifications/decidim-verifications.gemspec decidim-verifications/
# COPY decidim-govbr/decidim-govbr.gemspec decidim-govbr/

RUN if [ "$ENVIRONMENT" = "production" ]; then \
        bundle config set without 'test development'; \
        bundle install; \
    else \
        bundle check || bundle install; \
    fi

# ── Full source + asset compilation ──────────────────────────────────
COPY . .

# Install Node dependencies for dummy app (needed for asset compilation)
RUN cd spec/decidim_dummy_app && npm install

# Install the npm dependencies declared by each vendored module (e.g.
# decidim_awesome's formBuilder). Webpack resolves them via upward
# traversal into the module's own node_modules. --no-package-lock keeps
# the module dirs clean; devDependencies are not needed at runtime.
RUN for dir in vendor/modules/*/; do \
        if [ -f "$dir/package.json" ]; then \
            (cd "$dir" && npm install --no-package-lock --no-audit --no-fund --omit=dev); \
        fi; \
    done

# spec/decidim_dummy_app é gerada localmente via `rake test_app` (não é
# versionada; o .dockerignore a mantém no contexto do build), então a
# imagem NÃO precisa de PostgreSQL/Redis no build. O banco é
# criado/migrado no start do container (db:prepare no CMD) contra os
# serviços externos do ambiente (compose/Kubernetes).

RUN if [ "$ENVIRONMENT" = "production" ]; then \
        cd spec/decidim_dummy_app && \
        RAILS_ENV=production SECRET_KEY_BASE=placeholder \
            DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE=memory \
            DECIDIM_SPAM_DETECTION_BACKEND_USER=memory \
            bundle exec rails deface:precompile && \
        RAILS_ENV=production SECRET_KEY_BASE=placeholder \
            DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE=memory \
            DECIDIM_SPAM_DETECTION_BACKEND_USER=memory \
            bundle exec rails assets:precompile; \
    else \
        cd spec/decidim_dummy_app && \
        RAILS_ENV=development SECRET_KEY_BASE=placeholder \
            DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE=memory \
            DECIDIM_SPAM_DETECTION_BACKEND_USER=memory \
            bundle exec rails assets:precompile; \
    fi

ENV RAILS_ENV=${ENVIRONMENT} \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    DISABLE_SPRING=1 \
    PORT=3000

WORKDIR /decidim/spec/decidim_dummy_app

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/up || exit 1

# Prepara o banco (cria/migra/seeda no primeiro boot) e sobe o Puma.
# db:prepare é idempotente: cria o banco + seeds se não existir, roda
# migrations pendentes se já existir. Sem fallback silencioso — qualquer
# erro de conexão/schema aparece no log em vez de ser engolido.
CMD ["bash", "-c", "bundle exec rails db:prepare; exec bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:${PORT:-3000}"]
