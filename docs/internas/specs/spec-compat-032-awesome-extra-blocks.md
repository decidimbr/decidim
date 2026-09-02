# Spec — Compatibilização do Decidim Awesome e Extra Blocks com o Decidim 0.32

> Status: ready-for-agent
>
> Data: 2026-09-01
> Módulos afetados: módulos externos vendorizados `decidim-decidim_awesome` (0.14.4) e `decidim-extra_blocks` (0.1.0), dependências associadas, e integração com o núcleo 0.32.1 (branch `internalize/qa-fixes-v0.32.1`)
> Situação: **compatibilização implementada** — esta spec detalha o que foi feito e define o plano de validação e teste

---

## Declaração do problema

A plataforma utiliza dois módulos externos do ecossistema Decidim que precisam rodar sobre o fork 0.32.1:

- **Decidim Awesome** (usabilidade e ajustes de UX com configuração granular por espaço/componente);
- **Extra Blocks** (blocos de conteúdo por layout — CTA, hero, proposta rápida etc. — para as páginas iniciais de organização, processos, grupos e assembleias).

Após a migração para o Decidim 0.32, a compatibilidade deixou de existir por três frentes:

1. **Quebra de arranque por código removido no 0.32**: o Awesome aplica *patches* (inclusão de módulos/sobrescritas) sobre constantes do núcleo que **foram removidas no 0.32** — rascunhos colaborativos de propostas e a célula de bloco de conteúdo de menu global. Sem tratamento, o motor do módulo falha ao subir com erro de constante inexistente.
2. **Mudança do empacotador de ativos**: o Decidim 0.32 renomeou o `Decidim::Webpacker` para `Decidim::Shakapacker`; o Extra Blocks registrava seus ativos JavaScript pelo nome antigo e deixava de carregá-los.
3. **Dependências e idioma**: o Extra Blocks depende de módulos auxiliares e o conteúdo voltado ao participante precisa estar em português — as cadeias exibidas nesta implantação precisavam ser preenchidas em pt-BR.

Além disso, módulos vendorizados precisam ser **testados dentro do contexto do monorepo** (mesmo núcleo, mesmas versões de Ruby/Node) para garantir que continuam funcionando a cada evolução do fork.

## Solução

Internalizar (vendorizar) e compatibilizar os dois módulos no monorepo, de forma que subam com o Decidim 0.32.1 e sejam versionados junto com o fork:

1. **Vendorização**: os módulos passam a viver em diretórios próprios dentro do repositório e são declarados como gems de caminho no `Gemfile` do fork, com suas dependências associadas (`deface`, `sassc`, e os módulos `decidim-toggle` e `decidim-ephemeral_participation` exigidos pelo Extra Blocks, apontando para as fontes oficiais).
2. **Faixas de compatibilidade**: o Awesome passa a declarar compatibilidade com Decidim `>= 0.31` e `< 0.33`; o Extra Blocks declara `>= 0.29` e `< 0.33`, alinhando os dois ao 0.32.1 do fork.
3. **Guardas de arranque no Awesome**: os *patches* sobre constantes que não existem mais no 0.32 (rascunhos colaborativos e bloco de menu global) só são aplicados **quando a constante existir**, eliminando a falha de boot sem perder os *patches* em versões futuras que reintroduzam as constantes.
4. **Registro de ativos do Extra Blocks**: o registro de caminhos e entrypoints JavaScript passa a usar o empacotador ativo no 0.32 (`Decidim::Shakapacker`), com retrocompatibilidade para o nome antigo.
5. **Limpeza de integração**: removida uma inclusão de helper não utilizada que quebrava no 0.32 na célula de formulário de proposta rápida.
6. **Idioma**: as cadeias de interface do Extra Blocks usadas na implantação são preenchidas em português (pt-BR), já que os participantes navegam a plataforma em português.
7. **Validação e teste (esta spec)**: matriz de validação das funcionalidades efetivamente ativas na instância (administração, páginas públicas e blocos de conteúdo), execução das suítes dos módulos contra o núcleo do fork e checagens de regressão de arranque/ativos.

## Histórias de usuário

### Decidim Awesome — administração e participação

1. Como administrador, quero que a plataforma suba normalmente com o Awesome instalado, sem erros de constante no arranque, para que nenhum ajuste de UX dependa de gambiarras de boot.
2. Como administrador, quero acessar o painel administrativo do Awesome e visualizar a lista de ajustes disponíveis com seus escopos, para configurar quais *tweaks* valem em cada espaço/componente.
3. Como administrador, quero salvar alterações de configuração de um ajuste e ver o efeito imediato na área correspondente, para calibrar a experiência por espaço.
4. Como administrador, quero que ajustes de propostas (campos customizados, votação, visibilidade) funcionem nos fluxos públicos e administrativos de propostas do 0.32, para manter as capacidades contratadas.
5. Como administrador, quero que os blocos de conteúdo registrados pelo Awesome (processos em destaque, rich text, menu etc.) possam ser adicionados às páginas iniciais, para compor a home sem desenvolvimento.
6. Como participante, quero interagir com os recursos ativados pelo Awesome (formulários de proposta com campos adicionais, votações especiais, conteúdos em destaque) sem erros de interface, para que a experiência seja consistente com o restante da plataforma.
7. Como administrador, quero que ajustes não aplicáveis ao 0.32 (baseados em funcionalidades removidas, como rascunhos colaborativos) simplesmente não apareçam nem quebrem, para que a configuração reflita o que existe na versão.

### Extra Blocks — conteúdo e páginas iniciais

8. Como administrador de conteúdo, quero adicionar um bloco de conteúdo com layout escolhido (galeria de layouts: CTA, hero, proposta rápida etc.) à página inicial da organização, de um processo, de um grupo de processos ou de uma assembleia, para montar a página com seções prontas.
9. Como administrador de conteúdo, quero configurar as opções específicas do layout escolhido (imagens, textos, botões, métricas, vídeo), para personalizar a seção sem escrever código.
10. Como administrador de conteúdo, quero que os ativos JavaScript e estilos do Extra Blocks sejam carregados no 0.32, para que os blocos renderizem com interação e aparência corretas.
11. Como participante, quero ver as seções criadas com os blocos (CTA, hero, proposta rápida) renderizadas corretamente em celular e desktop, para uma navegação agradável.
12. Como participante, quero usar o formulário rápido de proposta dos blocos (quando ativado) e ser levado ao fluxo normal de criação, para participar com poucos cliques.
13. Como participante, quero que os textos desses blocos estejam em português, para que o conteúdo institucional faça sentido.
14. Como administrador, quero que mudanças de configuração de um bloco respeitem o cache e apareçam após a publicação, para não exibir conteúdo parcial.

### Engenharia e manutenção do fork

15. Como pessoa desenvolvedora, quero que os módulos vendorizados estejam no controle de versão do fork com as compatibilizações, para que o ambiente seja reproduzível sem depender de versões futuras dos mantenedores.
16. Como pessoa desenvolvedora, quero rodar as suítes de teste dos módulos contra o núcleo do fork em CI, para detectar quebras de compatibilidade a cada mudança no núcleo.
17. Como pessoa desenvolvedora, quero uma checagem de arranque que falhe claramente se um *patch* do Awesome voltar a referenciar constante inexistente, para pegar o problema no teste e não em produção.
18. Como pessoa desenvolvedora, quero validar que a pré-compilação de ativos e de *deface* (usada na imagem de produção) funciona com os módulos, para que o deploy não quebre na etapa de build.

## Decisões de implementação

> As decisões 1 a 6 já foram implementadas na branch. As seções 7 em diante definem o trabalho de validação e teste detalhado desta spec.

### 1. Vendorização dos módulos — implementado

- Os módulos `decidim_awesome` e `extra-blocks` são versionados em diretórios de módulos vendorizados no monorepo e declarados como **gems de caminho** no `Gemfile` do fork, junto com as dependências que o Extra Blocks exige (`decidim-toggle` e `decidim-ephemeral_participation`, a partir das fontes oficiais, além de `deface` e `sassc`).
- Efeito esperado: `bundle install` reproduz exatamente o conjunto de módulos desta implantação; upgrades futuros do fork passam a exigir revisão explícita dos módulos vendorizados.

### 2. Faixas de compatibilidade — implementado

- O Awesome (versão 0.14.4) declara compatibilidade com Decidim `[">= 0.31", "< 0.33"]`.
- O Extra Blocks (versão 0.1.0) declara compatibilidade com Decidim `[">= 0.29", "< 0.33"]`.
- Ambas as faixas cobrem o 0.32.1 do fork e impedem instalação acidental com versões fora da faixa.

### 3. Guardas de arranque no motor do Awesome — implementado

- Os *patches* do motor que referenciam `CreateCollaborativeDraft`, `UpdateCollaborativeDraft`, `CollaborativeDraft` e o bloco de conteúdo de menu global passam a ser condicionados à **existência das constantes** em tempo de execução.
- Consequência: no 0.32 (onde rascunhos colaborativos e o bloco de menu global foram removidos), o motor sobe normalmente e apenas omite esses *patches*; se uma versão futura do núcleo reintroduzir as constantes, os *patches* voltam a ser aplicados automaticamente.

### 4. Registro de ativos do Extra Blocks — implementado

- O registro de ativos do Extra Blocks passou a detectar o empacotador em uso: `Decidim::Shakapacker` no 0.32 (nome novo) com retrocompatibilidade para `Decidim::Webpacker`.
- O entrypoint JavaScript do módulo é registrado pelo nome do empacotador ativo, garantindo que os assets sejam compilados e servidos no 0.32.

### 5. Limpeza de integração — implementado

- Removida a inclusão de um helper de escopos não utilizada na célula do formulário de proposta rápida do Extra Blocks, que apontava para código inexistente no 0.32.

### 6. Idiomas — implementado

- As cadeias de interface do Extra Blocks exibidas nesta implantação foram preenchidas em **português (pt-BR)** (arquivos de locale do módulo), já que os participantes navegam a plataforma em português.

### 7. Matriz de validação por funcionalidade — a executar

- **Levantamento prévio**: em staging/produção, inventariar os ajustes do Awesome ativos (configuração por espaço/componente) e os blocos de conteúdo do Extra Blocks efetivamente publicados (por página inicial), gerando a lista concreta de funcionalidades a validar.
- Para cada item do inventário, validar: carregamento sem erro no console, aparência correta (desktop/mobile), fluxo completo de ponta a ponta e persistência da configuração.
- Cobertura mínima sugerida para o Awesome: painel administrativo (listar/salvar ajustes), editor de conteúdo (campos adicionais e formatação), fluxo de propostas (criação pública e administrativa com os campos customizados ativos) e blocos de conteúdo registrados.
- Cobertura mínima sugerida para o Extra Blocks: adicionar/configurar cada tipo de layout usado na instância nas páginas iniciais aplicáveis; validar o formulário rápido de proposta quando ativo; validar responsividade e cache de publicação.

### 8. Checagens de regressão automatizadas — a executar

- **Arranque**: o conjunto de testes do fork deve incluir uma checagem de boot da aplicação com os dois módulos carregados (sem erro de constante) — executada na geração do ambiente de teste.
- **Pré-compilação**: validar no pipeline que os passos de produção da imagem (pré-compilação de *deface* e de assets) concluem com os módulos vendorizados.
- **Suítes dos módulos**: executar as suítes de especificação de cada módulo vendorizado dentro do contexto do fork (mesmo núcleo e mesmas versões de Ruby/Node), com atenção especial às specs que exercitam os pontos de integração alterados (motor do Awesome e registro de ativos do Extra Blocks).
- **Estilo e tradução**: rodar as checagens padrão do projeto (rubocop, erblint, lint de JavaScript) sobre o código tocado nos módulos e validar a sintaxe/completeza dos arquivos de locale.

## Decisões de teste

Princípios:

- **Testar o comportamento de integração, não o código dos módulos**: o fork deve garantir que os módulos sobem, registram seus ativos e funcionam com o núcleo 0.32; a validação funcional detalhada de cada ajuste/bloco é feita por matriz de validação (item 7), complementada pelas suítes próprias dos módulos.
- **Prior art**: cada módulo vendorizado já traz sua própria infraestrutura de testes (suítes com aplicação dummy própria, exemplos de specs de sistema e de unidades) e documentação interna de convenções/testes; as checagens do fork devem **reutilizar essas suítes** dentro do contexto do monorepo, em vez de duplicar cobertura.
- **Falhe cedo no arranque**: prefere-se um teste que detecte erro de boot/constante no ambiente de teste a descobrir o problema em produção.

Pontos de teste:

1. **Boot com módulos**: ambiente de teste gerado com os dois módulos no `Gemfile` sobe sem exceção; qualquer referência a constante removida no 0.32 falha o teste.
2. **Registro de ativos**: a pré-compilação inclui os entrypoints do Extra Blocks e do Awesome; página com bloco do Extra Blocks carrega o pacote JavaScript correspondente.
3. **Suítes dos módulos no contexto do fork**: rodar as suítes de `decidim_awesome` e `extra-blocks` (unidade + sistema) contra o núcleo 0.32.1; tratar falhas como regressão de compatibilidade.
4. **Smoke de integração (matriz)**: para os ajustes/blocos ativos na instância, specs de sistema ou checklist manual versionado que percorra os fluxos principais das histórias de usuário (configurar ajuste → validar efeito; adicionar bloco → validar renderização e idioma).
5. **Pipeline de produção**: o build da imagem executa os passos de pré-compilação com sucesso (já previsto no fluxo de deploy) e o healthcheck da aplicação responde com os módulos ativos.

Recomendações de execução: as suítes dos módulos podem ser longas — nunca cancelar; rodar primeiro as suítes dos módulos isoladamente e depois o smoke de integração; registrar os resultados da matriz de validação num documento de acompanhamento (modelo: tabela com funcionalidade, ambiente, status e evidência).

## Fora de escopo

- **Novos recursos** dos módulos (tweaks ou layouts ainda não usados na instância): apenas os ativos/inventariados são validados; o restante permanece disponível mas não é escopo desta spec.
- **Upstream**: não há compromisso de enviar as compatibilizações aos mantenedores dos módulos nesta etapa (estratégia de fork deliberada); atualizações futuras dos módulos exigirão reaplicar as guardas, se necessário.
- **Migração de dados** de configuração do Awesome entre versões: validar apenas que a configuração existente carrega e salva no 0.32.
- **Módulos externos não vendorizados** (ex.: demais gems do ecossistema fora do `Gemfile` do fork).
- **Aparência/identidade visual** dos blocos além da verificação de renderização correta.

## Notas adicionais

- O build de produção já executa a pré-compilação de *deface* e de assets com os módulos presentes; manter esses passos no pipeline é condição de aceite para futuras mudanças no núcleo.
- Riscos a acompanhar: versões futuras do núcleo podem remover outras constantes usadas pelos módulos (a checagem de boot automatizada existe para detectar isso); e atualizações dos módulos vendorizados podem trazer dependências novas (validar no `Gemfile.lock`).
- Documentar no `RELEASE_NOTES.md` do fork a presença dos módulos e as faixas de compatibilidade suportadas.
- Para novas mudanças nos módulos, seguir as convenções internas documentadas nos próprios diretórios vendorizados (traduções na língua base primeiro, depois pt-BR; specs junto com código).
