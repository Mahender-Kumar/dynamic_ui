import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final String? url;
  const BannerImage({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Set your desired radius
          image: DecorationImage(
            image: NetworkImage((url!)),
            fit: BoxFit.cover,
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: 200, // optional: set max height
          maxWidth: double.infinity, // optional: set max width
        ),
      ),
    );
  }
}
