import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  final String id;
  const ProductPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product ID $id')),
      body: Center(child: Text('This is the Product page.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
