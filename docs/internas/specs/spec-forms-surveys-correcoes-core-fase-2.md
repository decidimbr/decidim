# Spec — Formulários e Pesquisas no núcleo: fase 2 (pendências do QA, export em larga escala e adoções do upstream)

> Status: ready-for-agent
>
> Data: 2026-09-03
> Módulos afetados: `decidim-forms`, `decidim-surveys`, `decidim-core` (exporters e job de exportação) — Decidim 0.32.1, branch `fix/forms-surveys`
> Antecessora: `spec-forms-surveys-correcoes-core.md` (contrato dos defeitos 01–07 do QA; status ready-for-agent, 2026-09-01)
> Fonte: relatório *triagem da comunidade decidim forms & surveys — núcleo* (2026-09-02, `docs/internas`)
> Documento redigido em português; nomes de módulos e termos técnicos preservados conforme o código.

---

## Declaração do problema

Os defeitos de formulários e pesquisas vivem em três planos que precisam ser reconciliados por quem mantém este fork:

1. A **comunidade** registra relatos no MetaDecidim (55 publicados desde 2021; 33 sem qualquer resposta oficial, mediana de 301 dias até resposta).
2. O **upstream** acumula uma fila de 51 PRs abertos (02/09/2026) — 9 deles tocam `decidim-forms`/`decidim-surveys` — sem que nenhum tenha sido mergeado até a verificação de 03/09/2026.
3. O **fork** já corrigiu, na branch `fix/forms-surveys`, os defeitos 01–05 da bateria de QA (contrato definido na spec antecessora) — mas ainda não concluiu os itens pendentes dessa mesma spec, o follow-up de exportação em larga escala (que derruba exportações com ~250 mil respostas, espelhando a issue decidim/decidim#15443) nem dois defeitos corrigidos só no upstream: perguntas perdidas ao importar um espaço (PR decidim/decidim#17568, issue #17567) e locale errado na tradução automática de questionários (PR decidim/decidim#17421).

Para o administrador e o participante da plataforma, isso significa: respostas grandes que "dizem que deram certo" mas nunca geram o arquivo; questionários que perdem perguntas na importação entre ambientes; traduções automáticas gravadas com idioma errado; e os três acabamentos de UX já mapeados (anexos invisíveis na leitura da resposta, texto de apoio ausente no campo de arquivo, perguntas sem numeração).

## Solução

Esta spec consolida em um único contrato o que **já está resolvido** (com referência ao que possui PR upstream ou solução publicada) e o que **ainda precisa ser construído**, na ordem de prioridade abaixo:

| # | Item | Estado | Fonte / solução publicada |
|---|------|--------|---------------------------|
| 1 | Estado "aberto" com fonte única + guarda de POST em pesquisa fechada | **resolvido** no fork | commits `8b9f2b3618`, `0599a79e53` em `fix/forms-surveys`; sem correlato upstream identificado |
| 2 | Condicionantes com dono correto, sem duplicação/auto-referência | **resolvido** no fork | commit `ec269c02be`; prior art upstream: PRs #17321 e #17194 (issues #13787, #15712, #16513, #17193 — todos abertos) |
| 3 | Edição de resposta enviada removida (decisão de produto) | **resolvido** no fork | commit `b9b645d878`; prior art upstream: PR #17495 / issue #12386 (abertos — solução upstream diferente: exclusão de respostas) |
| 4 | Exportação limpa: cabeçalhos sem HTML, sem perguntas estruturais | **resolvido** no fork | commit `e7d36fb313`; contexto upstream: #16030 (mergeada) e #15443 (aberta, parte grande) |
| 5 | Limite de arquivos (`max_choices`) + política de upload da organização | **resolvido** no fork | commits `0172d61b01`, `7b8931d67d`; sem correlato upstream identificado |
| 6 | Anexos clicáveis no detalhe/confirmação da resposta | **planejado** | contrato já definido na spec antecessora (defeito 06, parte 2) |
| 7 | Texto de apoio do campo de arquivo: limite, extensões e tamanho | **planejado** | idem (defeito 06, parte 3) |
| 8 | Numeração automática das perguntas respondíveis | **planejado** | idem (defeito 07) |
| 9 | Exportação em larga escala: lotes/streaming + job assíncrono com notificação de sucesso **e** de falha | **planejado** | espelha decidim/decidim#15443 (sem PR upstream); follow-up antes fora de escopo, agora incorporado |
| 10 | Perguntas perdidas ao importar espaço com pesquisas | **planejado** (cherry-pick) | upstream PR #17568 / issue #17567 — fork sem fix local |
| 11 | Locale da tradução automática do questionário | **planejado** (cherry-pick) | upstream PR #17421 — fork sem fix local |
| 12 | Documentação administrativa da semântica de "Permite respostas" | **resolvido** | [guia administrativo](../permite-respostas-em-pesquisas.md) |

Nenhum dos 7 PRs upstream relevantes (#17321, #17194, #17495, #17568, #17421, #17216, #17331) estava mergeado em 03/09/2026 — portanto não há solução publicada para puxar integralmente hoje; os itens 10 e 11 portam o conteúdo dos PRs como commits locais com atribuição, e os demais PRs servem como prior art documentado.

## Histórias de usuário

As histórias **1 a 33 da spec antecessora** (`spec-forms-surveys-correcoes-core.md`) permanecem o contrato de comportamento de todo o ciclo de vida do questionário — cobrem estado "aberto", bloqueio de submissões, condicionantes, remoção da edição, exportação limpa, limites de arquivo e numeração. Nada nesta spec as altera; os itens 6–8 acima **completam** as histórias 26, 29, 30, 31, 32 e 33.

Novas histórias desta fase:

1. Como administrador, quero que a exportação das respostas de uma pesquisa com centenas de milhares de respostas seja processada em segundo plano, para que a exportação não falhe por falta de memória nem degrade a plataforma durante a geração.
2. Como administrador, quero receber uma notificação com o link de download quando a exportação terminar, para não precisar esperar na tela.
3. Como administrador, quero receber um aviso claro quando a exportação **falhar**, para não ficar aguardando um arquivo que nunca vai chegar (hoje o fluxo "diz que deu certo" e o ZIP não vem).
4. Como administrador, quero que a exportação processe as respostas em lotes (sem materializar tudo em memória), para que o consumo de memória não cresça com o volume de respostas.
5. Como administrador, quero que importar um espaço contendo pesquisas preserve **todas** as perguntas do questionário, para que meus formulários cheguem íntegros ao ambiente de destino.
6. Como administrador, quero que a tradução automática de um questionário seja gravada com o locale correto da organização, para que os participantes vejam o questionário no idioma certo.
7. Como administrador, quero uma documentação que explique que o interruptor "Permite respostas" é o controle de abertura, independente das datas de vigência, para configurar a pesquisa sem ambiguidade (a confusão original do defeito 01).

## Decisões de implementação

Esta seção registra decisões de desenho por item. **Não** lista caminhos de arquivo nem trechos de código (podem ficar obsoletos); descreve módulos, interfaces e contratos. As decisões dos itens já resolvidos (1–5 da tabela da Solução) estão detalhadas na spec antecessora e não são repetidas aqui em profundidade — seguem valendo como contrato.

### Anexos clicáveis no detalhe/confirmação da resposta — planejado

- Em todos os pontos onde uma resposta é apresentada para leitura — detalhe da resposta no painel administrativo e visões somente leitura do questionário —, anexos de perguntas do tipo arquivo aparecem como **lista de documentos clicáveis** (abrir/baixar), não como texto puro nem omitidos.
- Reutilizar o componente padrão de exibição de anexos do núcleo (mesma apresentação usada em outras áreas da plataforma); metadados de cada arquivo (nome, extensão, tamanho) devem estar disponíveis no objeto de resposta exibido.
- Links de download passam pelas rotas seguras já existentes para anexos; nenhuma rota nova.
- Sem mudança de esquema: a associação de anexos por resposta já existe; a pendência é de apresentação/dados no ponto de leitura.

### Texto de apoio do campo de arquivo — planejado

- Junto ao campo de envio de arquivos, o participante vê texto de apoio com: número máximo de arquivos (quando configurado via limite de arquivos), extensões aceitas e tamanho máximo por arquivo — ambos vindos da **política de upload da organização**.
- O texto é gerado a partir das mesmas configurações usadas na validação (nenhum texto manual divergente); quando não há restrição alguma configurada, nada é exibido.
- Chaves de tradução em inglês no arquivo base primeiro; traduções pt-BR na sequência (fluxo Crowdin), conforme convenção do projeto.

### Numeração automática das perguntas — planejado

- A renderização pública do questionário numera as perguntas respondíveis em ordem (1, 2, 3…), ignorando separadores e blocos de título/descrição, que não consomem número.
- Numeração calculada **na apresentação** (sem coluna nova em banco), acompanhando a ordenação real das perguntas e fluindo sem saltos/duplicações em questionários com etapas.

### Exportação em larga escala — planejado (antes follow-up fora de escopo)

- O pipeline de exportação de respostas de questionário passa a iterar em **lotes** (enumeração em lote, sem carregar a coleção inteira em memória) — o consumo de memória deve ser constante em relação ao número de respostas.
- A exportação de respostas de surveys roda **assincronamente via job**, com notificação ao administrador **no sucesso** (link do arquivo) e **na falha** (mensagem de erro explícita) — o falso-positivo de "exportação concluída" que nunca entrega o ZIP é o sintoma alvo (issue upstream #15443).
- Tratamento de erro: falha no meio da geração não deve produzir arquivo parcial apresentado como sucesso.
- Manter o mecanismo de exportação existente do núcleo (manifestos e formatos atuais: CSV/JSON/Excel/PDF); não introduzir infraestrutura de storage externa nesta fase.

### Cherry-picks do upstream (#17568 e #17421) — planejado

- **#17568** (perguntas perdidas no import de espaço, issue #17567): portar a correção como commit local na branch de trabalho, preservando a atribuição upstream (referência `(backport/port from decidim/decidim#17568)` na mensagem).
- **#17421** (locale da tradução automática do questionário): mesmo tratamento.
- Estratégia: portar o conteúdo dos PRs agora (são correções de defeitos reais que atingem o fork); quando o upstream mergeá-los, na próxima sincronização base os commits locais são reavaliados e descartados em favor da versão oficial.
- Os PRs trazem suas próprias suítes de teste; as specs upstream vêm junto no port e passam a integrar a suíte do fork.

### Documentação administrativa de "Permite respostas" — resolvido

- Nova seção na documentação interna do fork: [Permitir respostas em pesquisas](../permite-respostas-em-pesquisas.md), explicando que o interruptor é independente da janela de datas e que ambos os controles precisam permitir a resposta.
- Referência cruzada a partir da spec antecessora (contrato do defeito 01) para que a doc e o código contem a mesma história.

## Decisões de teste

Princípios (herdados da spec antecessora):

- **Testar comportamento externo**, não implementação: os testes descrevem "o que o participante/administrador observa", não nomes de métodos internos.
- **Um único contrato de estado**: casos de aberto/fechado exercitados no nível de modelo e repetidos no nível de sistema apenas nos fluxos mais relevantes.
- **Specs em vermelho primeiro** para cada item planejado, na mesma branch/PR da implementação.

Seams (pontos de teste) — todos existentes, priorizados nesta ordem:

1. **Specs de modelo** — escopos/predicados da pesquisa (contrato aberto/fechado).
2. **Specs de controlador** — guarda de envio do fluxo público.
3. **Specs de serializador** — forma da exportação de respostas.
4. **Exemplos compartilhados** de administração de questionários — edição persistindo corretamente.
5. **Specs de sistema** — fluxos do participante e do administrador nos componentes.

Pontos de teste por item planejado:

- **Anexos clicáveis**: spec administrativa do detalhe da resposta + exemplo compartilhado do questionário somente leitura (anexo visível, clicável, com nome correto); prior art: specs de sistema existentes do componente *surveys*.
- **Texto de apoio**: spec de sistema do componente (mensagem visível refletindo limite/extensões/tamanho; ausente quando não há restrição) + spec de view; prior art: specs de sistema do limite de arquivos já implementado.
- **Numeração**: spec de sistema com questionário contendo separadores e blocos (2 separadores + 5 perguntas ⇒ numeradas de 1 a 5) e versão com etapas (contagem flui sem saltos); spec de unidade do helper apenas se a numeração virar helper extraível.
- **Exportação em larga escala** — **única seam nova**: teste do exporter/serializador com coleção grande em memória (≥ 100 mil objetos de teste, sem banco real) afirmando iteração em lotes; e spec de job afirmando notificação de sucesso **e** de falha. Critérios de aceite espelham a issue #15443. Prior art: specs de exporters do `decidim-core`.
- **Cherry-picks**: as suítes de teste que acompanham os PRs upstream (#17568, #17421) fazem a validação; integradas à suíte de `decidim-forms`.
- **Documentação**: sem teste automatizado; critério de aceite é a revisão do par.

Execução:

- Rodar as suítes completas de `decidim-forms` e `decidim-surveys` (podem levar dezenas de minutos — não cancelar) e as specs de exporters do `decidim-core` tocadas pela mudança.

## Fora de escopo

- **Triagem dos 33 relatos sem resposta do MetaDecidim**: trabalho de comunidade/upstream (migração para issues com rótulo de triagem e resposta automática no componente 210) — não é código do fork; registrada como recomendação do relatório.
- **Sincronização geral com o Decidim oficial**: fork deliberado, sem sync planejado — **exceções explícitas**: os cherry-picks de #17568 e #17421.
- **PRs upstream #17216** (export com votos ocultos em proposals) **e #17331** (CSV de open data por recurso): módulos proposals/open-data, tangenciais a formulários e surveys — monitorar, não portar nesta fase.
- **PRs upstream #17321/#17194/#17495**: permanecem como prior art; o fork já resolvia os mesmos problemas com abordagens próprias (dono da condição; remoção da edição).
- **Infraestrutura de exportação externa** (storage dedicado, serviços de fila adicionais): manter o mecanismo core existente.
- **Outras fases do plano de simplificação do componente** (publicação de respostas por pergunta, um survey por componente, resposta anônima) e **ajustes visuais gerais** não relacionados aos itens listados.

## Notas adicionais

- **Verificação de estado dos PRs upstream** (via `gh`, 03/09/2026): #17321, #17194, #17495, #17568, #17421, #17216, #17331 — todos **abertos**, nenhum mergeado, base `develop`. A tabela da seção Solução deve ser revalidada antes de cada execução.
- **Leitura cruzada dos três planos** (comunidade · upstream · fork), do relatório de 02/09/2026:
  - Estado "aberto"/submissões fora da janela: sem relato comunitário nem PR upstream — resolvido só no fork.
  - Condicionantes: 4 issues upstream abertas desde 2024 (#13787, #15712, #16513, #17193) → PRs #17321/#17194; fork resolvido de forma independente.
  - Edição de resposta: relato comunitário 16980 sem resposta; upstream #12386 → #17495 (exclusão); fork removeu o recurso.
  - Exportação suja/perda de dados: relato 17364 sem resposta; #15443 (OOM, sem PR) e #16030 (mergeada); fork com export limpo + streaming planejado aqui.
  - Perguntas de arquivo e numeração: sem relato comunitário nem correlato upstream — trabalho exclusivo do fork (itens 6–8).
- Estratégia de branch: um commit por item planejado, continuando em `fix/forms-surveys`; registrar mudanças relevantes no `RELEASE_NOTES.md` do fork quando houver release.
- A spec antecessora permanece válida como contrato dos defeitos 01–07; esta fase-2 não a substitui — complementa e fecha seus pendentes, incorpora o follow-up de exportação e adiciona as adoções do upstream.
