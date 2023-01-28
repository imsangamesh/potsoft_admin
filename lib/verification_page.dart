import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:potsoft_admin/utils/buttons.dart';
import 'package:potsoft_admin/utils/my_colors.dart';
import 'package:potsoft_admin/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'utils/my_textstyles.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifications')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('potholes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final snapData = snapshot.data;

          if (snapData == null || snapData.docs.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 50),
                  Icon(Icons.bubble_chart_outlined, size: 30),
                  SizedBox(height: 5),
                  Text(
                    'there are no under-verification potholes for now!\nplease come back later...',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: PageView.builder(
              itemCount: snapData.docs.length,
              itemBuilder: (context, index) {
                final data = snapData.docs[index].data();
                return Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: ImageTile(data: data)),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 226, 177),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                labelText('Name', data['name']),
                                labelText('Street', data['street']),
                                labelText('Country', data['country']),
                                labelText('Postal-code', data['postCode']),
                                labelText('City', data['city']),
                                labelText('Sub area', data['subArea']),
                                labelText(
                                    'latitude', data['lat'].toStringAsFixed(2)),
                                labelText('longitude',
                                    data['long'].toStringAsFixed(2)),
                                labelText(
                                  'uploaded on',
                                  DateFormat('dd MMM yyy  |  hh:mm')
                                      .format(DateTime.parse(data['date'])),
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: MyOutlinedBtn(
                                    'View in Google Map',
                                    () => openGoogleMap(
                                        data['lat'], data['long']),
                                    icon: Icons.launch_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Row(
                        children: [
                          // ============================================ deny
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.darkPink,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                ),
                                onPressed: () => deny(data),
                                child: Text(
                                  'Deny',
                                  style: MyTStyles.kTS16Bold
                                      .copyWith(color: MyColors.wheat),
                                ),
                              ),
                            ),
                          ),
                          // ============================================ approve
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF008E1F),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                ),
                                onPressed: () => approve(data),
                                child: Text(
                                  'Approve',
                                  style: MyTStyles.kTS16Bold
                                      .copyWith(color: MyColors.wheat),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  approve(Map<String, dynamic> dataMap) async {
    try {
      await FirebaseFirestore.instance
          .collection('potholes')
          .doc(dataMap['id'])
          .delete();

      await FirebaseFirestore.instance
          .collection('verifiedPotholes')
          .doc(dataMap['id'])
          .set(dataMap);

      //
    } on FirebaseException catch (e) {
      Utils.showAlert(e.code, e.message.toString());
    } catch (e) {
      Utils.normalDialog();
    }
  }

  deny(Map<String, dynamic> dataMap) async {
    try {
      await FirebaseFirestore.instance
          .collection('potholes')
          .doc(dataMap['id'])
          .delete();

      //
    } on FirebaseException catch (e) {
      Utils.showAlert(e.code, e.message.toString());
    } catch (e) {
      Utils.normalDialog();
    }
  }

  static openGoogleMap(double lat, double long) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    await launchUrlString(url);
  }

  labelText(String title, String subtitle) {
    return RichText(
      text: TextSpan(
        text: '$title: ',
        style: MyTStyles.kTS16Medium.copyWith(
          color: Get.isDarkMode ? const Color(0xFFDBDBDB) : MyColors.black,
          height: 1.5,
        ),
        children: [TextSpan(text: subtitle, style: MyTStyles.kTS16Regular)],
      ),
    );
  }
}

class ImageTile extends StatelessWidget {
  const ImageTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GestureDetector(
        onTap: () => Get.to(() => ImageViewer(data['image'])),
        child: Image.network(
          data['image'],
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: 200,
              width: 200,
              child: Center(
                child: SizedBox(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      value: loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  const ImageViewer(this.image, {super.key});
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Image.network(image),
    );
  }
}
