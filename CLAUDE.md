# ConcursoPro: landing de vendas

Landing de vendas da ConcursoPro, plataforma que vende simulados de concurso público montados pelo edital, no padrão da banca. As questões são geradas com IA (DeepSeek) e o acesso é vendido pela Hotmart. Responda e comente sempre em português do Brasil.

## Estrutura

- `index.html`: página única, sem build e sem framework. CSS e JS ficam inline no próprio arquivo. As fontes vêm do Google Fonts (Fraunces e Inter).
  - Seções: hero (`.hero`, com o mostrador animado `#dialStage`), mini-simulado interativo (`#teste`), pacote e preço (`#pacote`), concursos disponíveis e como pedir um novo (`#disponiveis`), prova social (`#prova`), FAQ (`#faq`).
  - Os botões de compra (`data-checkout`) abrem a janela de escolha (`<dialog id="checkout">`). O `href` deles continua sendo o checkout da Hotmart (`pay.hotmart.com/Q106592239T?off=rkiofuef`), que vale sem JS, com Ctrl+clique e como link de reserva da janela.
- `termos.html` e `privacidade.html`: páginas de leitura com o mesmo visual (CSS repetido inline nas duas; ao mudar uma, mude a outra). Ligadas no rodapé e no aviso da janela de escolha. O responsável pelos dados aparece só como "ConcursoPro", com o e-mail de contato. Se o produto mudar (dados coletados, fornecedores, prazo de guarda, garantia, acesso), atualize o texto e a data "Última atualização".
- `assets/`: imagens (prints do app, depoimentos, `og-image.png` 1200x630). Os prints do app na seção `#disponiveis` (`app-painel`, `app-priorizador`, `app-recurso`, `app-flashcards`) saem automáticos do `concursoelite`: `python manage.py dados_demo` e `scripts/prints_landing.py` (dados de demonstração genéricos, sem ano, escritos à mão, para não envelhecer). Rodar de novo quando o visual do app mudar e conferir os `width`/`height` das `<img>`.
- O app e a API ficam no repositório `concursoelite` (Django + React). Para entender a loja e o webhook, consulte o `CLAUDE.md` de lá.

## Infraestrutura

- Hospedagem: Static Site no Render, no mesmo projeto do backend. Deploy a cada push na `main`.
- Domínio: `concursoproelite.com.br`. A landing fica no domínio puro e no `www`, o app em `app.` e o backend continua no `concursoelite.onrender.com`.
- E-mail de contato com o aluno: `contato@concursoproelite.com.br`. Recebimento: o ImprovMX redireciona para o Gmail. Resposta: sai pelo SMTP do Brevo. Use este endereço em textos que pedem para o aluno escrever.
- As metatags `og:url`, `og:image` e `twitter:image` usam `https://www.concursoproelite.com.br/`. Não volte a usar endereços antigos (`concursopro-simulados.onrender.com` ou Netlify).
- Se a landing chamar a API, a origem dela precisa estar em `CORS_ALLOWED_ORIGINS` no backend (variável do Render).
- Git guardrails: o hook `.claude/hooks/block-dangerous-git.sh` bloqueia `git push`, `reset --hard`, `clean -f`, `branch -D`, `checkout .` e `restore .`. O push é sempre feito pelo usuário.

## Modelo de negócio

- Pacote de 12 simulados por concurso/cargo. Pagamento único (não é mensalidade): R$ 98,90, preço de lançamento R$ 67,90 (R$ 5,66 por simulado), 40% de desconto para quem já é aluno. Garantia de 7 dias.
- Concursos disponíveis: a lista vem da API da loja (`GET /api/loja/concursos/`, os marcados "à venda" no admin), tanto na janela de escolha quanto no "Já disponíveis" do hero e da seção `#disponiveis`. Sem API, a página mostra um texto genérico, sem citar concursos. Nomes e formatos são corrigidos no admin, nunca no código da landing. Cargos do mesmo edital (campos `edital_id`, `edital` e `cargo` da loja) aparecem agrupados: na janela, TODO edital vem FECHADO (`<details class="ck-edital">`, resumo "ÓRGÃO ANO · N cargos, BANCA") e abre com só o cargo em cada opção, mais "Outro cargo deste edital" (valor `novo:<edital_id>`): pede só o cargo e envia um pedido de concurso novo com `novo_concurso` = nome do edital e `novo_banca` = banca dele, sem mudança no backend. Fica aberto o que a pessoa abriu e o que tem a opção marcada, mesmo quando a lista é recriada. Concurso sem edital aparece como opção direta. No "Já disponíveis" (hero) e na lista da seção `#disponiveis`, só o edital ("ÓRGÃO ANO", com a banca na lista), sem os cargos; os cargos aparecem só na janela. Concurso sem edital (cadastrado antes dos editais) aparece como antes, pelo nome.
- Concurso ainda não cadastrado pode ser comprado: o primeiro simulado sai em até 24h.
- Formatos: múltipla escolha e Certo/Errado (Cebraspe).
- Marca: ConcursoPro (@concursopro.app no Instagram, @concursopro no TikTok).

Preços e prazos aparecem em vários pontos da página (hero, pacote, FAQ e metatags). Ao mudar um deles, atualize todos. Não citar concurso específico em texto fixo da página (fica obsoleto); exemplos são genéricos.

## Fluxo de compra (decidido)

Um único produto na Hotmart para todos os concursos. O Django decide o concurso; a Hotmart só recebe o pagamento.

1. Na landing, o aluno escolhe um concurso (`GET /api/loja/concursos/`, só os marcados `a_venda`) ou pede um concurso novo.
2. `POST /api/loja/pedidos/` cria o pedido e devolve o link do checkout com `email`, `name` e `sck=<código do pedido>`. A landing redireciona para esse link.
3. O webhook da Hotmart libera o acesso no backend. A landing nunca libera acesso.

A janela de escolha faz esse fluxo. Se a API demorar mais de 10 s, ela oferece o link direto da Hotmart com nome e e-mail preenchidos, e desiste da requisição aos 40 s. Só redireciona para `checkout_url` em `https://` de `hotmart.com`.

Para testar localmente: o CORS de produção não aceita localhost, e testar contra a API real cria pedidos reais. Sirva uma cópia com a URL da API trocada por uma API simulada.

## Comunicação com o aluno

- Transparência sobre a IA: as questões são "geradas com IA, calibradas no padrão da banca". Nunca descrever o produto como feito por especialistas ou sem IA.
- Evitar promessas exageradas ("idêntico à prova", "garante a vaga").
- Prova social só com depoimentos reais (prints de conversas). Nunca fotos ou nomes fictícios.
- Respostas da loja não podem revelar se um e-mail já é cliente.

## Pendências

1. Revisão jurídica de `termos.html` e `privacidade.html` (escritas em 06/11/2026, sem revisão de advogado).

Já feito (06/11/2026): janela de escolha publicada; compra e reembolso reais pela janela funcionando (o `sck` chega no webhook); site antigo do Netlify desativado; página gerada pela Hotmart despublicada.

## Como trabalhar neste projeto

- Explicar as mudanças em passos curtos, dizendo o porquê de cada decisão.
- Nunca alterar dados de produção (admin, banco Neon, painel do Render ou da Hotmart). Testes só no ambiente local com SQLite. Se precisar de uma mudança em produção, descreva o passo a passo para o usuário fazer.
- Testar no navegador, inclusive em largura de celular, antes de sugerir commit.
- Manter a acessibilidade que já existe (`aria-*`, `prefers-reduced-motion`, textos para leitor de tela).
- Não fazer commit sem aprovação do usuário.
