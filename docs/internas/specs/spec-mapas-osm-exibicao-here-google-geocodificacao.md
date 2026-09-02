# Spec — Mapas: OpenStreetMap na exibição e HERE/Google na geocodificação de endereços

> Status: ready-for-agent
>
> Data: 2026-09-01
> Módulos afetados: configuração de mapas da aplicação (inicializador/ambiente) e, no caminho alternativo, código de provedor no núcleo/repositório próprio
> Referências: documentação oficial de mapas (https://docs.decidim.org/en/develop/services/maps.html) e a versão local em `docs/modules/services/pages/maps.adoc`
> Situação: **a planejar/validar** (caminho recomendado não exige mudança de código no núcleo)

---

## Declaração do problema

A plataforma usa mapas e geocodificação (propostas e reuniões geocodificadas, exibidas em mapas). O requisito da operação é **separar exibição e busca de endereços**:

- **Exibição**: manter o **OpenStreetMap (OSM)** para os tiles e mapas — aparência atual, sem custo por visualização.
- **Busca/geocodificação de endereço** ("encoding" do endereço, ou seja, transformar o texto do endereço em coordenadas e oferecer sugestões enquanto se digita): usar o **HERE** ou o **Google Maps**.

**Pergunta de viabilidade — resposta curta:** sim, dá para manter OSM na exibição e usar outro provedor na geocodificação. A documentação oficial do Decidim mostra que os provedores são configuráveis **por categoria de serviço de mapa** (seção "Combining multiple service providers"): a exibição dinâmica/estática, a geocodificação e o autocomplete são independentes entre si. O **HERE** já é um provedor embutido no núcleo — a troca é **somente configuração** (chave de API). O **Google** também é viável tecnicamente, porém o núcleo **não embute provedor Google**: usá-lo exige **escrever código de integração** (a própria documentação orienta "write your own integration code" para provedores novos) — não é apenas configurar o que já existe.

Observação importante de política: não se deve usar os tiles públicos do `openstreetmap.org` (política de uso dos servidores de tiles). A exibição "OSM" precisa apontar para um provedor de tiles baseado em OSM (serviço comercial ou auto-hospedado) — verificar qual está em uso na instância.

## Solução

Compor os provedores por categoria de serviço de mapa, conforme a documentação oficial:

| Categoria | Provedor | Papel |
|---|---|---|
| Exibição dinâmica (tiles/mapa interativo) | OSM | Mapas nas páginas públicas e listagens (aparência atual) |
| Mapa estático (imagem), se usado | OSM (ou desativado) | Imagens de mapa geradas |
| Geocodificação (endereço → coordenadas) | **HERE** (recomendado) | Conversão do endereço informado em coordenadas |
| Autocomplete (sugestões ao digitar) | **HERE** (recomendado) | Sugestões de endereço no campo geocodificado, com coordenadas na seleção |

### Caminho A (recomendado): HERE na busca, OSM na exibição — somente configuração

- No inicializador de mapas da aplicação (padrão da documentação), manter o provedor global OSM e sobrescrever apenas as categorias de busca para HERE:

  ```text
  config.maps = {
    provider: :osm,                       # exibição (tiles OSM) e fallback
    dynamic: { tile_layer: { url: "<provedor de tiles OSM em uso>", attribution: ... } },
    geocoding:  { provider: :here, api_key: ENV["MAPS_HERE_API_KEY"] },
    autocomplete: { provider: :here, api_key: ENV["MAPS_HERE_API_KEY"] }
  }
  ```

- Chaves por ambiente: `MAPS_HERE_API_KEY` (e variáveis de tiles conforme o provedor OSM usado). Sem chave HERE no arranque, a configuração resolve para OSM nas duas categorias (desenvolvimento/testes seguem no padrão atual).
- Ativação por funcionalidade: propostas exigem "Mapas habilitados" no componente (por componente); reuniões geocodificam automaticamente ao criar/atualizar quando a geocodificação está configurada.
- Nenhuma mudança de código no núcleo: provedor HERE (servidor + navegador) já é entregue pelo Decidim; o autocomplete HERE já tem pacote JavaScript próprio no núcleo.

### Caminho B (alternativa): Google na busca — exige desenvolvimento

- Viável, mas **não é configuração**: é preciso implementar o provedor de geocodificação e de autocomplete do Google (lado servidor e lado navegador, incluindo o carregador da API do Google Maps), seguindo o guia de provedores customizados da documentação.
- Se o Google for obrigatório por contrato, abre-se trabalho dedicado; por diretriz atual do projeto, esse tipo de mudança se daria **no repositório próprio** (colaboração com o núcleo/módulos), não como configuração desta spec. Enquanto não houver decisão, o HERE cobre o requisito com custo mínimo.

### Degradação e consistência

- A exibição OSM nunca depende do provedor de busca: indisponibilidade/chave inválida do HERE afeta apenas as sugestões, e o formulário continua enviável.
- Geocodificação e autocomplete devem usar o **mesmo provedor**, para que as coordenadas da sugestão escolhida batam com a geocodificação do endereço salvo.
- Respeitar a política de tiles: confirmar o provedor de tiles OSM em uso (ou definir um) antes de validar em produção.

## Histórias de usuário

1. Como participante, quero digitar um endereço ao criar uma proposta ou reunião e receber sugestões do provedor de busca enquanto digito, para localizar corretamente meu ponto.
2. Como participante, quero que, ao escolher uma sugestão, o formulário guarde automaticamente as coordenadas do local, para que o marcador fique no lugar certo.
3. Como participante, quero visualizar os mapas (tiles e marcadores) com a mesma aparência OSM de hoje, para que a troca do provedor de busca não mude a experiência visual.
4. Como participante, quero que o mapa continue funcionando quando o serviço de busca estiver indisponível, já que a exibição não depende dele.
5. Como administrador da plataforma, quero configurar o provedor de busca por variável de ambiente (chave HERE), sem alterar código, para ativar a geocodificação por HERE em produção.
6. Como administrador, quero que, sem a chave configurada, a plataforma continue com o comportamento atual (OSM), para que desenvolvimento e testes não quebrem.
7. Como administrador, quero que propostas exijam "Mapas habilitados" no componente e que reuniões geocodifiquem automaticamente, conforme o comportamento padrão do Decidim, para controlar onde o mapa aparece.
8. Como administrador, quero que a chave do HERE seja restrita por domínio/IP conforme o uso (navegador/servidor), para reduzir risco de uso indevido.
9. Como responsável técnico, quero validar em staging o fluxo completo (sugestão → coordenadas → marcador em tiles OSM) antes de produção, para garantir a combinação de provedores.
10. Como responsável técnico, quero saber que a opção Google exige desenvolvimento de provedor próprio, para planejar corretamente caso o contrato exija Google.

## Decisões de implementação

- **Adotar o Caminho A (HERE por configuração)** como primeira entrega, por ser a única que atende ao requisito "configurar o que já existe" sem tocar no núcleo.
- **Configuração no inicializador da aplicação**, dirigida por ambiente: presença de `MAPS_HERE_API_KEY` decide HERE nas categorias de busca; ausência mantém OSM. Chaves nunca entram no repositório.
- **Exibição**: permanece o provedor OSM; confirmar o URL/atribuição do provedor de tiles OSM em uso na instância (política de uso de tiles) e ajustar a configuração de camada de tiles se necessário.
- **Mapa estático**: manter a configuração atual (provedor OSM ou desativado), sem mudança nesta spec.
- **Autocomplete/geocodificação HERE**: usar os provedores embutidos; configurar formato de endereço das sugestões (opções de `address_format` do HERE) se desejado.
- **Sem gem de mapa e sem mudança no núcleo** neste caminho; o Caminho B (Google) fica documentado como trabalho futuro, em repositório próprio se necessário.
- Ponto a validar no arranque: onde a configuração de mapas da instância vive hoje (a base do repositório não contém inicializador de mapas versionado — confirmar a camada de configuração da aplicação em uso antes de aplicar).

## Decisões de teste

Princípios:

- **Testar comportamento observável**: o que a página oferece (sugestões HERE com chave; OSM sem chave; mapa com tiles OSM sempre) — não detalhes internos dos provedores.
- **Sem rede real**: chamadas ao HERE simuladas (stubs de requisição) nos testes; o núcleo já possui specs de provedores de mapa (unidade e sistema) para OSM e HERE que servem de referência de estrutura.
- **Sem mudança de código no caminho A**: os testes focam configuração e fluxo de ponta a ponta.

Pontos de teste:

1. **Resolução de configuração**: com `MAPS_HERE_API_KEY` presente, `geocoding`/`autocomplete` resolvem para HERE e a exibição para OSM; sem chave, tudo OSM.
2. **Fluxo de proposta (sistema)**: criar proposta com endereço em ambiente HERE (mock) resulta em sugestões, coordenadas persistidas e marcador sobre tiles OSM.
3. **Reuniões**: criar/atualizar reunião com endereço geocodifica automaticamente e exibe o mapa OSM.
4. **Degradação**: ausência de chave ou falha do HERE não quebra o formulário nem a exibição do mapa.
5. **Regressão**: suíte dos componentes de propostas e reuniões verde com a configuração padrão OSM (sem chave).
6. **Validação em staging**: checklist manual do fluxo completo nos principais navegadores/dispositivos e conferência da política de tiles OSM.

Recomendações de execução: rodar as suítes do núcleo e de propostas/reuniões (nunca cancelar testes longos); registrar a matriz de validação de staging num documento de acompanhamento.

## Fora de escopo

- **Implementação do provedor Google** (Caminho B): trabalho futuro, em repositório próprio, se o contrato exigir Google.
- **Troca dos tiles de exibição** para HERE ou Google: permanece OSM.
- **Geocodificação reversa** (coordenadas → endereço ao arrastar marcador): fora, permanece no provedor atual até decisão própria.
- **Gem de mapa e mudanças no núcleo**: fora (colaboração com o núcleo se dá em repositório próprio).
- **Otimização de custo/quota** do provedor de busca: acompanhamento operacional posterior.
- **Migração de dados**: nenhuma — apenas o comportamento de busca muda.

## Notas adicionais

- Resposta direta à pergunta desta revisão: **sim**, é possível manter OSM para visualização e usar **HERE ou Google** para a geocodificação do endereço — HERE hoje, só com configuração (provedor embutido); Google, apenas com código de integração novo (documentado na doc oficial como "custom map providers").
- Antes de aplicar em produção: confirmar o provedor de tiles OSM em uso (política de uso dos tiles do OSM), a camada de configuração da instância e a chave HERE restrita por uso.
- Atualizar a documentação local de mapas do projeto após a validação, registrando a matriz de provedores e as variáveis de ambiente.
