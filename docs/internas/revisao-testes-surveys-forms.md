# Revisão de Testes - Surveys e Forms

## Data: 2026-09-01

## Contexto

Revisão completa dos testes dos módulos `decidim-surveys` e `decidim-forms` com base nas correções recentes implementadas entre os commits `89f256bba1` e `c45c81d904` (Agosto 2026).

## Correções Recentes Analisadas

### 1. Remoção da funcionalidade de edição de respostas (c159cefe12, c45c81d904)
- **Status:** ✅ Testes adequadamente removidos
- **Arquivos:** removidos `editable_survey_response_examples.rb` e testes relacionados
- **Análise:** Correto, não há necessidade de testes para código inexistente

### 2. Validação de max_files em questões de arquivos (485589daef)
- **Status:** ✅ Testes unitários adequados, ⚠️ testes de integração adicionados
- **Testes existentes:** `question_form_spec.rb`, `response_form_spec.rb`, `has_questionnaire.rb`
- **Novos testes adicionados:**
  - `decidim-surveys/spec/system/survey_spec.rb` - Teste de sistema para validação de max_files
  - `decidim-forms/lib/decidim/forms/test/shared_examples/manage_questionnaires/add_questions.rb` - Testes de configuração admin

### 3. Strip HTML dos headers na exportação (1edd19ea00)
- **Status:** ✅ Testes adequados, ⚠️ teste adicional adicionado
- **Testes existentes:** `user_responses_serializer_spec.rb`
- **Novo teste adicionado:**
  - Teste explícito para questões `title_and_description` não gerarem colunas vazias

### 4. Correção de display conditions corrompidas (f697786f98, c89dff3b02)
- **Status:** ✅ Testes adequados
- **Testes existentes:** `question_spec.rb`, `update_questions_spec.rb`
- **Análise:** Testes cobrem bem o bug de corrupção e re-saving

### 5. Bloqueio de submissões diretas para surveys fechadas (92900c4861)
- **Status:** ✅ Testes adequados, ⚠️ teste adicional adicionado
- **Testes existentes:** `surveys_controller_spec.rb`
- **Novo teste adicionado:**
  - Teste para survey com `starts_at` no futuro (ainda não aberta)

### 6. Correção do scope .open ignorando allow_responses (89f256bba1)
- **Status:** ✅ Testes adequados
- **Testes existentes:** `survey_spec.rb`
- **Análise:** Testes cobrem bem o bug e garantem que o scope funciona corretamente

## Testes Adicionados

### 1. Teste de Sistema para max_files (Prioridade Alta)
**Arquivo:** `decidim-surveys/spec/system/survey_spec.rb`

**Contexto:** "when the survey has a files question with max_choices limit"

**Testes:**
- Verifica que o limite de max_files é exibido na interface
- Valida que o limite é aplicado ao tentar enviar mais arquivos que o permitido
- Verifica que a submissão é bem-sucedida quando dentro do limite

**Cobertura:** Integração end-to-end do fluxo de validação de max_files

### 2. Testes de Admin para Configuração de max_files (Prioridade Alta)
**Arquivo:** `decidim-forms/lib/decidim/forms/test/shared_examples/manage_questionnaires/add_questions.rb`

**Contexto:** "when adding a files question"

**Testes:**
- Verifica que o admin pode configurar `max_choices` para questões tipo "files"
- Valida que `max_choices` mínimo é 2
- Verifica que o label "Max files" é exibido no formulário admin

**Cobertura:** Interface de administração para configuração de questões de arquivos

### 3. Teste para title_and_description na Exportação (Prioridade Média)
**Arquivo:** `decidim-forms/spec/serializers/decidim/forms/user_responses_serializer_spec.rb`

**Contexto:** "when the questionnaire has structural questions and bodies with HTML"

**Teste:**
- Verifica que questões `title_and_description` não geram colunas vazias na exportação

**Cobertura:** Complementa o teste existente para separadores

### 4. Teste para starts_at Futuro (Prioridade Baixa)
**Arquivo:** `decidim-surveys/spec/controllers/decidim/surveys/surveys_controller_spec.rb`

**Contexto:** "when the survey has not started yet"

**Teste:**
- Verifica que surveys com `starts_at` no futuro são bloqueadas

**Cobertura:** Complementa os testes de bloqueio de surveys fechadas

## Resumo da Cobertura

### Antes da Revisão
- ✅ 6 de 6 correções tinham testes unitários/form adequados
- ✅ 4 de 6 correções tinham testes de controller/model adequados
- ⚠️ 1 de 6 correções precisava de testes de integração/sistema

### Após a Revisão
- ✅ 6 de 6 correções têm testes unitários/form adequados
- ✅ 4 de 6 correções têm testes de controller/model adequados
- ✅ 2 de 6 correções agora têm testes de integração/sistema robustos

## Arquivos Modificados

### Testes Adicionados/Modificados
1. `decidim-surveys/spec/system/survey_spec.rb` - Adicionado contexto completo para max_files
2. `decidim-forms/lib/decidim/forms/test/shared_examples/manage_questionnaires/add_questions.rb` - Adicionado contexto para files questions
3. `decidim-forms/spec/serializers/decidim/forms/user_responses_serializer_spec.rb` - Adicionado teste para title_and_description
4. `decidim-surveys/spec/controllers/decidim/surveys/surveys_controller_spec.rb` - Adicionado teste para starts_at futuro

## Próximos Passos Recomendados

### Imediato
- [ ] Rodar suites completas de testes para verificar que todos passam
- [ ] Verificar cobertura de testes com `bundle exec rspec --coverage`

### Futuro
- [ ] Considerar adicionar testes de performance para exportação de grandes questionários
- [ ] Adicionar testes de acessibilidade para o modal de upload de arquivos
- [ ] Considerar testes de integração para o fluxo completo de display conditions

## Notas Técnicas

### Infraestrutura de Testes
- Os testes requerem banco de dados PostgreSQL configurado
- Usar `docker-compose.yml` para ambiente de desenvolvimento completo
- Testes de sistema usam Capybara com driver headless

### Padrões de Teste Seguidos
- Testes de sistema seguem o padrão existente em `survey_spec.rb`
- Testes de admin seguem o padrão dos shared examples em `manage_questionnaires`
- Testes de serializer seguem o padrão existente em `user_responses_serializer_spec.rb`
- Testes de controller seguem o padrão existente em `surveys_controller_spec.rb`

## Conclusão

A revisão identificou que a maioria das correções recentes já possuía boa cobertura de testes a nível unitário. As principais lacunas estavam em testes de integração/sistema, que foram adicionados para:

1. **Validação de max_files:** Fluxo completo de configuração admin → validação frontend → mensagem de erro
2. **Exportação de dados:** Cobertura explícita para questões `title_and_description`
3. **Bloqueio de surveys:** Cobertura para surveys com `starts_at` futuro

Os testes adicionados melhoram a confiança nas correções e servem como documentação viva do comportamento esperado do sistema.
