<div align="center">

# 🔥 GritTracker 2.0

### *Forje sua disciplina. Execute sem desculpas.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Web-Live%20Demo-38BDF8?logo=github)](https://WellingtonPereiraLuiz.github.io/taskflutter/)

<br/>

**O GritTracker é um sistema de alta performance pessoal para gestão de tarefas inegociáveis.**
Construído com Flutter, arquitetura MVVM, Provider e SQLite.

<br/>

<a href="https://WellingtonPereiraLuiz.github.io/taskflutter/downloads/GritTracker.apk">
  <img src="https://img.shields.io/badge/📥_DOWNLOAD_APK_ANDROID-38BDF8?style=for-the-badge&logoColor=black&labelColor=121212" alt="Download APK" />
</a>

<br/><br/>

<a href="https://WellingtonPereiraLuiz.github.io/taskflutter/">
  <img src="https://img.shields.io/badge/🌐_ACESSAR_WEB_APP-00D4FF?style=for-the-badge&logoColor=black&labelColor=121212" alt="Web App" />
</a>

</div>

---

## 📋 Índice

- [Descrição e Contextualização](#-descrição-e-contextualização)
- [Funcionalidades v2.0](#-funcionalidades-v20)
- [Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [Arquitetura do Software](#-arquitetura-do-software)
- [Como Executar](#-como-executar)
- [Roadmap](#-roadmap)
- [Autor](#-autor)

---

## 📖 Descrição e Contextualização

O GritTracker é o primeiro produto mobile do portfólio da nossa empresa. Ele foi desenvolvido não apenas como uma ferramenta utilitária, mas como um sistema focado em **alta performance pessoal e disciplina**. A aplicação funciona como uma "forja" de hábitos e gestão de tarefas inegociáveis.

### Respostas aos Critérios do Projeto:

**• Qual problema o aplicativo resolve?**
Resolve a procrastinação, a falta de consistência em rotinas árduas e a ausência de rastreabilidade na execução de tarefas diárias críticas. Muitas pessoas falham em seus objetivos por não terem um sistema de registro rápido, visual e livre de distrações para cobrar a si mesmas.

**• Quem seria o público-alvo?**
Estudantes de tecnologia, desenvolvedores, atletas amadores e qualquer indivíduo focado em autodesenvolvimento e produtividade extrema que necessite de uma ferramenta direta, sem elementos supérfluos, para rastrear suas vitórias diárias.

**• Quais funcionalidades principais o aplicativo oferece?**
Veja a seção completa de [Funcionalidades v2.0](#-funcionalidades-v20) abaixo.

**• Por que essa solução poderia ser útil para alguém?**
Porque ela remove a complexidade das ferramentas tradicionais de gestão. Ao oferecer uma interface brutalista e focada, aliada a um design responsivo e rápido, o usuário não perde tempo configurando o app; ele abre, registra a missão, executa e marca como concluída, gerando dopamina e mantendo a constância.

---

## ⚡ Funcionalidades v2.0

### 1. 📊 Dashboard de Alta Performance
- Gráfico **Pie Chart** de tarefas concluídas vs. pendentes
- Gráfico **Bar Chart** de atividade semanal (últimos 7 dias)
- **KPIs visuais**: Total, Pendentes, Concluídas e Taxa de Sucesso
- Distribuição por categoria com barras de progresso
- Integrado ao `BottomNavigationBar` como aba dedicada

### 2. 🔥 Sistema de Streaks (Ofensivas)
- Rastreia **dias consecutivos** de uso do app
- Badge visual no header: `🔥 5 Dias`
- Persistência via `SharedPreferences` (sobrevive entre sessões)
- Reseta automaticamente se o usuário pular um dia

### 3. ⏱️ Timer Pomodoro Embutido (Deep Work Focus)
- Timer de **25 minutos** isolado por tarefa
- Ao clicar em qualquer tarefa, abre o modal Pomodoro
- Botão dedicado "Iniciar Foco" com ícone de timer
- **Progresso circular** animado com pulse quando ativo
- Play/Pause/Reset com feedback visual
- Diálogo de conclusão ao finalizar a sessão

### 4. 🏷️ Categorização de Tarefas (Tags)
- Enum `TaskCategory`: **Treino** 💪, **Estudo** 📚, **Trabalho** 💼, **Outro** ⚡
- Seletor visual de categoria na criação de tarefa
- **Borda colorida** no card dependendo da categoria:
  - 🟠 Treino (Laranja)
  - 🔵 Estudo (Cyan)
  - 🟣 Trabalho (Roxo)
  - 🟢 Outro (Neon Green)
- Badge de categoria exibido em cada card
- Banco de dados SQLite atualizado com coluna `category` (migração v2)

### 5. 💀 Modo "Hard 75" (Filtro Implacável)
- Toggle `H75` no AppBar (ativa/desativa)
- **Oculta todas as tarefas concluídas**
- Mostra apenas o que falta ser feito
- **Banner vermelho** se houver tarefas atrasadas (24h+)

### 6. 📅 Calendário de Produtividade
- Visão visual de tarefas por dia com **table_calendar**
- Feedback visual do dia selecionado
- Oculta distrações mostrando apenas tarefas daquela data

### 7. 🧪 Testes Unitários de Qualidade
- Utilização extensiva de **mocktail** para simular Repositórios
- Testes cobrindo ViewModel, adição de tarefas e lógicas de data
- Integração garantida na esteira de desenvolvimento

### Funcionalidades Base (v1.0)
- ✅ Cadastro ágil de novas tarefas (título + descrição)
- ✅ Listagem em tempo real com estados visuais de carregamento
- ✅ Marcação de conclusão com feedback visual de alto contraste
- ✅ Exclusão de tarefas com animação
- ✅ Persistência local robusta (SQLite nativo + fallback in-memory para Web)
- ✅ Interface Dark Blue Premium (Alta Fidelidade) focada em concentração
- ✅ Splash Screen animada com efeito de glow

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Função |
|---|---|
| **Flutter 3.x** | Framework multiplataforma (Android, Web, Desktop) |
| **Dart 3.x** | Linguagem de programação |
| **Provider** | Gerenciamento de estado reativo |
| **sqflite** | Banco de dados relacional local (Android) |
| **fl_chart** | Gráficos interativos (Pie, Bar) |
| **shared_preferences** | Persistência de configurações (Streaks) |
| **Google Fonts** | Tipografia premium (Inter) |
| **intl** | Formatação de datas |
| **path_provider** | Acesso ao filesystem do dispositivo |

---

## 🏗️ Arquitetura do Software

Foi adotada a arquitetura **MVVM (Model-View-ViewModel)** em conjunto com o padrão **Repository**, visando separação rigorosa de responsabilidades:

```
lib/
├── main.dart                         # Entry point
├── models/
│   └── task_model.dart               # TaskModel + TaskCategory enum
├── services/
│   ├── database_service.dart         # SQLite driver (v2 c/ migration)
│   └── streak_service.dart           # SharedPreferences streak tracking
├── repositories/
│   └── task_repository.dart          # ITaskRepository + Factory + InMemory
├── viewmodels/
│   └── task_viewmodel.dart           # Regras de negócio + estado reativo
├── views/
│   ├── splash_screen.dart            # Splash animada
│   ├── home_screen.dart              # Tela principal + BottomNav + Hard75
│   ├── dashboard_screen.dart         # Dashboard com fl_chart
│   └── calendar_screen.dart          # Visão por data com table_calendar
├── widgets/
│   ├── task_card.dart                # Card de tarefa c/ categoria + Pomodoro
│   └── pomodoro_modal.dart           # Timer 25min Deep Work
└── utils/
    └── app_theme.dart                # Design System completo
```

- **Models:** Estruturas de dados, serialização e enums (`TaskModel`, `TaskCategory`).
- **Views & Widgets:** Componentes visuais reativos ao estado.
- **ViewModels:** Regras de negócio, estado e notificações (`TaskViewModel`).
- **Repositories:** Abstração da fonte de dados (SQLite ↔ InMemory).
- **Services:** Comunicação direta com drivers (SQLite, SharedPreferences).

---

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.x instalado
- Android Studio ou VS Code com extensão Flutter
- Emulador Android ou dispositivo físico

### Passos
```bash
# 1. Clone o repositório
git clone https://github.com/WellingtonPereiraLuiz/taskflutter.git

# 2. Entre na pasta
cd taskflutter

# 3. Instale dependências
flutter pub get

# 4. Execute no emulador, navegador ou dispositivo
flutter run

# 5. Build APK de produção
flutter build apk --release

# 6. Build Web
flutter build web --base-href "/taskflutter/"
```

### Download Direto

<a href="https://WellingtonPereiraLuiz.github.io/taskflutter/downloads/GritTracker.apk">
  <img src="https://img.shields.io/badge/📥_DOWNLOAD_APK_ANDROID-38BDF8?style=for-the-badge&logoColor=black&labelColor=121212" alt="Download APK" />
</a>

---

## 🗺️ Roadmap: Próximos Passos (Aula de CI/CD Codemagic)

- [ ] **Pipeline CI/CD com Codemagic** — Build e deploy automatizado a cada push
- [ ] **Notificações Push** — Lembretes para tarefas pendentes
- [ ] **Sincronização em Nuvem** — Firebase/Supabase como backend remoto
- [ ] **Sistema de Recompensas** — Conquistas desbloqueáveis por metas atingidas
- [ ] **Exportação de Dados** — Relatório PDF/CSV de performance
- [ ] **Tema Customizável** — Paletas de cores personalizáveis pelo usuário
- [ ] **Publicação na Google Play Store** — Distribuição oficial

---

## 🤖 Uso de IA (Antigravity & Claude Sonnet)

A Inteligência Artificial foi utilizada como um Engenheiro Pair-Programmer de alta performance. O fluxo consistiu em:
1. Delegação da criação do boilerplate e da árvore de diretórios (MVVM).
2. Geração do código estrutural das queries SQL e injeção do Provider.
3. Refatoração ativa da interface de usuário para alcançar o Design System exigido.
4. Implementação das 5 novas funcionalidades do GritTracker 2.0.

As decisões arquiteturais centrais (escolha do MVVM, divisão de repositórios e design de UI) foram direcionadas e auditadas pelo autor humano, garantindo total compreensão e autoria sobre a solução técnica final.

---

## 👤 Autor

**Wellington Pereira Luiz**
Estudante de Análise e Desenvolvimento de Sistemas — IFRO
Atividade: Meu Primeiro Aplicativo na Loja de Apps (Prof. Andrey Alencar Quadros)

---

<div align="center">

*Built with 🔥 discipline and ⚡ Flutter*

</div>
