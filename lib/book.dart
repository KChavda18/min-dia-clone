import 'package:flutter/material.dart';
import 'package:min_dia/continue_listening_widget.dart';
import 'package:min_dia/listener_page.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      // Use a Column to stack the main content and the listening widget.
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PodcastListenerWidget(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.audiotrack,
                            size: 150, color: Colors.blue),
                        const SizedBox(height: 20),
                        const Text(
                          'Listen to Book',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
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
