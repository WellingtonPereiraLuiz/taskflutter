import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/task_viewmodel.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/habit_card.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
    });
  }

  void _openAddTaskModal(BuildContext context) {
    final vm = context.read<TaskViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider<TaskViewModel>.value(
        value: vm,
        child: const _AddTaskSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TasksPage(onAddTask: () => _openAddTaskModal(context)),
      const CalendarScreen(),
      const DashboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _openAddTaskModal(context),
              tooltip: 'Nova tarefa ou hábito',
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.task_alt_rounded), label: 'Missões'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendário'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

// ─── Tasks Page ──────────────────────────────────────────────────────────────

class _TasksPage extends StatelessWidget {
  final VoidCallback onAddTask;
  const _TasksPage({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildHardModeWarning(context),
          _buildStatsRow(context),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'GritTracker',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (vm.currentStreak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF4444)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withValues(alpha: 0.4), blurRadius: 12)],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${vm.currentStreak} ${vm.currentStreak == 1 ? "Dia" : "Dias"}',
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Suas missões do dia', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 13)),
                ],
              ),
              GestureDetector(
                onTap: vm.toggleHardMode,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: vm.hardMode ? AppColors.error.withValues(alpha: 0.2) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: vm.hardMode ? AppColors.error : AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color: vm.hardMode ? AppColors.error : AppColors.textTertiary, size: 18),
                      const SizedBox(width: 4),
                      Text('H75',
                          style: GoogleFonts.inter(
                              color: vm.hardMode ? AppColors.error : AppColors.textTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHardModeWarning(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, vm, _) {
        if (!vm.hardMode) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.hasOverdueTasks
                        ? '⚠️ MODO HARD 75 ATIVO — Você tem tarefas atrasadas!'
                        : '🔥 MODO HARD 75 ATIVO — Apenas tarefas pendentes visíveis.',
                    style: GoogleFonts.inter(
                        color: vm.hasOverdueTasks ? AppColors.error : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              _StatChip(label: 'Tarefas', value: vm.todayTasks.length.toString(), color: AppColors.textSecondary),
              const SizedBox(width: 10),
              _StatChip(label: 'Pendentes', value: vm.pendingCount.toString(), color: Colors.orangeAccent),
              const SizedBox(width: 10),
              _StatChip(label: 'Hábitos Hoje', value: '${vm.habitsCompletedToday}/${vm.habitTasks.length}', color: AppColors.primary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, vm, _) {
        if (vm.errorMessage != null) {
          return _ErrorState(message: vm.errorMessage!, onRetry: () { vm.clearError(); vm.loadTasks(); });
        }
        if (vm.isLoading && vm.tasks.isEmpty) return const _LoadingState();

        final todos = vm.displayTasks;
        final habits = vm.habitTasks;

        if (todos.isEmpty && habits.isEmpty) return const _EmptyState();

        return Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // ── Seção: Missões de Hoje ──────────────────────────────
                if (todos.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.task_alt_rounded,
                    title: 'Missões de Hoje',
                    count: todos.length,
                    color: AppColors.primary,
                  ),
                  ...todos.map((task) => TaskCard(key: ValueKey(task.id), task: task)),
                ],
                if (todos.isEmpty && vm.hardMode)
                  _AllDoneMessage(),

                const SizedBox(height: 8),

                // ── Seção: Hábitos Diários ──────────────────────────────
                if (habits.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.loop_rounded,
                    title: 'Hábitos Diários',
                    count: habits.length,
                    color: const Color(0xFF10B981),
                  ),
                  ...habits.map((habit) => HabitCard(key: ValueKey('habit_${habit.id}'), habit: habit)),
                ],

                const SizedBox(height: 16),
                const AdBannerPlaceholder(),
              ],
            ),
            if (vm.isLoading)
              Positioned(
                top: 0, left: 0, right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 2,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.inter(color: color, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('$count', style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _AllDoneMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('Todas as missões cumpridas!',
                style: GoogleFonts.inter(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Chip ───────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── States ───────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
      const SizedBox(height: 16),
      Text('Carregando missões...', style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 14)),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cardBorder)),
        child: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 36),
      ),
      const SizedBox(height: 20),
      Text('Nenhuma missão ainda', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Toque no + para adicionar sua primeira\ntarefa e começar a forjar disciplina.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 13, height: 1.5)),
    ]),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
        const SizedBox(height: 16),
        Text('Ops! Algo deu errado', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded, size: 18), label: const Text('Tentar novamente')),
      ]),
    ),
  );
}

// ─── Add Task Sheet ───────────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();
  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  TaskCategory _selectedCategory = TaskCategory.outro;
  TaskType _selectedType = TaskType.todo;
  bool _addTimer = false;
  double _timerValue = 25.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final vm = context.read<TaskViewModel>();
    final success = await vm.createTask(
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      durationInMinutes: _addTimer ? _timerValue.toInt() : null,
      taskType: _selectedType,
    );

    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(_selectedType == TaskType.habit ? 'Hábito criado!' : 'Missão criada!',
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ]),
        duration: const Duration(seconds: 2),
      ));
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),

                // ── Type Selector ─────────────────────────────────────
                Text('Tipo', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: TaskType.values.map((type) {
                    final isSelected = _selectedType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder, width: isSelected ? 2 : 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(type.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(type.label, style: GoogleFonts.inter(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text(
                  _selectedType == TaskType.habit ? 'Novo Hábito' : 'Nova Missão',
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedType == TaskType.habit
                      ? 'Crie uma rotina inegociável que se repete todo dia.'
                      : 'Defina com clareza o que deve ser feito.',
                  style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 13),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Título *',
                    hintText: _selectedType == TaskType.habit ? 'Ex: Meditar 10 minutos' : 'Ex: Estudar Flutter por 2 horas',
                    prefixIcon: const Icon(Icons.task_alt_rounded, color: AppColors.textTertiary, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Por favor, insira um título.';
                    if (value.trim().length > 100) return 'Máximo de 100 caracteres.';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Detalhes opcionais...',
                    prefixIcon: Icon(Icons.notes_rounded, color: AppColors.textTertiary, size: 20),
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                // Category
                Text('Categoria', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: TaskCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final catColor = Color(cat.colorValue);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? catColor.withValues(alpha: 0.2) : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? catColor : AppColors.cardBorder, width: isSelected ? 2 : 1),
                        ),
                        child: Text('${cat.emoji} ${cat.label}',
                            style: GoogleFonts.inter(color: isSelected ? catColor : AppColors.textSecondary, fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),

                // Timer (only for todo)
                if (_selectedType == TaskType.todo) ...[
                  const SizedBox(height: 16),
                  Row(children: [
                    Checkbox(value: _addTimer, onChanged: (val) => setState(() => _addTimer = val ?? false)),
                    Text('Adicionar Timer de Foco?', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                  if (_addTimer) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.timer_outlined, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text('${_timerValue.toInt()} minutos', style: GoogleFonts.inter(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
                    ]),
                    Slider(value: _timerValue, min: 5, max: 60, divisions: 11, activeColor: AppColors.accent, inactiveColor: AppColors.surfaceVariant, onChanged: (val) => setState(() => _timerValue = val)),
                  ],
                ],

                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar'))),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submit(context),
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.background)))
                          : Text(_selectedType == TaskType.habit ? 'Criar Hábito' : 'Criar Missão'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      alignment: Alignment.center,
      child: Text(
        'Espaço Reservado para Foco',
        style: GoogleFonts.inter(
          color: AppColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
