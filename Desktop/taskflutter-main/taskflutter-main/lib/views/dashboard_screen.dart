import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/task_viewmodel.dart';
import '../utils/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<TaskViewModel>(
          builder: (context, vm, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Dashboard',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Métricas de performance',
                    style: GoogleFonts.inter(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // KPI Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.check_circle_rounded,
                          label: 'Concluídas',
                          value: vm.completedCount.toString(),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.pending_actions_rounded,
                          label: 'Pendentes',
                          value: vm.pendingCount.toString(),
                          color: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiCard(
                          icon: Icons.speed_rounded,
                          label: 'Taxa Sucesso',
                          value: '${vm.successRate.toStringAsFixed(0)}%',
                          color: const Color(0xFF00D4FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pie Chart: Concluídas vs Pendentes
                  _ChartContainer(
                    title: 'Progresso Geral',
                    child: SizedBox(
                      height: 200,
                      child: vm.tasks.isEmpty
                          ? Center(
                              child: Text(
                                'Sem dados ainda',
                                style: GoogleFonts.inter(
                                  color: AppColors.textTertiary,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 3,
                                      centerSpaceRadius: 40,
                                      sections: [
                                        PieChartSectionData(
                                          value: vm.completedCount.toDouble(),
                                          color: AppColors.primary,
                                          radius: 50,
                                          title: '${vm.completedCount}',
                                          titleStyle: GoogleFonts.inter(
                                            color: AppColors.background,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: vm.pendingCount.toDouble() == 0
                                              ? 0.1
                                              : vm.pendingCount.toDouble(),
                                          color: Colors.orangeAccent,
                                          radius: 45,
                                          title: '${vm.pendingCount}',
                                          titleStyle: GoogleFonts.inter(
                                            color: AppColors.background,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _LegendItem(
                                        color: AppColors.primary,
                                        label: 'Concluídas',
                                      ),
                                      const SizedBox(height: 12),
                                      _LegendItem(
                                        color: Colors.orangeAccent,
                                        label: 'Pendentes',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bar Chart: Weekly activity
                  _ChartContainer(
                    title: 'Atividade Semanal',
                    child: SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(vm.weeklyCompletionData),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()} tarefa(s)',
                                  GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    '', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex',
                                    'Sáb', 'Dom'
                                  ];
                                  final idx = value.toInt();
                                  if (idx < 1 || idx > 7) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      days[idx],
                                      style: GoogleFonts.inter(
                                        color: AppColors.textTertiary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: _buildWeeklyBars(vm.weeklyCompletionData),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Distribution
                  _ChartContainer(
                    title: 'Distribuição por Categoria',
                    child: vm.categoryDistribution.isEmpty
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                'Sem dados',
                                style: GoogleFonts.inter(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: vm.categoryDistribution.entries.map((e) {
                              final total = vm.tasks.length;
                              final pct =
                                  total > 0 ? (e.value / total) * 100 : 0;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      e.key.emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.key.label,
                                            style: GoogleFonts.inter(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: pct / 100,
                                              backgroundColor: AppColors
                                                  .surfaceVariant,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                Color(e.key.colorValue),
                                              ),
                                              minHeight: 6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${e.value} (${pct.toStringAsFixed(0)}%)',
                                      style: GoogleFonts.inter(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double _getMaxY(Map<int, int> data) {
    if (data.isEmpty) return 5;
    final maxVal = data.values.fold<int>(0, (a, b) => a > b ? a : b);
    return (maxVal + 2).toDouble();
  }

  List<BarChartGroupData> _buildWeeklyBars(Map<int, int> data) {
    return List.generate(7, (i) {
      final weekday = i + 1;
      final value = data[weekday]?.toDouble() ?? 0;
      return BarChartGroupData(
        x: weekday,
        barRods: [
          BarChartRodData(
            toY: value,
            color: AppColors.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(data),
              color: AppColors.surfaceVariant,
            ),
          ),
        ],
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
