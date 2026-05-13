# GritTracker 🔥

[📥 BAIXAR APK (VERSÃO FINAL)](https://WellingtonPereiraLuiz.github.io/taskflutter/downloads/GritTracker.apk)

> **Forje disciplina. Conquiste rotinas.**  
> Um rastreador de tarefas e hábitos diários construído com Flutter + MVVM + Provider.

---

## ✨ Features

### ✅ Missões de Hoje (Tarefas Únicas)
- Crie tarefas categorizadas (Treino 💪, Estudo 📚, Trabalho 💼, Outro ⚡)
- Marque como concluída com animação de checkbox
- Timer de foco Pomodoro integrado (5–60 min)
- Modo Hard 75: oculta tarefas concluídas e alerta atrasos

### 🔁 Hábitos Diários
- Crie rotinas inegociáveis que se repetem todo dia
- **LinearProgressIndicator** mostrando progresso semanal (X/7 dias)
- Mapa de dias da semana (bolinhas) com visualização do histórico
- Marque/desmarque o hábito de hoje com um toque
- Seção dedicada na tela principal, separada das missões

### 📊 Dashboard
- Gráfico de barras semanal (fl_chart)
- Taxa de sucesso das tarefas
- Distribuição por categoria (pizza chart)
- Streak de dias consecutivos 🔥

### 📅 Calendário
- Visualização de tarefas por dia (table_calendar)

### 🔐 Google Sign-In (Boilerplate)
- Tela de login premium com animações
- AuthService com `google_sign_in` v7 + `firebase_auth`
- Botão "Continuar sem conta" para bypass em desenvolvimento
- **Requer configuração Firebase** (veja instruções abaixo)

---

## 🛡️ Arquitetura

O projeto utiliza os seguintes padrões:
- **MVVM (Model-View-ViewModel):** Separação clara de interface (View) da lógica de negócios (ViewModel).
- **Repository Pattern:** O `TaskViewModel` depende da abstração `ITaskRepository`, permitindo trocar a camada de dados facilmente (ex: SQLite para Produção, InMemory para Testes/Web).
- **Singleton para o DB:** O `DatabaseService` é um Singleton garantindo uma única conexão e instância do SQLite gerenciando todas as transações, protegendo contra vazamentos de memória e locks do DB.

```
lib/
├── main.dart               # Entry point (Firebase init + Provider)
├── models/
│   └── task_model.dart     # TaskModel + TaskCategory + TaskType enums
├── repositories/
│   └── task_repository.dart # ITaskRepository, SQLite e InMemory impl.
├── services/
│   ├── auth_service.dart   # Google Sign-In + Firebase Auth
│   ├── database_service.dart # SQLite (sqflite) — Singleton Pattern
│   └── streak_service.dart # SharedPreferences streak tracking
├── viewmodels/
│   └── task_viewmodel.dart # ChangeNotifier MVVM — tarefas + hábitos
├── views/
│   ├── login_screen.dart   # Tela de login com Google Sign-In
│   ├── home_screen.dart    # Seções Missões + Hábitos + modal FAB
│   ├── dashboard_screen.dart
│   ├── calendar_screen.dart
│   ├── profile_screen.dart # Perfil de usuário e Hard Mode
│   └── splash_screen.dart
├── widgets/
│   ├── task_card.dart      # Card de tarefa com animação + delete
│   ├── habit_card.dart     # Card de hábito (Glassmorphism + week dots)
│   ├── pomodoro_modal.dart
│   └── task_detail_sheet.dart
└── utils/
    └── app_theme.dart      # Tema dark (AppColors + ThemeData)
```

**Plataformas:** Android (SQLite) | Web (InMemory)  
**SDK Dart:** `^3.10.0`

---

## 🚀 Setup Rápido (novo ambiente)

```bash
# 1. Limpar ambiente
flutter clean

# 2. Restaurar dependências
flutter pub get

# 3. Verificar SDK
flutter doctor

# 4. Rodar em modo debug
flutter run
```

---

## 🎨 App Icon

O ícone foi gerado com `flutter_launcher_icons` usando uma PNG 512×512 personalizada:

```bash
# Gerar a PNG do ícone (requer package:image — já no pubspec como dev dep)
dart run tool/generate_icon.dart

# Aplicar aos projetos Android / Web
dart run flutter_launcher_icons
```

**Configuração em `pubspec.yaml`:**
```yaml
flutter_icons:
  android: true
  ios: false           # Sem pasta ios/ neste projeto
  image_path: "assets/icon/app_icon.png"
  web:
    generate: true
    image_path: "assets/icon/app_icon.png"
```

---

## 🔥 Firebase & Google Sign-In

> ⚠️ **ATENÇÃO:** O Google Sign-In **não funciona** sem configuração Firebase.  
> O app roda em modo demo sem Firebase — use "Continuar sem conta".

### Passos obrigatórios para ativar o login real:

1. **Criar projeto no Firebase Console**  
   → https://console.firebase.google.com

2. **Adicionar app Android**  
   → Package name: `com.example.taskflutter` (ou o seu)

3. **Obter SHA-1 do keystore de debug:**
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

4. **Registrar o SHA-1** no Firebase Console → Configurações do Projeto → Suas Apps → SHA

5. **Baixar `google-services.json`** e colocar em `android/app/`

6. **Habilitar Google** em Firebase → Authentication → Sign-in methods

7. **Instalar FlutterFire CLI e configurar:**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   → Isso gera `lib/firebase_options.dart` — **atualize o `main.dart`** para importá-lo:
   ```dart
   import 'firebase_options.dart';
   // ...
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```

8. **Rodar o app** — o botão "Entrar com Google" funcionará.

---

## 🧪 Estratégia de Qualidade (ISTQB)

A aplicação foi validada usando conceitos robustos baseados no **Framework ISTQB**, aplicando **Shift-Left Testing** para garantir a qualidade desde o início do ciclo de vida:

- **Testes de Regressão Automatizados:** Sempre que uma nova funcionalidade é adicionada, a suíte de testes inteira é rodada. Se algo quebrar, a automação detecta imediatamente. 
- **Testes de Integração / Widget (Caixa Preta):** O fluxo de usuário é validado desde o clique até as interações de estado e persistência simulada via `flutter_test`.
- **Testes de Unidade (Caixa Branca):** A validação da lógica de serviços críticos, como o mock de autenticação e repositórios virtuais.

```bash
# Rodar todos os testes
flutter test

# Rodar apenas os testes da HomeScreen
flutter test test/views/home_screen_test.dart --reporter=compact
```

### Cobertura dos testes (`test/views/home_screen_test.dart`):

| Grupo | Teste | Status |
|---|---|---|
| Empty State | Exibe "Nenhuma missão ainda" | ✅ |
| Empty State | Exibe ícone rocket_launch | ✅ |
| FAB | Toque abre modal de criação | ✅ |
| FAB | Modal contém "Criar Missão" | ✅ |
| FAB | Modal tem toggle Tarefa/Hábito | ✅ |
| FAB | Selecionar Hábito muda botão | ✅ |
| Seções | Exibe "Missões de Hoje" | ✅ |
| Seções | Exibe "Hábitos Diários" | ✅ |
| Seções | Aba Calendário navegável | ✅ |

**Estratégia:** `FakeTaskViewModel` com estado pré-definido — sem dependências de SharedPreferences ou SQLite nos testes.

---

## 📦 Dependências Principais

| Pacote | Versão | Uso |
|---|---|---|
| `provider` | ^6.1.5 | State management (MVVM) |
| `sqflite` | ^2.4.2 | SQLite (Android) |
| `google_fonts` | ^8.1.0 | Tipografia Inter |
| `fl_chart` | ^0.70.2 | Gráficos Dashboard |
| `table_calendar` | ^3.2.0 | Calendário |
| `shared_preferences` | ^2.3.4 | Streak persistence |
| `google_sign_in` | ^7.2.0 | Auth Google |
| `firebase_auth` | ^6.5.0 | Auth Firebase |
| `firebase_core` | ^4.8.0 | Firebase init |
| `flutter_launcher_icons` | ^0.14.4 | App icon geração |

---

## 🔢 Versionamento do Banco de Dados

| Versão | Mudança |
|---|---|
| v1 | Tabela `tasks` inicial |
| v2 | Coluna `category` |
| v3 | Coluna `durationInMinutes` |
| v4 | Colunas `taskType` + `weeklyCompletions` (Habit Tracker) |

---

*GritTracker — Desenvolvido com Flutter 🐦 e determinação 🔥*
