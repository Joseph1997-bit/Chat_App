import 'package:circle_list/circle_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';

class GeneralMessagingSection extends StatefulWidget {
  const GeneralMessagingSection({Key? key}) : super(key: key);

  @override
  State<GeneralMessagingSection> createState() =>
      _GeneralMessagingSectionState();
}

class _GeneralMessagingSectionState extends State<GeneralMessagingSection> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            //iconlari hareket eden bi daire icinde koymak icin CircleList paketi ve widgeti kullandim
            child: CircleList(
              initialAngle: 55,
              outerRadius: MediaQuery.of(context).size.width / 2.2,//outerRadius ozelligi disardan  dairenin boyutunu veya siniri belirliyo
              innerRadius: MediaQuery.of(context).size.width / 4,//innerRadius ozelligi tadadan veya icerden dairenin boyutunu/siniri belirliyo
           //ekrandaki dairenin boyutunu belirledikten sonra ekleyecegimiz widgetlar icinde olacak ve daire icinde hareket edebilir
              showInitialAnimation: true,//general kismi actiktan sonra otomatik olarak  widgetlar hareket eder
              innerCircleColor: Colors.blueGrey,//icerdeki dairenin rengi
              outerCircleColor: Colors.white24,//disardaki dairenin rengi
              origin: Offset(2, 0),
              rotateMode: RotateMode.allRotate,
              centerWidget: Center(
                child: Text(
                  "Send",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 50.0,
                  ),
                ),
              ),
              children: [
                //her icon icin bi daire icinde olack bu daire container widgeti kullanarak yaptim
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(//container'i yuvarlak yapmak icin borderRadius ozelligi kulllandim
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(//sinirlara genislik veya kalinlik vermek icin border ozelligi kullandim
                        color: Colors.black,
                        width: 3,
                      )),
                  //iconlara tiklama ozelligi eklemek icin GestureDetector ekledim
                  child: GestureDetector(
                    onTap: () async {
                      //_imageOrVideoSend(imageSource: ImageSource.camera);
                    },
                    onLongPress: () async {
                      //_imageOrVideoSend(imageSource: ImageSource.gallery);
                    },
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.greenAccent,
                      size: 35.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      // _imageOrVideoSend(
                      //     imageSource: ImageSource.camera, type: 'video');
                    },
                    onLongPress: () async {
                      // _imageOrVideoSend(
                      //     imageSource: ImageSource.gallery, type: 'video');
                    },
                    child: Icon(
                      Icons.video_collection,
                      color: Colors.black,
                      size: 35.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      //_extraTextManagement(MediaTypes.Text);
                    },
                    child: Icon(
                      Icons.text_fields_rounded,
                      color: Colors.lightBlueAccent,
                      size: 35.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      //await _documentSend();
                    },
                    child: Icon(
                      Icons.folder_copy,
                      color: Colors.greenAccent,
                      size: 35.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      // if (!await NativeCallback().callToCheckNetworkConnectivity())
                      //   _showDiaLog(titleText: 'No Internet Connection');
                      // else {
                      //   _showDiaLog(titleText: 'Wait for map');
                      //   await _locationSend();
                      // }
                    },
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.black,
                      size: 35.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      )),
                  child: GestureDetector(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.lightBlueAccent ,
                      size: 35.0,
                    ),
                    onTap: () async {
                      //await _voiceSend();
                    },
                  ),
                ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}
