import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgImage extends StatelessWidget {
  const SvgImage({super.key, required this.icon, this.height, this.width});

  final String icon;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      Uri.decodeComponent(icon),
      colorMapper: const _MyColorMapper(),
      height: height,
      width: width,
    );
  }
}

class _MyColorMapper extends ColorMapper {
  const _MyColorMapper();

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == const Color(0xFFFF0000)) {
      return Colors.blue;
    }
    if (color == const Color(0xFF00FF00)) {
      return Colors.yellow;
    }
    return color;
  }
}
