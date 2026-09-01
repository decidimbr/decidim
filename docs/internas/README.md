# Documentação interna — fork pessoal

Documentos gerados durante o desenvolvimento deste fork (arquitetura,
explicações de módulos e relatórios de análise). Estes arquivos **não** fazem
parte da documentação oficial do Decidim (Antora, em `docs/modules/`).

## Conteúdo

| Arquivo | Descrição |
|---|---|
| `ARCHITECTURE.md` | Visão geral da arquitetura do monorepo gerada a partir do grafo de conhecimento do GitNexus (módulos, fluxos de execução, dependências). |
| `arquitetura-repositorios.html` | Diagrama interativo da arquitetura dos repositórios/módulos. |
| `arquitetura-repositorios.visual-check.html` / `.json` | Verificação visual do diagrama acima, em temas claro/escuro. |
| `arquitetura-repositorios.visual-check.*.png` | Capturas de tela usadas na verificação visual (1440x900 e 2048x1320, claro/escuro). |
| `explicacao-forms.html` | Explicação do funcionamento do módulo `decidim-forms`. |
| `explicacao-surveys.html` | Explicação do funcionamento do módulo `decidim-surveys`. |
| `relatorio-classificacao-problemas.html` | Relatório de classificação de problemas identificados no projeto. |

## Observações

- Os arquivos `.html` são autocontidos (CSS/JS embutidos) e podem ser
  abertos diretamente no navegador.
- O relatório `relatorio-static-pages/` não foi movido para cá por conter um
  repositório git próprio embutido.
