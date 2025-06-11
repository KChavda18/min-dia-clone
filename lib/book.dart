import 'package:flutter/material.dart';
import 'package:min_dia/audio_book.dart';
import 'package:min_dia/continue_listening_widget.dart';
import 'package:min_dia/listener_page.dart';

final List<AudioBook> books = [
  const AudioBook(
      id: 'atomic_habits_1',
      title: 'Atomic Habits',
      artist: 'James Clear',
      url: 'https://daq7nasbr6dck.cloudfront.net/atomic_habits/1.mp3',
      artUrl: 'https://m.media-amazon.com/images/I/81YkqyaFVEL._SL1500_.jpg'
  ),
  const AudioBook(
      id: 'sapiens_1',
      title: 'Sapiens',
      artist: 'Yuval Noah Harari',
      url: 'https://daq7nasbr6dck.cloudfront.net/sapiens/1.mp3',
      artUrl: 'https://m.media-amazon.com/images/I/713jIoMO3UL._SL1500_.jpg'
  ),
];

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Shelf')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(
                        book.artUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(book.title),
                    subtitle: Text(book.artist),
                    trailing: const Icon(Icons.play_circle_outline),
                    onTap: () {
                      // Navigate to the player, passing the selected book.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PodcastListenerWidget(book: book),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const ContinueListeningWidget(),
        ],
      ),
    );
  }
}