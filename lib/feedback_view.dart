import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbacksView extends StatelessWidget {
  const FeedbacksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedbacks')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('feedbacks').snapshots(),
        builder: (context, snapshot) {
          final snapData = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapData.docs.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 100),
                  Icon(Icons.bubble_chart_outlined, size: 30),
                  SizedBox(height: 5),
                  Text(
                    'there are no feedbacks yet!\ncome back later',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(13),
            itemCount: snapData.docs.length,
            itemBuilder: (context, index) {
              final data = snapData.docs[index].data();

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  tileColor: Colors.teal.shade100,
                  title: Text(data['feedback']),
                  trailing: Text(
                    DateFormat('dd\nMMM\nyyyy')
                        .format(data['createdOn'].toDate()),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
