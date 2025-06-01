import 'package:dynamic_ui/widgets/svg_image.dart';
import 'package:flutter/material.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.svgString,
    this.title,
    this.subTtitle,
  });

  final String? svgString;
  final String? title;
  final String? subTtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4), // Set your desired radius
        color: Colors.yellow.shade100,
      ),
      constraints: BoxConstraints(
        maxWidth: 240, // optional: set max height
      ),

      child: ListTile(
        leading: svgString != null
            ? SvgImage(icon: svgString!, height: 40, width: 40)
            //  SvgPicture.string(
            //     Uri.decodeComponent(svgString),
            //     colorMapper: const _MyColorMapper(),
            //     height: 40,
            //   )
            : null,
        title: Text(
          title ?? '',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Text(
          subTtitle ?? '',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
