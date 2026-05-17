import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_copy.dart';
import '../../domain/entities/table.dart';
import '../providers/app_demo_provider.dart';
import '../providers/order_provider.dart';
import '../providers/table_provider.dart';
import '../widgets/app_utility_toggles.dart';

class TableSelectionScreen extends StatelessWidget {
  const TableSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    final provider = context.watch<TableProvider>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF171717);
    final mutedColor =
        isDarkMode ? const Color(0xFFC9C2BE) : const Color(0xFF625B56);
    final surfaceColor = isDarkMode
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.86)
        : Colors.white.withValues(alpha: 0.90);

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDarkMode ? 0.30 : 0.14,
                child: Image.asset(
                  'lib/assets/images/artisan_harvest_bowl.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor.withValues(alpha: 0.18),
                      backgroundColor.withValues(alpha: 0.76),
                      backgroundColor,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                copy.tableSelectionBadge,
                                style: const TextStyle(
                                  color: Color(0xFFFFB48E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                copy.tableSelectionTitle,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const AppUtilityToggles(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: provider.loadTables,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
                        children: [
                          Text(
                            copy.tableSelectionDescription,
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 15,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _LegendBar(
                            available: copy.availableTable,
                            occupied: copy.occupiedTable,
                            payment: copy.paymentPendingTable,
                          ),
                          const SizedBox(height: 18),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.10)
                                        : Colors.black.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: _TableGrid(
                                  provider: provider,
                                  copy: copy,
                                  textColor: textColor,
                                  mutedColor: mutedColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SelectedTablePanel(
                            table: provider.selectedTable,
                            isLoading: provider.isReserving,
                            copy: copy,
                            textColor: textColor,
                            mutedColor: mutedColor,
                            isDarkMode: isDarkMode,
                            onContinue: () => _continue(context, provider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue(
    BuildContext context,
    TableProvider provider,
  ) async {
    final copy = AppCopy.of(context);
    final selectedTable = provider.selectedTable;

    if (selectedTable == null) {
      return;
    }

    final success = await provider.reserve(selectedTable);

    if (!context.mounted) {
      return;
    }

    if (success) {
      context.read<OrderProvider>().selectTable(selectedTable.id);
      context.read<AppDemoProvider>().openCustomerArea(
            screen: CustomerScreen.aiConcierge,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.tableReserved)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage ?? copy.unableToReserveTable),
      ),
    );
  }
}

class _TableGrid extends StatelessWidget {
  const _TableGrid({
    required this.provider,
    required this.copy,
    required this.textColor,
    required this.mutedColor,
  });

  final TableProvider provider;
  final AppCopy copy;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && !provider.hasTables) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!provider.hasTables) {
      return SizedBox(
        height: 260,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_restaurant_outlined, color: mutedColor, size: 42),
            const SizedBox(height: 12),
            Text(
              copy.noTablesAvailable,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: provider.loadTables,
              child: Text(copy.retry),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: provider.tables.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.06,
      ),
      itemBuilder: (context, index) {
        final table = provider.tables[index];
        final isSelected = table.id == provider.selectedTableId;
        return _TableTile(
          table: table,
          isSelected: isSelected,
          copy: copy,
          onTap: table.isSelectable ? () => provider.choose(table) : null,
        );
      },
    );
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({
    required this.table,
    required this.isSelected,
    required this.copy,
    required this.onTap,
  });

  final TableEntity table;
  final bool isSelected;
  final AppCopy copy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (table.statusKey) {
      'occupied' => const Color(0xFF727272),
      'payment_pending' => const Color(0xFFFFC14F),
      _ => const Color(0xFF62D26F),
    };
    final statusLabel = switch (table.statusKey) {
      'occupied' => copy.occupiedTable,
      'payment_pending' => copy.paymentPendingTable,
      _ => copy.availableTable,
    };
    final disabled = !table.isSelectable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF6F22)
                : disabled
                    ? const Color(0xFF2A2A2C).withValues(alpha: 0.66)
                    : const Color(0xFF252528).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFB48E)
                  : statusColor.withValues(alpha: disabled ? 0.22 : 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    disabled
                        ? Icons.lock_rounded
                        : Icons.event_seat_rounded,
                    color: isSelected ? Colors.white : statusColor,
                    size: 20,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${table.number}',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFF7F7F8),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statusLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.86)
                      : const Color(0xFFC9C2BE),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedTablePanel extends StatelessWidget {
  const _SelectedTablePanel({
    required this.table,
    required this.isLoading,
    required this.copy,
    required this.textColor,
    required this.mutedColor,
    required this.isDarkMode,
    required this.onContinue,
  });

  final TableEntity? table;
  final bool isLoading;
  final AppCopy copy;
  final Color textColor;
  final Color mutedColor;
  final bool isDarkMode;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6F22).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.table_restaurant_rounded,
              color: Color(0xFFFF6F22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.selectedTable,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  table == null ? '--' : '#${table!.number}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: table == null || isLoading ? null : onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F22),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(copy.continueToAi),
          ),
        ],
      ),
    );
  }
}

class _LegendBar extends StatelessWidget {
  const _LegendBar({
    required this.available,
    required this.occupied,
    required this.payment,
  });

  final String available;
  final String occupied;
  final String payment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _LegendChip(label: available, color: const Color(0xFF62D26F)),
        _LegendChip(label: occupied, color: const Color(0xFF727272)),
        _LegendChip(label: payment, color: const Color(0xFFFFC14F)),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
