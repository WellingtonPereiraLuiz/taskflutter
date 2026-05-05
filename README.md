# GritTracker

## 1. Descrição e Contextualização
O GritTracker é o primeiro produto mobile do portfólio da nossa empresa. Ele foi desenvolvido não apenas como uma ferramenta utilitária, mas como um sistema focado em alta performance pessoal e disciplina. A aplicação funciona como uma "forja" de hábitos e gestão de tarefas inegociáveis.

### Respostas aos Critérios do Projeto:

**• Qual problema o aplicativo resolve?**
Resolve a procrastinação, a falta de consistência em rotinas árduas e a ausência de rastreabilidade na execução de tarefas diárias críticas. Muitas pessoas falham em seus objetivos por não terem um sistema de registro rápido, visual e livre de distrações para cobrar a si mesmas.

**• Quem seria o público-alvo?**
Estudantes de tecnologia, desenvolvedores, atletas amadores e qualquer indivíduo focado em autodesenvolvimento e produtividade extrema que necessite de uma ferramenta direta, sem elementos supérfluos, para rastrear suas vitórias diárias.

**• Quais funcionalidades principais o aplicativo oferece?**
- Cadastro ágil de novas tarefas (com título e descrição).
- Listagem em tempo real com estados visuais de carregamento.
- Marcação de conclusão de tarefas com feedback visual de sucesso (alto contraste).
- Exclusão de tarefas.
- Persistência de dados local robusta (funciona offline com arquitetura escalável).
- Interface Dark Mode Premium focada em concentração.

**• Por que essa solução poderia ser útil para alguém?**
Porque ela remove a complexidade das ferramentas tradicionais de gestão. Ao oferecer uma interface brutalista e focada, aliada a um design responsivo e rápido, o usuário não perde tempo configurando o app; ele abre, registra a missão, executa e marca como concluída, gerando dopamina e mantendo a constância.

---

## 2. Tecnologias Utilizadas
- **Linguagem / Framework:** Dart e Flutter.
- **Backend:** `sqflite` (Banco de dados relacional local, simulando integrações externas com latência artificial para fins de arquitetura).
- **Gerenciador de Estados:** `provider` (Sólido, nativo e escalável para injeção de dependências).
- **Pacotes Adicionais:** `path_provider`, `google_fonts`, `intl`.

## 3. Arquitetura do Software
Foi adotada a arquitetura **MVVM (Model-View-ViewModel)** em conjunto com o padrão **Repository**, visando separação rigorosa de responsabilidades:
- **Models:** Contêm as estruturas de dados e regras de serialização (`task_model.dart`).
- **Views & Widgets:** Componentes visuais burros, reativos apenas ao estado (`home_screen.dart`, `task_card.dart`).
- **ViewModels:** Detêm as regras de negócio e controlam o estado da aplicação emitindo notificações (`task_viewmodel.dart`).
- **Repositories:** Abstraem a fonte de dados, permitindo que no futuro o banco local seja trocado por uma API externa (como Firebase ou Supabase) sem alterar a regra de negócio (`task_repository.dart`).
- **Services:** Camada de comunicação direta com o driver do SQLite (`database_service.dart`).

## 4. Integração com Backend e Gerenciamento de Estados
O **Backend** é resolvido via persistência local no disco do dispositivo com tabelas relacionais. O fluxo de dados opera de forma assíncrona.
O **Gerenciamento de Estados** ocorre através do Provider. O `TaskViewModel` processa a chamada ao repositório, define a flag `isLoading` como `true`, notifica a UI (que exibe o load), e ao finalizar a transação, atualiza a lista em memória e notifica a UI novamente para renderizar os cards.

## 5. Uso de IA (Antigravity & Claude Sonnet)
A Inteligência Artificial foi utilizada como um Engenheiro Pair-Programmer de alta performance. O fluxo consistiu em:
1. Delegação da criação do boilerplate e da árvore de diretórios (MVVM).
2. Geração do código estrutural das queries SQL e injeção do Provider.
3. Refatoração ativa da interface de usuário para alcançar o Design System exigido.
As decisões arquiteturais centrais (escolha do MVVM, divisão de repositórios e design de UI) foram direcionadas e auditadas pelo autor humano, garantindo total compreensão e autoria sobre a solução técnica final.

## 6. Como Executar o Projeto
1. Clone este repositório: `git clone https://github.com/WellingtonPereiraLuiz/taskflutter.git`
2. Navegue até a pasta: `cd taskflutter`
3. Restaure as dependências: `flutter pub get`
4. Execute no emulador ou navegador: `flutter run`

## 7. Apresentação (Prints / GIFs)
*(Espaço reservado para o aluno adicionar os prints gerados após a primeira execução, conforme exigido no enunciado)*
- [Print da Splash Screen]
- [Print da Home Vazia]
- [Print da Home com Tarefas]

## Autor
Wellington Pereira Luiz
Estudante de Análise e Desenvolvimento de Sistemas - IFRO
Atividade: Meu Primeiro Aplicativo na Loja de Apps (Prof. Andrey Alencar Quadros)
