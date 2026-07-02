import 'package:flutter/material.dart';

class AiQuickQueryBubble extends StatelessWidget {
  const AiQuickQueryBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<dynamic>();
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: () {
          // Placeholder: open quick query sheet
          showModalBottomSheet(context: context, builder: (_) => const SizedBox(height: 200, child: Center(child: Text('AI Quick Query'))));
        },
        child: const Icon(Icons.auto_awesome),
      ),
    );
  }
}
