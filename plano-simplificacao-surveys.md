# Plano: Simplificação do `decidim-surveys` + correção de performance do export

## Veredito sobre a hipótese

**"A complexidade adicionada reflete os problemas" — parcialmente confirmada.** Auditoria do histórico git (2022→hoje):

| Funcionalidade | Bugs documentados | Tamanho da adição |
|---|---|---|
| Exports (CSV/JSON/Excel/FormPDF, open data) | 5 (`dc6b47f44e`, `a4ceeed23b`, `0b7759ef3a`, `f2f89e2ae8`, `e4162beeac`) | grande |
| Múltiplos surveys por componente + publicação | 4 (`dc6b47f44e`, `ace96bded1`, `8643e60d94`, `6c6f29597d`) | commit `e506575e77`: 2.888 inserções |
| Publicação de respostas por pergunta | 4 (`edd653c72f`, `e850731941`, `b0ee99ba16`, `6eb0ce5a23`) | feature `f927627512`: 1.103 inserções |
| Editor admin de perguntas (no forms) | 5 | herdado, não removível |
| Janela de datas, honeypot, `clean_after_publish`, e-mail de confirmação | **0** | pequena |

Ressalvas: ~1/3 dos bugs vive no `decidim-forms` (compartilhado), e complexidade ≠ bug em 100% dos casos (searchable e edição de respostas têm poucos bugs). Ainda assim, os 3 maiores geradores de bugs são exatamente as 3 maiores adições pós-2023 — a hipótese se sustenta onde importa.

**Correção de rota sobre o export:** a solução proposta ("gerar em background + link protegido") **já existe** (`ExportJob` → fila `:exports` → `PrivateExport` com uuid + token assinado + expiração de 7 dias → link por e-mail). O sintoma real relatado é **lentidão/travamento em surveys grandes**, com causas verificadas no código:

- `QuestionnaireUserResponses.for` (`decidim-forms/app/queries/decidim/forms/questionnaire_user_responses.rb:23-29`) carrega TODAS as respostas e faz `sort_by`/`group_by` em Ruby; `:choices` e `:attachments` não são eager-loaded.
- `UserResponsesSerializer` (`decidim-forms/lib/decidim/forms/user_responses_serializer.rb`): 1 query de questions **por participante** (linhas 46-58), queries por resposta em `choices`/`attachments` (linhas 67, 71), e **1 query por célula de matriz** (`choices.find_by(matrix_row:, response_option:)`, linha 91).
- `export_response` individual carrega a coleção inteira e filtra por `session_token` em Ruby (`decidim-forms/app/controllers/decidim/forms/admin/concerns/has_questionnaire_responses.rb:49-54`).

## Decisões já tomadas

- Remover as 4 funcionalidades: **publicação de respostas por pergunta**, **múltiplos surveys por componente**, **resposta anônima** (`allow_unregistered`), **edição de respostas** (`allow_editing_responses`).
- Escopo: `decidim-surveys` + `decidim-forms` com cuidado (nada de `decidim-core`).

---

## Fase 0 — Preparação

1. Criar branch de trabalho a partir de `develop`.
2. Garantir test app gerada: `bundle exec rake test_app` (se `spec/decidim_dummy_app` não existir).
3. Baseline: `cd decidim-surveys && bundle exec rspec` e `cd decidim-forms && bundle exec rspec` (rodar em background; nunca cancelar — podem levar 10–30 min).

## Fase 1 — Remover publicação de respostas por pergunta (~380 linhas no surveys + 1 coluna no forms)

**Em `decidim-surveys`:**

- Apagar: `app/controllers/decidim/surveys/admin/publish_responses_controller.rb`, `app/commands/decidim/surveys/publish_responses.rb` e `unpublish_responses.rb`, `app/helpers/decidim/surveys/publish_responses_helper.rb`, views `app/views/decidim/surveys/admin/publish_responses/*` e `app/views/decidim/surveys/surveys/_published_questions_responses.html.erb`.
- `admin_engine.rb:37`: remover rota `resources :publish_responses`.
- `app/permissions/decidim/surveys/admin/permissions.rb:25-33`: remover bloco `:questionnaire_publish_responses`.
- `app/controllers/decidim/surveys/surveys_controller.rb`: remover `show_published_questions_responses?` (linhas 53-55) — survey fechado sempre mostra o aviso "questionnaire_closed".
- `lib/decidim/surveys/component.rb:80-95`: remover o export `:published_survey_user_responses` (open data) — ele depende da coluna que vai embora e já tem bug residual (`Survey.find_by(component:)` assume 1 survey).
- Apagar `lib/decidim/surveys/user_responses_serializer.rb` e specs correspondentes.

**Em `decidim-forms` (com cuidado):**

- Migration `drop column survey_responses_published_at from decidim_forms_questions` (novo arquivo em `decidim-forms/db/migrate/`).
- Grep por `survey_responses_published_at` em forms e remover referências (deve restar só a coluna e specs).
- Verificar `publish_responses_buttons.js` em `decidim-forms/app/packs/src/decidim/forms/admin/` — se só serve ao surveys, remover.

**Limpeza transversal:** chaves `en.yml` órfãs (apenas `en` — Crowdin cuida do resto); specs: apagar `publish_responses_spec.rb`, `unpublish_responses_spec.rb`, trechos de `admin_manages_surveys_spec.rb` (linhas 200-303) e `survey_spec.rb` (linhas 54-98) que testam a feature.

**Validação da fase:** `cd decidim-surveys && bundle exec rspec`, `cd decidim-forms && bundle exec rspec`, `bundle exec i18n-tasks normalize --locales en`.

## Fase 2 — Voltar a 1 survey por componente

**Decisão pendente de dados (confirmar antes de executar):** componentes que hoje têm >1 survey. Política recomendada: data migration que mantém o survey **com mais respostas** (desempate: o mais antigo) e **destroi** os demais, com modo dry-run que apenas reporta (`puts` por componente afetado) rodado antes em produção/staging.

**Em `decidim-surveys`:**

- `lib/decidim/surveys/engine.rb:11-18`: trocar `resources :surveys, only: [:index, :show, :edit]` por rota singleton: `root to: "surveys#show"`, `post :respond` no escopo do componente. Apagar `index` do controller, views `index.html.erb`/`_surveys.html.erb`, o `Filterable`/filtro `with_any_state` do controller público e o concern `app/controllers/concerns/decidim/surveys/filterable.rb` (se só serve a isso).
- `app/controllers/decidim/surveys/surveys_controller.rb`: `survey` passa a ser `Survey.find_by!(component: current_component)` (linhas 79-81); remover `search_collection`/`filter`/`paginate`.
- Admin (`admin/surveys_controller.rb`): remover `index`, `Filterable`, `collection` paginada; `create` deve falhar/redirect se já existir survey no componente (guard no `Admin::CreateSurvey` ou validação de unicidade); menu admin (`admin_engine.rb:42-68`) já assume 1 survey — mantém.
- `app/models/decidim/surveys/survey.rb`: `validates :component, uniqueness: true`; scopes `.open`/`.closed` e `FilterableResource` podem sair junto com o index público (avaliar: o filtro público morre com a listagem).
- Data migration (`decidim-surveys/db/data/`): regra acima para componentes com >1 survey.
- Verificar e simplificar: `component.rb:38-56` (stat), seeds (`seeds.rb` cria 1 — ok), `CleanSurveyResponsesJob` (`Survey.find_by(component:)` — vira correto por construção), GraphQL `SurveysType` (retorna lista → vira item único? manter lista com 1 item para não quebrar a API — **decisão: manter compatível**).
- Views/cells: `card_for`/cell do survey continuam usados em busca global — manter.

**Validação:** specs de sistema `survey_spec.rb` (listagem some), `admin_manages_surveys_spec.rb`; ajustar factories se necessário.

## Fase 3 — Remover resposta anônima (`allow_unregistered`)

**Em `decidim-surveys`:**

- Remover coluna via migration (`db/migrate/`), campo do `SurveySettingsForm` (`app/forms/decidim/surveys/admin/survey_settings_form.rb:7-14`), views de settings, `allow_unregistered?` em `surveys_controller.rb:61-63`.
- `lib/decidim/api/survey_type.rb`: remover campo; ajustar `spec/types/*`.
- Apagar `spec/system/unregistered_user_survey_spec.rb` (142 linhas) e exemplos compartilhados dependentes; ajustar `factories.rb` (trait).
- Efeito colateral positivo: `visitor_can_respond?` passa a exigir login sempre; o honeypot/`invisible_captcha` continua (é do forms, custo zero).

**Em `decidim-forms`:** não mexer — o default `allow_unregistered?` do concern `HasQuestionnaire` permanece (usado por meetings/demographics).

**Validação:** `bundle exec rspec` no surveys; `i18n-tasks normalize --locales en`.

## Fase 4 — Remover edição de respostas (`allow_editing_responses`)

> **EXECUTADA** (branch `fix/forms-surveys-qa-fixes`, 2026-08-18) — com um ajuste de escopo: a infraestrutura do `decidim-forms` (`add_responses!`, atributo `allow_editing_responses` do `QuestionnaireForm`, parâmetro do `ResponseQuestionnaire` e hook `allow_editing_responses?` do concern) foi **mantida** porque o `decidim-demographics` depende dela (`demographics_controller.rb`). Removidos: coluna e setting do survey, rota/action `edit` pública, campo GraphQL `allowEditingResponses`, link "Edit your responses" e o template `questionnaires/edit`.

**Em `decidim-surveys`:**

- Remover coluna via migration, campo do settings form, `check_editable` e `edit` (controller público, linhas 24-30 e 42-47), `allow_editing_responses?` (49-51), rota `edit` no engine.
- Apagar `spec/shared/editable_survey_response_examples.rb` e trechos dependentes (`survey_spec.rb:238-273`, `registered_user_survey_spec.rb`).

**Em `decidim-forms` (com cuidado — grep confirma que nenhum outro consumidor usa):**

- `app/commands/decidim/forms/response_questionnaire.rb`: remover ramo `allow_editing_responses` e `clear_responses!` (linhas 24-38, 81-83) — resposta duplicada passa a ser sempre `:invalid`.
- `app/forms/decidim/forms/questionnaire_form.rb`: remover `add_responses!` (31-35) e o atributo `allow_editing_responses`.
- `app/controllers/decidim/forms/concerns/has_questionnaire.rb`: remover ganchos de edição; `app/views/decidim/forms/questionnaires/edit.html.erb` e o ramo "já respondeu → link de edição" de `show.html.erb` (33-49) viram só anúncio.
- `app/cells/decidim/forms/step_navigation_cell.rb:47-64`: remover ramo `allow_editing_responses?` do `data-confirm`.
- Locales `en.yml` correspondentes.

**Validação:** `bundle exec rspec` em surveys e forms; checar meetings/demographics com grep por `add_responses!`/`edit` antes de apagar (já confirmado: sem uso fora de surveys).

## Fase 5 — Performance do export (decidim-forms)

Ordem de ataque (medir antes/depois com um survey grande seedado na development_app, ex.: 50 perguntas × 5 mil participantes):

1. **Eager loading na query** — `questionnaire_user_responses.rb:23-29`: adicionar `:choices` (com `response_option`/`matrix_row`) e `:attachments` ao `includes`; substituir `sort_by` em Ruby por `order` no SQL onde possível (group_by final continua em Ruby, aceitável).
2. **Eliminar N+1 por célula de matriz** — `user_responses_serializer.rb:86-97`: trocar `choices.find_by(...)` por lookup em memória sobre a associação já carregada (ex.: indexar `response.choices` por `[matrix_row_id, response_option_id]` uma vez por resposta).
3. **Eliminar query de questions por participante** — `user_responses_serializer.rb:46-58`: memoizar o mapa de perguntas por questionário (cache em nível de classe indexado por `[questionnaire_id, I18n.locale]`, válido durante o job; perguntas são imutáveis após haver respostas, então staleness é não-issue na prática).
4. **Export individual sem carregar tudo** — `has_questionnaire_responses.rb:49-54`: filtrar por `session_token` em SQL antes de agrupar.
5. **Specs de regressão**: estender `spec/lib/decidim/forms/user_responses_serializer_spec.rb` e `spec/queries/decidim/forms/questionnaire_user_responses_spec.rb` cobrindo matriz, free_text e attachments; se fácil, spec de contagem de queries.

**Fora de escopo (follow-up):** escrita em disco/streaming nos exporters e no `FileZipper`/`attach_archive` (são `decidim-core`); job recorrente de limpeza de `PrivateExport`s expirados; link de download contextualizado na UI do admin; feedback de falha do job.

## Fase 6 — Limpeza e documentação

- Remover método morto `clean_after_publish_changed?` (`decidim-surveys/app/jobs/decidim/surveys/settings_change_job.rb:44-46`).
- Registrar em `RELEASE_NOTES.md`: fim do anonimato, fim da edição, 1 survey por componente, fim da publicação de resultados.
- Atualizar `docs/` se houver páginas sobre surveys/exports afetadas.
- Checklist final (`.ai/build-pipeline-integration.md`): `bundle exec rubocop`, `bundle exec erblint --lint-all`, `bundle exec i18n-tasks normalize --locales en`, `bundle exec rspec` (surveys + forms), `npm run lint` se JS tocado.

## Riscos e mitigações

- **Data migration destrutiva** (fase 2): dry-run obrigatório antes; destruir só após confirmação do relatório.
- **API GraphQL** quebra de contrato (fase 2): manter `surveys` como lista de 1 item.
- **Templates existentes** (decidim-templates) que usam questionários: não afetados — nenhuma fase toca o editor de perguntas.
- **Meetings/demographics** dependem do forms: fases 4 e 5 tocam forms; cada mudança lá exige grep prévio de consumidores + suite do forms verde.
- **Divergência com upstream**: este repo é um fork; cada remoção aumenta a distância do Decidim oficial. Aceito como custo deliberado da simplificação.

## Ordem sugerida de commits

Um commit por fase (1→6), cada um deixando a suite verde. Fases 3 e 4 são independentes entre si; fase 2 deve vir depois da 1 (o open-data export morre na 1, simplificando a 2).
