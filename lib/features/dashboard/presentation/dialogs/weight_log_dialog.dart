import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/common/widgets/app_dialog.dart';
import 'package:calcount/common/widgets/app_text_field.dart';

/// Shows the dashboard weight logging dialog.
Future<void> showWeightLogDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();

  final dialogFuture = AppDialog.showCustom<void>(
    context,
    title: 'Log Current Weight',
    content: AppTextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      label: 'Weight',
      hint: 'e.g. 187.4',
      suffix: const Padding(
        padding: EdgeInsets.only(right: 12),
        child: Center(child: Text('lbs')),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          final newWeight = double.tryParse(controller.text);
          if (newWeight != null) {
            ref.read(userProfileProvider.notifier).updateWeight(newWeight);
            ref
                .read(weightHistoryProvider.notifier)
                .logWeight(newWeight, DateTime.now());
          }
          // PRESERVED: invalid values still close the dialog without mutation.
          Navigator.of(context).pop();
        },
        child: const Text('Save'),
      ),
    ],
  );

  return dialogFuture.whenComplete(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
  });
}
