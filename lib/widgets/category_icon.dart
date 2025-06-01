import 'package:dynamic_ui/widgets/svg_image.dart';
import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        SvgImage(icon: icon, height: 48, width: 48),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
