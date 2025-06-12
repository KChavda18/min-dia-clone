import 'package:flutter/material.dart';
import 'package:min_dia/continue_listening_widget.dart';
import 'book.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast Reader')),
      // Use a Column to stack the main content and the listening widget.
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookPage()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.book, size: 150, color: Colors.blue),
                    const SizedBox(height: 20),
                    const Text(
                      'Open Book',
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Add the continue listening widget at the bottom.
          const ContinueListeningWidget(),
        ],
      ),
    );
  }
}
