import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String title;
  final double value;

  MyCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Sombra do card
      margin: EdgeInsets.all(16), // Margem em torno do card
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Espaço entre o título e o valor
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}