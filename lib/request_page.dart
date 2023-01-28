import 'package:potsoft_admin/utils/my_colors.dart';
import 'package:potsoft_admin/utils/my_textstyles.dart';
import 'package:potsoft_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  approveUserRequest(String docId, String name, String email) {
    try {
      FirebaseFirestore.instance
          .collection('businessRequests')
          .doc(docId)
          .delete();

      FirebaseFirestore.instance.collection('businesses').doc().set({
        'id': '$name ~~~ $email ~~~ ${DateTime.now().toIso8601String()}',
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      sendEmail(email, name);
    } catch (e) {
      Utils.normalDialog();
    }
  }

  void sendEmail(String recEmail, String name) async {
    final Email email = Email(
      body:
          'Hello there $name, \n🎉Congragulations! \n\nyou have been selected as Business collaborator with Potsoft application\nNow you can view all the potholes data\n\n\nThankyou\nBest Regards\nPotsoft',
      subject: 'Your request for Business Collaborator has been verified',
      recipients: [recEmail],
    );

    await FlutterEmailSender.send(email);
    Utils.showSnackBar('Email sent Successfully!', yes: true);
  }

  deleteTheUserRequest(String docId) {
    try {
      FirebaseFirestore.instance
          .collection('businessRequests')
          .doc(docId)
          .delete();
    } catch (e) {
      Utils.normalDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Requests by Business')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('businessRequests')
            .snapshots(),
        builder: (context, snapshot) {
          final snapData = snapshot.data;

          if (snapData == null || snapData.docs.isEmpty) {
            return SizedBox(
              width: double.infinity,
              height: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 100),
                  Icon(Icons.bubble_chart_outlined, size: 30),
                  SizedBox(height: 5),
                  Text(
                    'there are no requests for now!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: snapData.docs.length,
              itemBuilder: (context, index) {
                final adminData = snapData.docs[index].data();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    color: Colors.teal.shade200.withAlpha(100),
                    child: ListTile(
                      title: Text(
                        adminData['name'],
                        style: MyTStyles.kTS16Medium,
                      ),
                      subtitle: Text(
                        adminData['email'],
                        style: MyTStyles.kTS16Medium,
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.task_alt_rounded,
                                color: Color(0xFF2F7F31),
                                size: 28,
                              ),
                              onPressed: () => approveUserRequest(
                                snapData.docs[index].id,
                                adminData['name'],
                                adminData['email'],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: MyColors.darkPink,
                                size: 26,
                              ),
                              onPressed: () => deleteTheUserRequest(
                                snapData.docs[index].id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
