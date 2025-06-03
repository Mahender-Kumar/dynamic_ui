import 'package:flutter/material.dart';

class DealsOfTheDay extends StatelessWidget {
  const DealsOfTheDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deals of the Day')),
      body: Center(child: Text('')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
