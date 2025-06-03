import 'package:dynamic_ui/widgets/svg_image.dart';
import 'package:flutter/material.dart';

class TypeCard extends StatelessWidget {
  const TypeCard({super.key, required this.iconName, required this.title});

  final String iconName;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgImage(icon: iconName, height: 40, width: 40),
            const SizedBox(height: 8),
            Text(
              'BUY',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.arrow_forward, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
