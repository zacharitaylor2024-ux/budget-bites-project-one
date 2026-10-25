import 'package:flutter/material.dart';
import '../db/models.dart';
import '../helper/lunch_lens.dart';

/// Shows the Lunch Lens estimate. Never saves anything itself:
/// "Use as draft" only hands the amount back to the purchase form.
class LunchLensCard extends StatelessWidget {
  final LunchLensResult lens;
  final ValueChanged<int> onUseDraft;
  final VoidCallback onDismiss;
  const LunchLensCard(
      {super.key,
      required this.lens,
      required this.onUseDraft,
      required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.lightbulb_outline),
            const SizedBox(width: 8),
            Text('Lunch Lens (estimate)', style: text.titleSmall),
          ]),
          const SizedBox(height: 8),
          if (lens.estimateCents != null)
            Text('Estimated next cost: ${money(lens.estimateCents!)}',
                style: text.titleLarge),
          Text(lens.explanation),
          if (lens.baselineCents != null)
            Text('Last paid: ${money(lens.baselineCents!)}',
                style: text.bodySmall),
          if (lens.hasOutlier)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                  'One recent price looks unusual, so this estimate may be off.',
                  style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 8),
          Row(children: [
            if (lens.estimateCents != null)
              FilledButton.tonal(
                  onPressed: () => onUseDraft(lens.estimateCents!),
                  child: const Text('Use as draft')),
            const SizedBox(width: 8),
            TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
          ]),
        ]),
      ),
    );
  }
}
