import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String? image;
  final String? title;
  final String? price;
  final String? color;
  const ProductCard({
    super.key,
    this.image,
    this.title,
    this.price,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null || image == '') {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: 120,
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,

        children: [
          Image.network(image!, height: 160, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title ?? '',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse(color ?? '0xFFFFF9C4')),
                  ),
                  alignment: Alignment.center,

                  constraints: BoxConstraints(minHeight: 32),
                  child: Text(
                    price ?? '',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
