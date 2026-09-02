# Spec — Correções no núcleo de Formulários e Pesquisas (decidim-forms e decidim-surveys)

> Status: ready-for-agent
>
> Data: 2026-09-01
> Módulos afetados: `decidim-forms`, `decidim-surveys` (núcleo do Decidim 0.32.1 — branch `internalize/qa-fixes-v0.32.1`)
> Documento redigido em português; nomes de módulos e termos técnicos preservados conforme o código.

---

## Declaração do problema

A equipe de QA registrou uma bateria de defeitos no fluxo de formulários e pesquisas (componente *surveys* do Decidim, que usa o questionário compartilhado do `decidim-forms`). Os relatos, vindos das abas "Relatórios/Formulários" e "Formulários" da planilha de QA, descrevem comportamentos inconsistentes entre o que o administrador configura e o que participante e administrador observam:

1. Um formulário inserido, publicado e com datas de vigência configuradas aparece como **"encerrado"** mesmo estando dentro da janela de respostas.
2. As **condicionantes** (perguntas que só aparecem conforme respostas anteriores) **não são executadas conforme a configuração**.
3. **Participações e respostas continuam sendo enviadas** mesmo com o formulário encerrado (inclusive via requisição direta).
4. Ao selecionar o botão de **edição de respostas enviadas**, a edição **não funciona**.
5. Na **exportação** das respostas, o último item sai com **HTML quebrado**.
6. Em perguntas do tipo arquivo, o participante **não vê o limite máximo de arquivos** configurado, nem **quais extensões são aceitas**; e, após anexar documentos, **não consegue visualizar os documentos na confirmação/detalhe da resposta**.
7. O formulário **não enumera as questões** de forma automatizada, dificultando referenciar perguntas.

Além de corrigir cada sintoma, esta spec estabelece o contrato de comportamento esperado para o ciclo de vida de um questionário (aberto/fechado, submissão, condicionantes, arquivos, exportação e leitura das respostas), de forma que as correções sejam verificáveis e não regridam.

## Solução

Unificar a definição de "formulário aberto para respostas" em uma única semântica — *aceita respostas se, e somente se, o responsável pela pesquisa marcou "Permite respostas" **e** a data/hora atual estiver dentro da janela configurada (ou não houver janela)* — e fazer **todas** as superfícies respeitarem essa definição: o selo de estado exibido, a permissão de submissão no controlador (incluindo POST diretos), os escopos de consulta e a interface.

Para os demais defeitos:

- **Condicionantes**: garantir que cada condição de exibição pertença à pergunta condicionada e nunca seja duplicada nem auto-referente durante a edição no administrador; a avaliação no navegador passa a ler sempre do lado correto (pergunta condicionada) e a responder imediatamente à mudança da pergunta gatilho.
- **Edição de respostas**: por decisão de produto (alinhada ao plano de simplificação do componente), a funcionalidade de editar uma resposta já enviada é **removida** — o participante responde uma única vez; a infraestrutura compartilhada do `decidim-forms` é preservada apenas onde outros consumidores dependem dela.
- **Exportação**: a exportação passa a conter apenas perguntas respondíveis, com cabeçalhos sem marcação HTML e sem colunas vazias geradas por separadores e blocos de título/descrição.
- **Arquivos**: o limite máximo de arquivos passa a ser configurável na pergunta (reutilizando o conceito de limite de opções) e é exibido ao participante; o envio respeita os limites da organização (extensões permitidas e tamanho máximo); o detalhe da resposta passa a permitir **visualizar/baixar** os documentos anexados; e o campo de arquivo informa previamente o número máximo de arquivos, as extensões aceitas e o tamanho máximo.
- **Numeração**: as perguntas respondíveis do formulário são numeradas automaticamente na exibição, ignorando separadores e blocos de título.

Grande parte dessas correções **já está implementada na branch atual**; esta spec funciona como contrato de comportamento único: (a) detalha e padroniza o que já foi feito para validação e regressão, e (b) define o trabalho ainda pendente (exibição de anexos no detalhe/confirmação, informação prévia de extensões/limites e numeração automática). Cada seção indica o estado — **implementado** ou **pendente** — para que o time saiba o que validar e o que construir.

## Histórias de usuário

### Estado do formulário e janela de respostas

1. Como administrador de uma pesquisa, quero que o formulário seja considerado **aberto** somente quando a opção "Permite respostas" estiver ativa **e** a data atual estiver dentro da janela configurada, para que o selo de estado exibido corresponda à realidade.
2. Como administrador de uma pesquisa, quero que um formulário com "Permite respostas" desativado apareça como encerrado mesmo que as datas de vigência ainda estejam válidas, para que eu possa usar o interruptor como controle explícito de abertura.
3. Como administrador de uma pesquisa, quero que um formulário com janela futura ou já vencida apareça como encerrado mesmo com "Permite respostas" ativo, para que as datas sejam respeitadas.
4. Como administrador, quero que o estado exibido na listagem administrativa e na página pública do formulário venham da mesma definição, para que não haja contradição entre telas.
5. Como participante, quero ver o aviso de formulário encerrado quando a pesquisa não estiver aceitando respostas, para entender por que não posso responder.

### Bloqueio de submissões em formulário encerrado

6. Como administrador, quero que nenhuma resposta seja gravada quando o formulário estiver encerrado, para que os dados coletados reflitam apenas o período válido.
7. Como participante, quero que tentativas de envio fora da janela (inclusive por requisição direta, sem passar pela interface) sejam recusadas com uma mensagem clara, para que eu não acredite que minha resposta foi aceita.
8. Como participante, quero poder responder normalmente dentro da janela, sem bloqueios indevidos, para que a correção não prejudique quem responde no prazo.
9. Como administrador, quero que respostas já enviadas antes do fechamento permaneçam íntegras e visíveis, para que o bloqueio afete apenas novos envios.

### Condicionantes

10. Como administrador, quero configurar uma condição de exibição (por exemplo, "mostrar pergunta B se a resposta de A for 'Sim'") e ver o questionário se comportar exatamente como configurado, para que eu possa criar formulários adaptativos.
11. Como participante, quero que perguntas condicionadas apareçam/desapareçam imediatamente conforme minhas respostas, sem precisar recarregar a página.
12. Como administrador, quero salvar e reabrir o editor de perguntas sem que as condições sejam duplicadas, trocadas de dono ou apontem para si mesmas, para que a configuração não se corrompa a cada salvamento.
13. Como administrador, quero remover ou reordenar uma pergunta gatilho sem quebrar as condições das perguntas dependentes.
14. Como participante, quero que perguntas condicionadas que não devem aparecer não sejam exibidas nem exigidas, para que eu não receba campos sem sentido.
15. Como administrador de respostas, quero que a exportação considere as respostas efetivamente dadas às perguntas condicionadas exibidas, sem linhas/colunas fantasmas.

### Edição de respostas (remoção)

16. Como participante, quero responder a uma pesquisa uma única vez e, após o envio, não encontrar um botão de editar respostas, para que o fluxo seja simples e previsível.
17. Como participante, quero receber uma confirmação clara de que minha resposta foi registrada e que não poderei alterá-la depois, para evitar expectativas erradas.
18. Como administrador, quero que a configuração de pesquisa não ofereça mais a opção "permitir edição de respostas", para que a interface administrativa reflita o comportamento real.
19. Como administrador, quero que tentativas de reenvio por um mesmo participante sejam recusadas como resposta duplicada, para que não haja respostas múltiplas por participante.

### Exportação

20. Como administrador, quero exportar as respostas (CSV/JSON/Excel/PDF) com cabeçalhos limpos, sem marcação HTML, para que o arquivo abra corretamente em planilhas.
21. Como administrador, quero que o export contenha apenas perguntas respondíveis (sem colunas vazias de separadores e blocos de título), para que a leitura dos dados seja objetiva.
22. Como administrador, quero que o último item da exportação saia completo e bem-formado, para que nenhuma resposta seja perdida ou truncada.

### Arquivos: limite, extensões e visualização

23. Como administrador, quero definir o número máximo de arquivos que o participante pode anexar a uma pergunta do tipo arquivo, para controlar o volume de uploads.
24. Como participante, quero ver, antes de enviar, quantos arquivos posso anexar no máximo, para não tentar enviar além do permitido.
25. Como participante, quero ser alertado imediatamente quando ultrapassar o limite de arquivos, para corrigir antes de enviar o formulário.
26. Como participante, quero saber quais extensões de arquivo são aceitas e o tamanho máximo por arquivo, para preparar anexos válidos.
27. Como participante, quero que o envio de arquivos fora das extensões/tamanho permitidos seja recusado com mensagem clara, para não perder tempo com anexos inválidos.
28. Como administrador, quero que os limites de extensão e tamanho da organização sejam aplicados às perguntas de arquivo dos formulários, para manter a política de upload consistente em toda a plataforma.
29. Como participante, quero, ao revisar ou confirmar minha resposta (e nas telas somente leitura), conseguir **ver e abrir** os documentos que anexei, para conferir que foram enviados corretamente.
30. Como administrador de respostas, quero visualizar e baixar os documentos anexados a cada resposta no detalhe da resposta, para auditar o conteúdo recebido sem depender da exportação.

### Numeração das questões

31. Como participante, quero que as perguntas de um formulário apareçam numeradas automaticamente (1, 2, 3…), pulando separadores e blocos de título, para facilitar a navegação e a referência a perguntas.
32. Como administrador, quero que a numeração exibida ao participante seja estável e coerente com a ordem das perguntas no editor, para que referências cruzadas façam sentido.
33. Como participante de formulários em etapas, quero que a numeração continue correta ao longo das etapas, para não me perder em questionários longos.

## Decisões de implementação

Esta seção registra as decisões de desenho e os pontos de mudança por módulo. **Não** lista caminhos de arquivo nem trechos de código (podem ficar obsoletos); descreve módulos, interfaces e contratos.

### Estado "aberto" com fonte única de verdade — implementado

- A definição canônica de pesquisa aberta passa a ser: **`Permite respostas` ativo** e, se houver janela, `starts_at <= agora < ends_at` (ou janela indefinida, ou apenas início/ou apenas fim). O escopo de consulta `Survey.open` e o predicado de instância correspondente **devem concordar** entre si.
- Correção aplicada no modelo da pesquisa: o escopo de consulta passou a combinar o filtro `allow_responses` com a lógica de janela usando conjunção (antes, a janela era avaliada sem o filtro, contando como abertas pesquisas com respostas desativadas dentro do período).
- As telas de estado (listagem administrativa e página pública) devem derivar do mesmo predicado — nenhuma regra paralela de datas no controlador ou na visão.
- Regressão coberta por testes de modelo: pesquisas com respostas desativadas dentro do período não constam como abertas; pesquisas futuras e vencidas não constam como abertas; pesquisas sem janela e com respostas ativas constam como abertas.

### Bloqueio de submissões em pesquisas fechadas — implementado

- A permissão de ação `respond` continua sendo concedida de forma ampla (por projeto), portanto o controlador público ganhou uma **guarda explícita** antes de processar o envio: se a pesquisa não estiver aberta (predicado único acima), a submissão é recusada com redirecionamento e aviso, sem gravar nada.
- O aviso de formulário encerrado continua sendo o fluxo visível para o participante na página pública.
- Não há mudança de contrato na API GraphQL para envio; o bloqueio é aplicado no ponto de entrada HTTP do formulário.
- Testes de controlador cobrem: pesquisa fechada por respostas desativadas, por janela futura e por janela vencida; e pesquisa aberta aceitando normalmente.

### Condicionantes com dono correto — implementado

- Cada condição de exibição é **propriedade da pergunta condicionada** (a pergunta que depende de outra); o editor administrativo não deve gravá-la na pergunta gatilho nem duplicá-la nos dois lados.
- Uma migração de dados remove condições **auto-referentes** eventualmente gravadas por versões anteriores (pergunta condicionada apontando para si mesma).
- A operação de salvar/reordenar perguntas não deve recriar condições órfãs nem reatribuir o dono; persistir a edição preserva exatamente o conjunto de condições configurado.
- A avaliação no navegador lê as condições do elemento da pergunta condicionada e escuta as mudanças da pergunta gatilho (mesmo mecanismo atualizado, agora com dados íntegros).
- Testes de modelo cobrem: associação correta (condição pertence à condicionada), ausência de auto-referência e não duplicação ao re-salvar; testes de unidade do comando administrativo cobrem o salvamento repetido.

### Remoção da edição de respostas — implementado (decisão de produto)

- A pesquisa (componente *surveys*) deixa de oferecer edição de respostas já enviadas: some a coluna/setting "permitir edição", a rota e a ação públicas de edição, o campo no GraphQL, o link "editar minha resposta" e o template de edição.
- Após responder, o participante vê apenas a confirmação/anúncio; qualquer novo envio é tratado como resposta duplicada (`inválido`).
- **Preservação deliberada de infraestrutura**: o mecanismo compartilhado do `decidim-forms` (adicionar respostas com suporte a reenvio) é mantido porque outros consumidores (ex.: módulo de coleta demográfica) dependem dele — a remoção é feita no componente *surveys*, não no mecanismo genérico.
- Testes: remoção dos exemplos compartilhados e specs de sistema que exercitavam a edição; specs que garantem que o link/rota de edição não existem mais; regressão de que o fluxo normal de resposta única continua funcionando.

### Exportação limpa e só com perguntas respondíveis — implementado

- O serializador de respostas do questionário passa a **ignorar perguntas estruturais** (separadores e blocos de título/descrição) ao montar as linhas, evitando colunas vazias e artefatos.
- Os **cabeçalhos** (títulos das perguntas) são gerados sem marcação HTML — o texto é extraído/limpo antes de virar coluna — eliminando o "HTML quebrado" no último item e em qualquer coluna com rich text.
- Como consequência positiva, a exportação também fica mais leve (menos colunas e menos processamento).
- Testes do serializador cobrem: ausência de colunas para perguntas estruturais, cabeçalhos sem HTML e conteúdo íntegro das respostas (inclusive texto livre e matriz).

### Limite máximo de arquivos em perguntas do tipo arquivo — implementado

- O atributo de limite de opções (`max_choices`) passa a ter segundo papel quando a pergunta é do tipo arquivo: **número máximo de arquivos anexáveis**; o rótulo exibido alterna entre "máximo de opções" e "máximo de arquivos" conforme o tipo da pergunta.
- A pergunta exibe ao participante o limite configurado; o componente de alerta de limite é ativado também para arquivos (além de múltipla escolha).
- O formulário de resposta valida o número de anexos contra o limite (lado servidor), e o alerta client-side previne exceder o limite antes do envio.
- A interface administrativa permite configurar o limite mínimo e rotula o campo de acordo com o tipo de arquivo.
- Testes: formulário administrativo (limite mínimo, rótulo), formulário de resposta (validação), e teste de sistema cobrindo exibição do limite, tentativa de exceder e envio válido.

### Extensões e tamanho permitidos vindos da organização — implementado

- O controle de anexo das perguntas de arquivo passa a receber, na montagem da página, a **política de upload da organização**: extensões permitidas e tamanho máximo por arquivo (mesmas fontes usadas pelo restante da plataforma).
- O servidor mantém a validação efetiva; o controle já repassa os parâmetros ao componente de upload, de modo que mensagens de erro usem a política real.
- Testes: exemplo compartilhado de questionário com política configurada exercitando o repasse e a recusa de arquivo inválido.

### Exibição de documentos anexados na confirmação/detalhe — pendente

- **Contrato a implementar**: em todos os pontos onde uma resposta é apresentada para leitura — detalhe da resposta no painel administrativo e visões somente leitura do questionário —, os anexos de perguntas do tipo arquivo devem aparecer como **lista de documentos clicáveis** (abrir/baixar), e não apenas como texto puro ou omitidos.
- Decisões esperadas: reutilizar o componente padrão de exibição de anexos do núcleo (mesma apresentação usada em outras áreas da plataforma); os metadados de cada arquivo (nome, extensão, tamanho) devem estar disponíveis no objeto de resposta exibido; links de download devem passar pelas rotas seguras já existentes para anexos.
- Critério de aceite: um administrador que abre o detalhe de uma resposta com documentos consegue ver o nome de cada arquivo e abri-lo; um participante numa tela somente leitura (quando aplicável) consegue ver os próprios anexos.
- Sem mudança de esquema esperada: a associação de anexos por resposta já existe; a pendência é de apresentação/dados no ponto de leitura.

### Informação prévia sobre arquivos (quantidade, extensões e tamanho) — pendente

- **Contrato a implementar**: junto ao campo de envio de arquivos, o participante deve ver um texto de apoio com: número máximo de arquivos (quando configurado), extensões aceitas (da política da organização) e tamanho máximo por arquivo.
- O texto deve ser gerado a partir das mesmas configurações usadas na validação (nada de texto manual divergente); quando não houver limite de quantidade, apenas extensões/tamanho são informados.
- Critério de aceite: a mensagem exibida reflete exatamente o que o servidor valida; não há exibição quando não há restrição alguma configurada.

### Numeração automática das questões — pendente

- **Contrato a implementar**: a renderização pública do questionário numera as perguntas respondíveis em ordem, ignorando separadores e blocos de título/descrição; a numeração acompanha a ordem real das perguntas (campo de ordenação) e continua correta em formulários com etapas.
- Decisões esperadas: numeração calculada na apresentação (sem coluna nova em banco), reiniciada por etapa ou contínua conforme o padrão de navegação escolhido; blocos estruturais não consomem número.
- Critério de aceite: em um questionário com 2 separadores e 5 perguntas, as perguntas aparecem numeradas de 1 a 5; em questionário em etapas, a contagem flui sem saltos/duplicações.

## Decisões de teste

Princípios:

- **Testar comportamento externo**, não implementação: os testes devem descrever "o que o participante/administrador observa", e não nomes de métodos internos.
- **Um único contrato de estado**: os casos de "aberto/fechado" devem ser exercitados no nível de modelo (escopo/predicado) e repetidos no nível de sistema apenas nos fluxos mais relevantes (envio negado com aviso, selo correto na página).
- **Prior art já existente na suíte**: specs de modelo da pesquisa (escopos e predicados), specs de controlador do fluxo público (guarda de envio), specs de serializador de respostas, exemplos compartilhados de administração de questionários e specs de sistema do componente *surveys*. As correções implementadas devem manter essas suítes verdes; novas pendências devem seguir os mesmos padrões.

Pontos de teste por estado:

- **Implementado (validação/regressão)**: modelo (escopos com `allow_responses` e janela), controlador (POST em fechada/futura/vencida negado; aberta aceita), formulário de resposta (limite de arquivos, extensões/tamanho da organização), serializador (sem colunas estruturais, cabeçalhos sem HTML), comando administrativo e modelo de pergunta (condicionantes com dono correto, sem auto-referência), remoção de edição (rota/UI/link ausentes, duplicidade rejeitada).
- **Pendente (a escrever junto com a implementação)**: detalhe da resposta com anexos clicáveis (spec administrativa + exemplo compartilhado), texto de apoio do campo de arquivo (spec de sistema do componente e spec de view), numeração automática (spec de sistema do componente com separadores e etapas; spec de unidade para o cálculo da numeração se houver helper).

Recomendações de execução:

- Rodar as suítes completas de `decidim-forms` e `decidim-surveys` (podem levar dezenas de minutos — não cancelar).
- Adicionar os testes novos de pendências na mesma branch/PR das pendências, em vermelho primeiro quando o comportamento ainda não existir.
- Para mensagens e textos, manter chaves de tradução em inglês no arquivo base e só então as traduções em pt-BR (fluxo Crowdin), conforme convenção do projeto.

## Fora de escopo

- **Correções em outros consumidores do questionário** (ex.: reuniões com formulário de inscrição, coleta demográfica): esta spec trata do componente *surveys* e do mecanismo compartilhado apenas onde os defeitos listados ocorrem.
- **Performance da exportação em larga escala** (exportação em segundo plano, streaming, limpeza de exportações privadas): registrada como follow-up próprio.
- **Outras fases do plano de simplificação do componente** (publicação de respostas por pergunta, um survey por componente, resposta anônima): decisões separadas, fora desta spec.
- **Ajustes visuais gerais** não relacionados aos fluxos listados.
- **Correções de upstream**: não se espera sincronizar estas mudanças com o Decidim oficial nesta etapa (fork deliberado).

## Notas adicionais

- As correções "implementado" desta spec correspondem às mudanças de QA de agosto/2026 registradas na branch (`Survey.open` respeitando `allow_responses` na janela; guarda de submissão em pesquisa fechada; dono das condicionantes; remoção da edição de respostas; exportação sem HTML e sem perguntas estruturais; `max_choices` como limite de arquivos; política de upload da organização nas perguntas de arquivo) e já possuem cobertura de testes revisada (ver `revisao-testes-surveys-forms.md`).
- Itens **pendentes** (anexos no detalhe/confirmação, texto de apoio de extensões/limites e numeração automática) devem ser abertos como tarefas de implementação com base nos contratos desta spec.
- Registrar mudanças relevantes no `RELEASE_NOTES.md` do fork quando houver release.
- A semântica do interruptor "Permite respostas" precisa ficar explícita na documentação de uso administrativo: é o controle de abertura independente das datas.
