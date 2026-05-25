import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_snack_bar.dart';

class WeightLogScreen extends ConsumerStatefulWidget {
  const WeightLogScreen({super.key});

  @override
  ConsumerState<WeightLogScreen> createState() => _WeightLogScreenState();
}

class _WeightLogScreenState extends ConsumerState<WeightLogScreen> {
  double _loggedWeight = 165.0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Convert kg from profile to lbs if standard or keep unit base (using standard lbs)
    _loggedWeight = 165.0; // default for mock display in lbs
  }

  void _onSaveWeight() {
    // Save to weight history provider
    ref
        .read(weightHistoryProvider.notifier)
        .logWeight(_loggedWeight, _selectedDate);
    // Update weight in user profile provider
    ref.read(userProfileProvider.notifier).updateWeight(_loggedWeight);

    AppSnackBar.showSuccess(
      context,
      message:
          'Successfully logged weight: ${_loggedWeight.toStringAsFixed(1)} lbs!',
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final history = ref.watch(weightHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Log Weight',
          style: AppTypography.headingLg(color: colors.onSurface),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Current weight details picker card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'LOG CURRENT WEIGHT',
                        style: AppTypography.labelSm(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _loggedWeight.toStringAsFixed(1),
                            style: AppTypography.numeralHero(
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'lbs',
                            style: AppTypography.headingMd(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Slider for easy weight selecting
                      Slider(
                        value: _loggedWeight,
                        min: 100.0,
                        max: 250.0,
                        divisions: 300,
                        label: '${_loggedWeight.toStringAsFixed(1)} lbs',
                        onChanged: (val) {
                          setState(() => _loggedWeight = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Log Date Selection Row
              Card(
                child: ListTile(
                  leading: Icon(LucideIcons.calendar, color: colors.primary),
                  title: Text(
                    'Log Date',
                    style: AppTypography.bodyLg(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: AppTypography.bodySm(color: colors.onSurfaceVariant),
                  ),
                  trailing: Icon(LucideIcons.chevronRight),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Save button trigger
              ElevatedButton(
                onPressed: _onSaveWeight,
                child: const Text('Log Weight Record'),
              ),
              const SizedBox(height: 36),

              // 3. Weight History Records List
              Text(
                'Recent Log Entries',
                style: AppTypography.headingSm(color: colors.onSurface),
              ),
              const SizedBox(height: 12),
              if (history.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No past logs recorded.',
                      style: AppTypography.bodySm(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry =
                        history[history.length -
                            1 -
                            index]; // reverse chronological
                    final entryDate =
                        '${entry.date.day}/${entry.date.month}/${entry.date.year}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primaryContainer.withValues(
                            alpha: 0.4,
                          ),
                          child: Icon(
                            LucideIcons.scale,
                            color: colors.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          '${entry.weight.toStringAsFixed(1)} lbs',
                          style: AppTypography.bodyLg(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          entryDate,
                          style: AppTypography.bodySm(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        trailing: Icon(
                          LucideIcons.checkCircle2,
                          color: AppColors.greenLeaf,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
