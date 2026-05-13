import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/task_viewmodel.dart';

/// Card visual para exibir um hábito diário recorrente com progresso semanal.
class HabitCard extends StatelessWidget {
  final TaskModel habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final catColor = Color(habit.category.colorValue);
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final doneToday = habit.weeklyCompletions.contains(todayKey);
    final progress = habit.weeklyProgress.clamp(0.0, 1.0);
    final count = habit.weeklyCompletionCount.clamp(0, 7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: doneToday
                ? catColor.withValues(alpha: 0.6)
                : AppColors.cardBorder,
            width: doneToday ? 1.5 : 1,
          ),
          boxShadow: doneToday
              ? [
                  BoxShadow(
                    color: catColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        habit.category.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🔁',
                                style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              'Hábito Diário',
                              style: GoogleFonts.inter(
                                color: AppColors.textTertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          habit.title,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Check today button
                  _TodayCheckButton(
                    doneToday: doneToday,
                    catColor: catColor,
                    onTap: () {
                      context
                          .read<TaskViewModel>()
                          .toggleHabitDay(habit, today);
                    },
                  ),
                ],
              ),

              if (habit.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  habit.description,
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 14),

              // Weekly progress bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progresso semanal',
                              style: GoogleFonts.inter(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$count / 7 dias',
                              style: GoogleFonts.inter(
                                color: catColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.surfaceVariant,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(catColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Days-of-week dots
              _WeekDots(
                habit: habit,
                catColor: catColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCheckButton extends StatelessWidget {
  final bool doneToday;
  final Color catColor;
  final VoidCallback onTap;

  const _TodayCheckButton({
    required this.doneToday,
    required this.catColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: doneToday
              ? catColor
              : AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(
            color: doneToday ? catColor : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Icon(
          doneToday
              ? Icons.check_rounded
              : Icons.add_rounded,
          color: doneToday ? Colors.white : AppColors.textTertiary,
          size: 20,
        ),
      ),
    );
  }
}

/// Linha de 7 bolinhas representando os dias da semana atual.
class _WeekDots extends StatelessWidget {
  final TaskModel habit;
  final Color catColor;

  const _WeekDots({required this.habit, required this.catColor});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Calcular o início da semana (segunda-feira)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final dayLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final day = startOfWeek.add(Duration(days: i));
        final key =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final isCompleted = habit.weeklyCompletions.contains(key);
        final isToday = day.day == now.day &&
            day.month == now.month &&
            day.year == now.year;
        final isFuture = day.isAfter(now);

        return Column(
          children: [
            Text(
              dayLabels[i],
              style: GoogleFonts.inter(
                color: isToday
                    ? catColor
                    : AppColors.textTertiary,
                fontSize: 9,
                fontWeight:
                    isToday ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCompleted
                    ? catColor
                    : isFuture
                        ? AppColors.surfaceVariant.withValues(alpha: 0.4)
                        : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: catColor, width: 2)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12)
                  : null,
            ),
          ],
        );
      }),
    );
  }
}
