# ConcursoPro: landing de vendas

Landing de vendas da ConcursoPro, plataforma que vende simulados de concurso público montados pelo edital, no padrão da banca. As questões são geradas com IA (DeepSeek) e o acesso é vendido pela Hotmart. Responda e comente sempre em português do Brasil.

## Estrutura

- `index.html`: página única, sem build e sem framework. CSS e JS ficam inline no próprio arquivo. As fontes vêm do Google Fonts (Fraunces e Inter).
  - Seções: hero (`.hero`, com o mostrador animado `#dialStage`), mini-simulado interativo (`#teste`), pacote e preço (`#pacote`), concursos disponíveis e como pedir um novo (`#disponiveis`), prova social (`#prova`), FAQ (`#faq`).
  - Os botões de compra (`data-checkout`) abrem a janela de escolha (`<dialog id="checkout">`). O `href` deles continua sendo o checkout da Hotmart (`pay.hotmart.com/Q106592239T?off=rkiofuef`), que vale sem JS, com Ctrl+clique e como link de reserva da janela.
- `assets/`: imagens (prints do app, depoimentos, `og-image.png` 1200x630).
- O app e a API ficam no repositório `concursoelite` (Django + React). Para entender a loja e o webhook, consulte o `CLAUDE.md` de lá.

## Infraestrutura

- Hospedagem: Static Site no Render, no mesmo projeto do backend. Deploy a cada push na `main`.
- Domínio: `concursoproelite.com.br`. A landing fica no domínio puro e no `www`, o app em `app.` e o backend continua no `concursoelite.onrender.com`.
- As metatags `og:url`, `og:image` e `twitter:image` usam `https://www.concursoproelite.com.br/`. Não volte a usar endereços antigos (`concursopro-simulados.onrender.com` ou Netlify).
- Se a landing chamar a API, a origem dela precisa estar em `CORS_ALLOWED_ORIGINS` no backend (variável do Render).
- Git guardrails: o hook `.claude/hooks/block-dangerous-git.sh` bloqueia `git push`, `reset --hard`, `clean -f`, `branch -D`, `checkout .` e `restore .`. O push é sempre feito pelo usuário.

## Modelo de negócio

- Pacote de 12 simulados por concurso/cargo. Pagamento único (não é mensalidade): R$ 98,90, preço de lançamento R$ 67,90 (R$ 5,66 por simulado), 40% de desconto para quem já é aluno. Garantia de 7 dias.
- Concursos disponíveis: Transpetro Engenharia de Produção (Cesgranrio), TCE-MA Contador e TCE-MA Direito (Cebraspe).
- Concurso ainda não cadastrado pode ser comprado: o primeiro simulado sai em até 24h.
- Formatos: múltipla escolha e Certo/Errado (Cebraspe).
- Marca: ConcursoPro (@concursopro.app no Instagram, @concursopro no TikTok).

Preços, concursos e prazos aparecem em vários pontos da página (hero, pacote, disponíveis, FAQ e metatags). Ao mudar um deles, atualize todos.

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

1. Compra real de teste pela janela de escolha (confere `sck` no webhook).
2. Páginas de Termos e Privacidade (os links do rodapé apontam para `#`).
3. Print novo do painel (o atual mostra DATAPREV).
4. "Pagamento único" mais visível perto do botão principal.
5. Desativar o site antigo no Netlify e despublicar a página gerada pela Hotmart.

## Como trabalhar neste projeto

- Explicar as mudanças em passos curtos, dizendo o porquê de cada decisão.
- Nunca alterar dados de produção (admin, banco Neon, painel do Render ou da Hotmart). Testes só no ambiente local com SQLite. Se precisar de uma mudança em produção, descreva o passo a passo para o usuário fazer.
- Testar no navegador, inclusive em largura de celular, antes de sugerir commit.
- Manter a acessibilidade que já existe (`aria-*`, `prefers-reduced-motion`, textos para leitor de tela).
- Não fazer commit sem aprovação do usuário.
