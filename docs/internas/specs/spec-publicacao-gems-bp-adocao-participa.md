# Spec — Publicação das correções de Formulários/Pesquisas como gems `bp-decidim-*` para adoção pelo participa

> Status: ready-for-agent
>
> Data: 2026-09-01
> Base: monorepo do fork (branch `internalize/qa-fixes-v0.32.1`, Decidim 0.32.1)
> Contexto: PRD "Publicação de gems `bp-*` no RubyGems" (rascunho, 2026-08-26) — usado como referência de contexto; esta spec é o **recorte mínimo operacional** daquele programa
> Repositório downstream: `gitlab.com/lappis-unb/decidimbr/participa` (hoje em Decidim 0.30)

---

## Declaração do problema

As correções de núcleo de formulários e pesquisas especificadas na spec 1 vivem neste monorepo, que é um fork do Decidim. O projeto downstream — a instância do **participa** (hoje em Decidim 0.30) — precisa **internalizar essas correções o quanto antes**. Não há hoje um caminho limpo para isso: consumir o monorepo exige clonar o repositório inteiro ou usar `path:`/`git:` no Gemfile, o que não versiona semanticamente, não escala e se confunde com as gems oficiais do upstream.

O PRD já desenha o programa de publicação no RubyGems sob o namespace `bp-*`. Esta spec **não** executa o programa inteiro: ela entrega o **recorte mínimo** que destrava o participa — publicar as duas gems modificadas que carregam as correções da spec 1 (`bp-decidim-forms` e `bp-decidim-surveys`) — e registra que:

- a **colaboração com o núcleo** (upstream Decidim) e com os **módulos extras** (Awesome, Extra Blocks e afins) acontece **através dos repositórios próprios** de cada um e **não é trabalho desta spec**;
- metas de versão futura do upstream presentes no PRD **não fazem sentido agora** e ficam fora; a publicação parte da base atual do fork (0.32.1).

## Solução

Publicar no RubyGems, a partir das fontes locais deste monorepo, duas gems com as correções da spec 1, mantendo intactos namespaces, requires e diretórios:

| Gem publicada | Origem local | Conteúdo | Dependências |
|---|---|---|---|
| `bp-decidim-forms` | `decidim-forms/` (modificada) | Correções de questionários da spec 1 (condicionantes, exportação, limites/arquivos) | `decidim-core` upstream (gem oficial) |
| `bp-decidim-surveys` | `decidim-surveys/` (modificada) | Correções de pesquisas da spec 1 (janela/`allow_responses`, bloqueio de envio, remoção de edição) | `decidim-core` upstream + **`bp-decidim-forms`** |

- **Consumo pelo participa com uma linha**: como `bp-decidim-surveys` depende de `bp-decidim-forms`, o Gemfile do participa passa a usar apenas `gem "bp-decidim-surveys", "~> 0.32.1.bp1"` após o upgrade dele de versão.
- **Versão**: sincronizada à base atual do fork — `0.32.1.bp1`, `bp2`, … (sufixo `bpN` para as customizações locais). A spec não agenda versões futuras do upstream: quando o fork mudar de base, o próximo sufixo é definido em release própria.
- **Namespace preservado**: o nome da gem no registro muda (`bp-decidim-*`), mas `Decidim::Forms`/`Decidim::Surveys`, os `require`s e os diretórios físicos permanecem os mesmos.
- **Processo de release manual e reproduzível** (primeira publicação): renomear os gemspecs (nome, autores, homepage/metadata para o repositório do fork, `allowed_push_host`), adaptar o mecanismo de release do repositório (hoje exige o remote `decidim/decidim`) para o remote do fork, e publicar na ordem `bp-decidim-forms` → `bp-decidim-surveys`, com credenciais RubyGems e MFA.
- **Validação de downstream**: aplicação dummy consumindo as gems publicadas (não `path:`) para provar a resolução e o comportamento das correções antes de anunciar a adoção.

## Histórias de usuário

1. Como mantenedora ou mantenedor da distribuição, quero publicar `bp-decidim-forms` e `bp-decidim-surveys` no RubyGems a partir da base atual do fork (0.32.1), para disponibilizar as correções da spec 1 ao participa o quanto antes.
2. Como mantenedora ou mantenedor, quero que a versão das gems acompanhe a base atual (`0.32.1.bp1`, `bp2`, …), para que a compatibilidade com o Decidim seja previsível sem amarras a versões futuras do upstream.
3. Como mantenedora ou mantenedor, quero que os namespaces Ruby, os `require`s e os diretórios físicos permaneçam inalterados nas gems publicadas, para que engines, rotas, migrações e integrações existentes continuem funcionando.
4. Como mantenedora ou mantenedor, quero que `bp-decidim-surveys` declare dependência de `bp-decidim-forms` (trava de versão pré-release), para que quem instalar surveys receba forms automaticamente na versão correta.
5. Como mantenedora ou mantenedor, quero que as dependências não-renomeadas (`decidim-core`) venham das gems oficiais do upstream na versão compatível, para não duplicar o núcleo.
6. Como mantenedora ou mantenedor, quero um processo de release reproduzível (build → tag no remote do fork → `gem push`) na ordem forms → surveys, para não quebrar a resolução do Bundler.
7. Como mantenedora ou mantenedor, quero que os metadados das gems (autores, homepage, repositório) apontem para o fork, para que issues e contribuições cheguem ao lugar certo.
8. Como mantenedora ou mantenedor, quero validar a instalação das gems publicadas numa aplicação dummy antes de anunciar a release, para garantir que o `bundle install` resolve e as correções se comportam como esperado.
9. Como mantenedora ou mantenedor, quero publicar somente com as suítes de formulários e pesquisas verdes, para não distribuir regressões.
10. Como pessoa desenvolvedora do participa, quero internalizar as correções de formulários/pesquisas adicionando uma única linha ao Gemfile (`gem "bp-decidim-surveys", "~> 0.32.1.bp1"`) após o upgrade de versão, para não clonar o monorepo nem gerenciar paths locais.
11. Como pessoa desenvolvedora do participa, quero que `require "decidim/forms"` e `require "decidim/surveys"` continuem funcionando como no upstream, para não reescrever código existente.
12. Como equipe do participa, quero manter a instância atual em 0.30 funcionando sem alterações (sem backport), com a adoção das gems ocorrendo no upgrade de versão, para não arriscar produção antes da hora.
13. Como equipe do participa, quero um guia curto de adoção explicando o fork, a versão e a troca do Gemfile, para executar a internalização com segurança.
14. Como equipe do participa, quero validar após a adoção as telas afetadas pelas correções da spec 1 (estado aberto/fechado, bloqueio de envio, condicionantes, exportação, arquivos), para confirmar que o comportamento esperado chegou à instância.
15. Como mantenedora ou mantenedor, quero registrar nesta spec que colaboração com o núcleo e módulos extras é feita nos repositórios próprios de cada um, para não misturar escopos nem criar dependência de terceiros para esta entrega.

## Decisões de implementação

> Adaptações deliberadas ao PRD (registro): escopo **mínimo** (2 gems, não 20); base atual **0.32.1** (as metas de versão futura do upstream no PRD ficam fora); colaboração com core/módulos extras **fora**, via repositórios próprios; meta-gem, gem govbr, módulos vendored e mapa **fora** desta entrega. O PRD permanece como referência de contexto para o programa maior de publicação `bp-*`.

### Renomeação e versão

- Renomear apenas o `s.name` dos gemspecs: `decidim-forms` → `bp-decidim-forms` e `decidim-surveys` → `bp-decidim-surveys`; versão `0.32.1.bp1` (sufixo derivado da base do fork no processo de release).
- **Não mudam**: namespaces Ruby, arquivos de `require`, diretórios físicos, tasks de engine, rotas, migrações, células e controladores.
- Um único lugar de versão (base do fork) alimenta os gemspecs das duas gems, evitando dessincronização.

### Dependências nos gemspecs

- `bp-decidim-forms` → depende de `decidim-core` upstream com faixa compatível com a base (ex.: `~> 0.32.1`), sem sufixo `bp`.
- `bp-decidim-surveys` → depende de `decidim-core` upstream (faixa acima) **e** de `bp-decidim-forms` com trava **exata** `= 0.32.1.bpN` (versão pré-release exige requisito pré-release para o Bundler resolver).
- Nenhuma outra dependência `bp-*` é necessária neste recorte.

### Mecanismo de release

- Adaptar o utilitário de release do repositório (que hoje resolve o remote pela presença de `decidim/decidim`) para aceitar o remote do fork — remote canônico de release a confirmar entre os já configurados no repositório.
- Tarefa de release do recorte: publicar na ordem `bp-decidim-forms` → `bp-decidim-surveys` (folha antes da dependente), com build → tag no remote do fork → `gem push`.
- Adicionar `s.metadata["allowed_push_host"] = "https://rubygems.org"` nos gemspecs como proteção contra push acidental.
- Primeira publicação manual com credenciais RubyGems e MFA (`gem signin` antes); automação com OTP único fica para trabalho futuro, fora desta spec.

### Validação do conteúdo e adoção

- As correções da spec 1 são o conteúdo das duas gems; a spec 1 permanece a fonte de verdade do comportamento esperado.
- Validação downstream: aplicação dummy com `gem "bp-decidim-surveys", "~> 0.32.1.bp1"` no Gemfile (sem `path:`), executando boot e a matriz de comportamento da spec 1.
- Adoção no participa: apenas após o upgrade de versão dele; contrato de consumo e roteiro curto documentados no README/guia; nenhuma alteração no repositório do participa enquanto ele estiver em 0.30.
- Ponto em aberto registrado: o PRD condicionava a publicação às simplificações do componente de pesquisas (fases 1–3 do plano, ainda não executadas). Para o recorte mínimo de entrega das correções ao participa, **não** se bloqueia a publicação nessas fases; recomenda-se concluí-las antes de ampliar a adoção downstream e de anunciar a distribuição publicamente.

## Decisões de teste

Princípios:

- **Testar o comportamento externo do empacotamento**: "a gem publicada instala e resolve numa aplicação downstream" — não detalhes de edição de gemspec.
- **Harness de integração**: reaproveitar a aplicação dummy do monorepo com um Gemfile que consome **as gems publicadas** (não `path:`).
- **Conteúdo já coberto**: as correções da spec 1 possuem suítes próprias (modelo, controlador, formulários, serializador e sistema) — o empacotamento não reescreve esses testes.

Pontos de teste:

1. **Resolução do Bundler**: Gemfile de teste com `gem "bp-decidim-surveys", "~> 0.32.1.bp1"` resolve e traz `bp-decidim-forms` na versão correta, com `decidim-core` upstream.
2. **Smoke de aplicação**: aplicação dummy sobe com as gems carregadas (boot sem erro).
3. **Metadados**: `gem specification bp-decidim-forms -r` e `gem specification bp-decidim-surveys -r` retornam nome, versão, homepage do fork e dependências corretas.
4. **Namespace preservado**: `require "decidim/forms"` e `require "decidim/surveys"` funcionam; módulos `Decidim::Forms`/`Decidim::Surveys` são os esperados.
5. **Conteúdo funcional (spec 1)**: na dummy com as gems, executar a matriz de comportamento — pesquisa fechada rejeita envio; estado aberto respeita `allow_responses` e janela; condicionantes íntegras; exportação sem HTML; limites de arquivos aplicados; ausência de edição de respostas.
6. **Regressão no monorepo**: suítes de formulários e pesquisas verdes antes de cada release (nunca cancelar testes longos).

Recomendações de execução: validar primeiro a publicação de `bp-decidim-forms` isoladamente, depois `bp-decidim-surveys`; registrar o resultado da validação na dummy num documento de acompanhamento da release.

## Fora de escopo

- **Colaboração com o núcleo e módulos extras**: qualquer mudança a propor ao upstream Decidim ou aos repositórios próprios dos módulos (Awesome, Extra Blocks etc.) — feita nesses repositórios, não nesta spec.
- **Meta-gem `bp-decidim`**, **gem `bp-decidim-govbr`**, módulos vendored e demais gems do PRD: fora deste recorte; reavaliar quando houver demanda.
- **Customização de mapas** (spec 2): fora desta entrega.
- **Backport para o participa em 0.30**: nenhum — adoção somente no upgrade de versão do participa.
- **Metas de versão futura do upstream**: fora — a spec parte da base atual 0.32.1 e não agenda rebase nesta entrega.
- **Automação de publicação** (action de release, OTP único) e **changelog automatizado**: trabalho futuro.
- **Publicação de pacotes npm**: fora do escopo (só gems Ruby).
- **Criação de conta/ownership group no RubyGems e disponibilidade dos nomes**: pré-requisito humano/registro (gate), não código.
- **Simplificações do componente de pesquisas** (fases 1–3 do plano): recomendadas antes de ampliar adoção, mas não bloqueiam este recorte (decisão registrada).

## Notas adicionais

- **Referência de contexto**: o PRD "Publicação de gems `bp-*` no RubyGems" descreve o programa completo (namespace, versionamento com sufixo pré-release, ordem de publicação e riscos). Esta spec implementa o primeiro recorte útil daquele programa; ler o PRD para o panorama.
- **Pontos em aberto para confirmação**: remote canônico para as tags de release; conta/ownership group no RubyGems e disponibilidade dos nomes `bp-decidim-forms`/`bp-decidim-surveys` (alternativas do PRD: `br-decidim-*`, `govbr-decidim-*`); ordem das simplificações do componente de pesquisas versus a adoção ampla.
- **Riscos**: nomes ocupados no RubyGems (mitigação: verificar via API antes, alternativas prontas); versão pré-release exigindo trava exata entre as duas gems (mitigação: regra de dependência acima e validação com Bundler); divergência com o upstream por ser fork deliberado (mitigação: namespaces/diretórios preservados facilitam rebase).
- A spec 1 permanece a fonte de verdade do **conteúdo funcional**; esta spec cobre apenas **empacotamento, publicação e adoção** desse conteúdo.
- Registrar a primeira publicação e o contrato de consumo no `RELEASE_NOTES.md` do fork.
