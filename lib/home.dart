import 'package:potsoft_admin/feedback_view.dart';
import 'package:potsoft_admin/request_page.dart';
import 'package:potsoft_admin/utils/my_textstyles.dart';
import 'package:potsoft_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:potsoft_admin/verification_page.dart';

import 'utils/my_colors.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final nameCntr = TextEditingController();
  final emailCntr = TextEditingController();

  checkValidations() {
    if (nameCntr.text.trim() == '' || emailCntr.text.trim() == '') {
      Utils.showAlert(
        'Alert!',
        'please make sure you have filled all the fields before submiting.n',
      );
      return;
    }

    if (nameCntr.text.trim().length < 3) {
      Utils.showAlert(
        'Alert!',
        'please enter the valid username.',
      );
      return;
    }

    // -------------------------------- email
    if (!emailCntr.text.contains('@') || !emailCntr.text.contains('.')) {
      Utils.showAlert(
        'Alert!',
        'please enter the valid email address.',
      );
      return;
    }

    final id = 'id:${nameCntr.text.trim()}~~~${emailCntr.text.trim()}}';

    addAdmins(id);
  }

  addAdmins(String id) {
    try {
      FirebaseFirestore.instance.collection('admins').doc(id).set({
        'id': id,
        'email': emailCntr.text.trim(),
        'name': nameCntr.text.trim(),
      });

      nameCntr.clear();
      emailCntr.clear();
      Utils.showSnackBar('Hurray!, admins updated.');
    } catch (e) {
      Utils.showAlert(
        'Oops!',
        'Something went wrong, please check your internet connection and try again.',
      );
    }
  }

  deleteAdmins(String id) {
    try {
      FirebaseFirestore.instance.collection('admins').doc(id).delete();
    } catch (e) {
      Utils.showAlert(
        'Oops!',
        'Something went wrong, please check your internet connection and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Potsoft Admin'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const FeedbacksView()),
            icon: const Icon(Icons.feedback_outlined),
          ),
          IconButton(
            onPressed: () => Get.to(() => const VerificationPage()),
            icon: const Icon(Icons.done_all_rounded),
          ),
          IconButton(
            onPressed: () => Get.to(() => const RequestPage()),
            icon: const Icon(Icons.notifications_active),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------------------------------- name
              TextFieldWrapper(
                TextField(
                  controller: nameCntr,
                  style: MyTStyles.kTS20Medium,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Admin name:',
                    hintStyle: MyTStyles.kTS15Medium,
                  ),
                ),
                Icons.short_text,
              ),
              // ---------------------------------- email
              TextFieldWrapper(
                TextField(
                  controller: emailCntr,
                  style: MyTStyles.kTS20Medium,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Admin email:',
                    hintStyle: MyTStyles.kTS15Medium,
                  ),
                ),
                Icons.email_outlined,
              ),
              // ---------------------------------- submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: checkValidations,
                  child: const Text('Submit'),
                ),
              ),

              // -------------------------------------------- list
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('businesses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final snapData = snapshot.data;

                    if (snapData == null || snapData.docs.isEmpty) {
                      return SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(height: 100),
                            Icon(Icons.bubble_chart_outlined, size: 30),
                            SizedBox(height: 5),
                            Text(
                              'there are no admins for now\nadd some!',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ListView.builder(
                        itemCount: snapData.docs.length,
                        itemBuilder: (context, index) {
                          final adminData = snapData.docs[index].data();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: ListTile(
                              onTap: () => Utils.confirmDialogBox(
                                'Alert',
                                'do you want to delete this business account?',
                                yesFun: () {
                                  deleteAdmins(adminData['id']);
                                  Get.back();
                                },
                              ),
                              title: Text(
                                adminData['name'],
                                style: MyTStyles.kTS16Medium,
                              ),
                              subtitle: Text(
                                adminData['email'],
                                style: MyTStyles.kTS16Medium,
                              ),
                              trailing: InkWell(
                                child: const Icon(
                                  Icons.delete,
                                  color: MyColors.darkPink,
                                ),
                                onTap: () => Utils.confirmDialogBox(
                                  'Alert',
                                  'do you want to delete this business account?',
                                  yesFun: () => deleteAdmins(adminData['id']),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldWrapper extends StatelessWidget {
  const TextFieldWrapper(this.widget, this.icon, {super.key});

  final Widget widget;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.teal,
          ),
          const SizedBox(width: 10),
          Expanded(child: widget),
        ],
      ),
    );
  }
}
