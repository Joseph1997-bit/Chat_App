import 'dart:io';
import 'package:animations/animations.dart';
import 'package:circle_list/circle_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

import '../../../Backend/firebase/OnlineDatabaseManagment/cloud_data_managment.dart';
import '../../../Backend/sqlite_management/local_database_management.dart';
import '../../../Global_Uses/constants.dart';
import '../../../Global_Uses/enum.dart';
import '../../Preview/image_preview_screen.dart';
import '../../model/previous_message_structure.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
   ChatScreen({ required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = false;
  bool _writeTextPresent = false;
  bool _showEmojiPicker = false;
  String _connectionEmail = "";
  bool _lastDirection=false;
  final FirestoreFieldConstants _firestoreFieldConstants = FirestoreFieldConstants();
late Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;
 final FToast _fToast = FToast();
 // final String _messageAndTimeSeparator="[[[Message_And_Time_Separator]]]";
  List<Map<String, String>> _allConversationMessages = [];
  List<bool> _conversationMessageHolder = [];
  List<ChatMessageTypes> _chatMessageCategoryHolder = [ChatMessageTypes.Text,ChatMessageTypes.Text];
  final TextEditingController _typedText = TextEditingController();

  final CloudStoreDataManagement _cloudStoreDataManagement =
  CloudStoreDataManagement();
  final LocalDatabase _localDatabase = LocalDatabase();
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
  );

 _takePermissionForStorage() async {
    var status = await Permission.storage.request();
    /*if (status == PermissionStatus.granted) {
      {
        // showToast("Thanks For Storage Permission", _fToast,
        //     toastColor: Colors.green, fontSize: 16.0);

      }
    } else {
      showToast("Some Problem May Be Arrive", _fToast,
          toastColor: Colors.green, fontSize: 16.0);
    }*/
  }



  _getConnectionEmail() async {
    final String? getUserEmail =
    await _localDatabase.getParticularFieldDataFromImportantTable(
        userName: widget.userName,
        getField: GetFieldForImportantDataLocalDatabase.UserEmail);

    if (mounted) {
      setState(() {
        _connectionEmail = getUserEmail.toString();
      });
    }
  }

  /// Fetch Real Time Data From Cloud Firestore
  Future<void> _fetchIncomingMessages() async {
    final Stream<QuerySnapshot<Map<String, dynamic>>>? realTimeSnapshot =
    await this._cloudStoreDataManagement.fetchRealTimeDataFromFirestore();

    if (mounted) {
      setState(() {
        this._stream = realTimeSnapshot  ;
      });
    }
    realTimeSnapshot!.listen((querySnapshot) {
      querySnapshot.docs.forEach((queryDocumentSnapshot) async{
        if(queryDocumentSnapshot.id== FirebaseAuth.instance.currentUser!.email.toString()){
          await _checkingForIncomingMessages(queryDocumentSnapshot, querySnapshot.docs);
        }
      });
    });
  }

  Future<void> _checkingForIncomingMessages(QueryDocumentSnapshot<Map<String,dynamic>> queryDocumentSnapshot,
      List<QueryDocumentSnapshot<Map<String,dynamic>>> docs
  ) async {

    final Map<String, dynamic> _connectionsList = queryDocumentSnapshot.get(_firestoreFieldConstants.connections)!;

    List<dynamic>? getIncomingMessages = _connectionsList[_connectionEmail];

    if (getIncomingMessages != null) {
      //eski mesajlar tekrar birden fazla ekranda gozukmesin diye silmemiz lazim
      await _cloudStoreDataManagement.removeOldMessages(connectionEmail: _connectionEmail);
        getIncomingMessages.forEach((everyMessage) {
          if (everyMessage.keys.first.toString() == ChatMessageTypes.Text.toString()) {
            Future.microtask(() {
              _manageIncomingTextMessages(everyMessage.values.first);
            });
          }
        });

    }

    print('Get Incoming Messages: $getIncomingMessages');
  }



  _manageIncomingTextMessages(var textMessage) async {
    await _localDatabase.insertMessageInUserTable(
        userName: widget.userName,
        actualMessage: textMessage.keys.first.toString(),
        chatMessageTypes: ChatMessageTypes.Text,
        messageHolderType: MessageHolderType.ConnectedUsers,
        messageDateLocal: DateTime.now().toString().split(" ")[0],
        messageTimeLocal: textMessage.values.first.toString());

    if (mounted) {
      setState(() {
        _allConversationMessages.add({
          textMessage.keys.first.toString():
          textMessage.values.first.toString(),
        });
        _chatMessageCategoryHolder.add(ChatMessageTypes.Text);
        _conversationMessageHolder.add(true);
      });
    }

    if (mounted) {
      setState(() {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent +
              _amountToScroll(ChatMessageTypes.Text)+30.0,
        );
      });
    }
  }



  Future<void> _storeAndShowIncomingMessageData(
      {required String mediaFileLocalPath,
        required ChatMessageTypes chatMessageTypes,
        required var mediaMessage}) async {
    try {
      await _localDatabase.insertMessageInUserTable(
          userName: widget.userName,
          actualMessage: mediaFileLocalPath,
          chatMessageTypes: chatMessageTypes,
          messageHolderType: MessageHolderType.ConnectedUsers,
          messageDateLocal: DateTime.now().toString().split(" ")[0],
          messageTimeLocal: mediaMessage.values.first.toString());

      if (mounted) {
        setState(() {
          this._allConversationMessages.add({
            mediaFileLocalPath: mediaMessage.values.first.toString(),
          });
          this._chatMessageCategoryHolder.add(chatMessageTypes);
          this._conversationMessageHolder.add(true);
        });
      }
    } catch (e) {
      print("Error in Store And Show Message: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          this._isLoading = false;
        });
      }
    }
  }

  _loadPreviousStoredMessages() async {
    double _positionToScroll = 100.0;

    try {
      // if (mounted) {
      //   setState(() {
      //     this._isLoading = true;
      //   });
      // }

      List<PreviousMessageStructure> _storedPreviousMessages =
      await _localDatabase.getAllPreviousMessages(widget.userName);

      for (int i = 0; i < _storedPreviousMessages.length; i++) {
        final PreviousMessageStructure _previousMessage =
        _storedPreviousMessages[i];

        if (mounted) {
          setState(() {
            this._allConversationMessages.add({
              _previousMessage.actualMessage: _previousMessage.messageTime,
            });
            this._chatMessageCategoryHolder.add(_previousMessage.messageType);
            this._conversationMessageHolder.add(_previousMessage.messageHolder);

            _positionToScroll += _amountToScroll(_previousMessage.messageType,
                actualMessageKey: _previousMessage.actualMessage);
          });
        }
      }
    } catch (e) {
      print("Previous Message Fetching Error in ChatScreen: ${e.toString()}");
    } finally {
      // if (mounted) {
      //   setState(() {
      //     this._isLoading = false;
      //   });
      // }

      if (mounted) {
        setState(() {
          print("Position to Scroll: $_positionToScroll");
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent + _positionToScroll,
          );
        });
      }
      await _fetchIncomingMessages();
    }
  }
  @override
  void initState() {
    _fToast.init(context);

    _takePermissionForStorage();
    _getConnectionEmail();
    _fetchIncomingMessages();
   // _loadPreviousStoredMessages();

    super.initState();
  }

  @override
  void dispose() {
    _stream!.listen((event) { }).cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        bottomSheet: _bottomInsertionPortion(context),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: const Color.fromRGBO(25, 39, 52, 1),
          elevation: 0.0,
          title: Text(widget.userName),
          leading: Row(
            children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: OpenContainer(
                  closedColor: const Color.fromRGBO(25, 39, 52, 1),
                  middleColor: const Color.fromRGBO(25, 39, 52, 1),
                  openColor: const Color.fromRGBO(25, 39, 52, 1),
                  closedShape: CircleBorder(),
                  closedElevation: 0.0,
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: Duration(milliseconds: 500),
                  openBuilder: (_, __) {
                    return Center();
                  },
                  closedBuilder: (_, __) {
                    return CircleAvatar(
                      radius: 23.0,
                      backgroundColor: const Color.fromRGBO(25, 39, 52, 1),
                      backgroundImage: ExactAssetImage(
                        "assets/images/google.png",
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.call,
                color: Colors.green,
              ),
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          color: Colors.black,
          child: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * (11.15 / 15),
          //  margin: EdgeInsets.all(12.0),
            child:ListView(
              reverse: true,
              children: [
                Container(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height-210,
                 child: ListView.builder(
                   shrinkWrap: true,
                   itemCount: _allConversationMessages.length,
                   itemBuilder: (context, index) {
                     if (this._chatMessageCategoryHolder[index] == ChatMessageTypes.Text)
                   return _textConversationManagement(context,index);
                     else if (this._chatMessageCategoryHolder[index] == ChatMessageTypes.Image)
                       return _mediaConversationManagement(context, index);
                     return Center();
                 },),
                ),

              ],
            ) ,
          ),
        ),
      ),
    );
  }

  Widget _bottomInsertionPortion(BuildContext context) {
    return BottomSheet(
      backgroundColor:const Color.fromRGBO(34, 48, 60, 1) ,
      onClosing: (){}, builder: (context) {
      return Container(
        width: double.maxFinite,
        height: 80.0,
        decoration: BoxDecoration(
            color: const Color.fromRGBO(25, 39, 52, 1),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
        child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.amber,
                ),
                onPressed: () {
                  print('Clicked Emoji');
                  if (mounted) {
                    setState(() {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      this._showEmojiPicker = true;
                      //_chatBoxHeight -= 300;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                child: GestureDetector(
                  child: Icon(
                    Entypo.link,
                    color: Colors.lightBlue,
                  ),
                  onTap: (){
                    _differentChatOptions();
                  },
                ),
              ),
             Expanded(
                child: SizedBox(
                  width: double.maxFinite,
                  height: 60.0,
                  child: TextField(
                    controller:_typedText,
                    style: TextStyle(color: Colors.white),
                    maxLines: null,//null degeri yapinca satirlar ust uste olur
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
                      ),
                    ),
                    onTap: () {
                      if (mounted) {
                        setState(() {
                      //    this._chatBoxHeight += 300;
                          this._showEmojiPicker = false;
                        });
                      }
                    },
                    onChanged: (writeText) {
                    //textField bos ise sesli mesaj iconu gosterck bos degilse mesaj iconu gosterck
                      if (mounted) {
                        setState(() {
                          writeText.isEmpty ? _writeTextPresent = false : _writeTextPresent = true;
                        });
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: GestureDetector(
                  child: _writeTextPresent
                      ? Icon(
                    Icons.send,
                    color: Colors.green,
                    size: 30.0,
                  )
                      : Icon(
                    Icons.keyboard_voice_rounded,
                    color: Colors.green,
                    size: 30.0,
                  ),
                  onTap:  _sendText
                ),
              ),
            ]
        ),

      );

    },);
  }
  void _sendText() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (this._writeTextPresent) {
      if (mounted) {
        setState(() {
          this._isLoading = true;

        });
      }

      final String _messageTime =
          "${DateTime.now().hour}:${DateTime.now().minute}";
     //talebi kabul edenlere mesaj atmak icin asagidaki fonksyonu kullanacz
      await _cloudStoreDataManagement.sendMessageToConnection(
          connectionUserName: widget.userName,
          sendMessageData: {ChatMessageTypes.Text.toString(): {
              _typedText.text: _messageTime,
            },
          },
          chatMessageTypes: ChatMessageTypes.Text);

      if (mounted) {
        setState(() {
          this._allConversationMessages.add({
            this._typedText.text: _messageTime,
          });
          this._chatMessageCategoryHolder.add(ChatMessageTypes.Text);
          this._conversationMessageHolder.add(false);
        });
      }
      if (mounted) {
        setState(() {
          this._typedText.clear();
          this._isLoading = false;
          this._writeTextPresent = false;
        });
      }
      if (mounted) {
        setState(() {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent +
                _amountToScroll(ChatMessageTypes.Text)+30.0,

          );
        });
      }

      await _localDatabase.insertMessageInUserTable(
          userName: widget.userName,
          actualMessage: _typedText.text,
          chatMessageTypes: ChatMessageTypes.Text,
          messageHolderType: MessageHolderType.Me,
          messageDateLocal: DateTime.now().toString().split(" ")[ 0],
          messageTimeLocal: _messageTime);

      if (mounted) {
        setState(() {
          this._typedText.clear();
          this._isLoading = false;
          this._writeTextPresent = false;
        });
      }
    }
  }
  double _amountToScroll(ChatMessageTypes chatMessageTypes,
      {String? actualMessageKey}) {
    switch (chatMessageTypes) {
      case ChatMessageTypes.None:
        return 10.0 + 30.0;
      case ChatMessageTypes.Text:
        return 10.0 + 30.0;
      case ChatMessageTypes.Image:
        return MediaQuery.of(context).size.height * 0.6;
      case ChatMessageTypes.Video:
        return MediaQuery.of(context).size.height * 0.6;
      case ChatMessageTypes.Document:
        return actualMessageKey!.contains('.pdf')
            ? MediaQuery.of(context).size.height * 0.6
            : 70.0 + 30.0;

      case ChatMessageTypes.Audio:
        return 70.0 + 30.0;
      case ChatMessageTypes.Location:
        return MediaQuery.of(context).size.height * 0.6;
    }
  }
  void _differentChatOptions() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          elevation: 0.3,
          backgroundColor: Color.fromRGBO(34, 48, 60, 0.5),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.7,
            child: Center(
              child: CircleList(
                initialAngle: 55,
                outerRadius: MediaQuery.of(context).size.width / 3.2,
                innerRadius: MediaQuery.of(context).size.width / 10,
                showInitialAnimation: true,
                innerCircleColor: Color.fromRGBO(34, 48, 60, 1),
                outerCircleColor: Color.fromRGBO(0, 0, 0, 0.1),
                origin: Offset(0, 0),
                rotateMode: RotateMode.allRotate,
                centerWidget: Center(
                  child: Text(
                    "G",
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 45.0,
                    ),
                  ),
                ),
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        )),
                    child: GestureDetector(
                      onTap: () async {//foto cekip atmak icin kullanacz
                        final pickedImage = await ImagePicker().pickImage(
                            source: ImageSource.camera, imageQuality: 50);
                        if (pickedImage != null) {
                          _addSelectedMediaToChat(pickedImage.path);
                        }
                        },

                      onLongPress: () async {//galeri'den foto secip atmak icin kullanacz
                        final XFile? pickedImage = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 50);
                        if (pickedImage != null) {
                          //fotoyu sectikten sonra onu tipi/path asagidaki fonksyona atip ekranda gostermek icin
                          _addSelectedMediaToChat(pickedImage.path);
                        }
                      },
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.lightGreen,
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        )),
                    child: GestureDetector(
                      onTap: () async {
                        if (mounted) {
                          setState(() {
                            this._isLoading = true;
                          });
                        }

                      },
                      onLongPress: () async {
                        if (mounted) {
                          setState(() {
                            this._isLoading = true;
                          });
                        }

                      },
                      child: Icon(
                        Icons.video_collection,
                        color: Colors.lightGreen,
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        )),
                    child: GestureDetector(
                      onTap: () async {
                     //   await _pickFileFromStorage();
                      },
                      child: Icon(
                        Icons.document_scanner_outlined,
                        color: Colors.lightGreen,
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        )),
                    child: GestureDetector(
                      onTap: () async {

                      },
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.lightGreen,
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        )),
                    child: GestureDetector(
                      child: Icon(
                        Icons.music_note_rounded,
                        color: Colors.lightGreen,
                      ),
                      onTap: () async {
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
  void _addSelectedMediaToChat(String path, {ChatMessageTypes chatMessageTypeTake = ChatMessageTypes.Image, String thumbnailPath = ''}) {
    //butoni basinca veya fotoyu secince asaidaki islemler gercekleseck
    Navigator.pop(context);
    print('Thumbnail Path: $thumbnailPath    ${File(path).path}');

    final String _messageTime = "${DateTime.now().hour}:${DateTime.now().minute}";//simdi sati ve dakyi eklemek icin bu fonksyonu kullanacz

    if (mounted) {
      setState(() {
        this._allConversationMessages.add({
            File(path).path: _messageTime + '',
        });

        this._chatMessageCategoryHolder.add(ChatMessageTypes.Image);
        _conversationMessageHolder.add(_lastDirection);
        _lastDirection=!_lastDirection;

      });
    }

  }

  Widget _textConversationManagement(
      BuildContext itemBuilderContext, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        //_conversationMessageHolder degeri true ise demeki baska kullanici tarafindan mesaj gelmistir
        Container(//mesajin boyutunu ayarlamak icin ve sagdan ve soldan bpsluk vermek icin
          margin: _conversationMessageHolder[index]
              ? EdgeInsets.only(
            right: MediaQuery.of(context).size.width / 3,
            left: 5.0,
          )
              : EdgeInsets.only(
            left: MediaQuery.of(context).size.width / 3,
            right: 5.0,
          ),
          alignment: _conversationMessageHolder[index]
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: ElevatedButton(//her mesaja bazi ozellikler vermek icin silme,cevap verme gbi ElevatedButton kullandim
            style: ElevatedButton.styleFrom(
              primary: _conversationMessageHolder[index]
                  ? Color.fromRGBO(60, 80, 100, 1)
                  : Color.fromRGBO(102, 102, 255, 1),
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              //mesaji gonderen kisiye isaret etmek icin shape ve RoundedRectangleBorder ozelligini kullandim
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(//diger kullanicilara isaret etmek icin kucuk bi isaret
                  topLeft: this._conversationMessageHolder[index]
                      ? Radius.circular(0.0)
                      : Radius.circular(20.0),
                  topRight: this._conversationMessageHolder[index]
                      ? Radius.circular(20.0)
                      : Radius.circular(0.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
            child: Text(
              _allConversationMessages[index].keys.first,
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            onPressed: () {},
            onLongPress: () {},
          ),
        ),
         //mesajlar altinda zamanlari ayarlamak icin _conversationMessageTime fonksyonun kullandim
        _conversationMessageTime(_allConversationMessages[index].values.first, index),
      ],
    );
  }
  Widget _conversationMessageTime(String time, int index) {
    return Container(
      alignment: this._conversationMessageHolder[index]
          ? Alignment.centerLeft
          : Alignment.centerRight,
      margin: this._conversationMessageHolder[index]
          ? const EdgeInsets.only(
        left: 5.0,
        bottom: 5.0,
        top: 5.0,
      )
          : const EdgeInsets.only(
        right: 5.0,
        bottom: 5.0,
        top: 5.0,
      ),
       child: _timeReFormat(_allConversationMessages[index].values.first),
    );
  }

  Widget _timeReFormat(String _willReturnTime) {
    if (int.parse(_willReturnTime.split(':')[0]) < 10) {
      _willReturnTime = _willReturnTime.replaceRange(
          0, _willReturnTime.indexOf(':'), '0${_willReturnTime.split(':')[0]}');}

    if (int.parse(_willReturnTime.split(':')[1]) < 10) {
      _willReturnTime = _willReturnTime.replaceRange(
          _willReturnTime.indexOf(':') + 1,
          _willReturnTime.length,
          '0${_willReturnTime.split(':')[1]}');
    }
    return Text(
      _willReturnTime,
      style: const TextStyle(color: Colors.lightBlue),
    );
  }

  Widget _mediaConversationManagement(
      BuildContext itemBuilderContext, int index) {
    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            margin: this._conversationMessageHolder[index]
                ? EdgeInsets.only(
              right: MediaQuery.of(context).size.width / 3,
              left: 5.0,
              top: 30.0,
            )
                : EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 3,
              right: 5.0,
              top: 15.0,
            ),
            alignment: this._conversationMessageHolder[index]
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: OpenContainer(
              openColor: const Color.fromRGBO(60, 80, 100, 1),
              closedColor: this._conversationMessageHolder[index]
                  ? const Color.fromRGBO(60, 80, 100, 1)
                  : const Color.fromRGBO(102, 102, 255, 1),
              middleColor: Color.fromRGBO(60, 80, 100, 1),
              closedElevation: 0.0,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              transitionDuration: Duration(
                milliseconds: 400,
              ),
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (context, openWidget) {
                return ImageViewScreen(
                  imagePath: _chatMessageCategoryHolder[index] == ChatMessageTypes.Image ? _allConversationMessages[index].keys.first
                      : _allConversationMessages[index].keys.first.split("+")[0],
                  imageProviderCategory: ImageProviderCategory.FileImage,
                );
              },
              closedBuilder: (context, closeWidget) => Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: PhotoView(
                      imageProvider: FileImage(
                          File(
                          this._chatMessageCategoryHolder[index] ==
                              ChatMessageTypes.Image
                              ? this._allConversationMessages[index].keys.first
                              : this
                              ._allConversationMessages[index]
                              .keys
                              .first
                              .split("+")[0])),
                      loadingBuilder: (context, event) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorBuilder: (context, obj, stackTrace) => Center(
                          child: Text(
                            'Image not Found',
                            style: TextStyle(
                              fontSize: 23.0,
                              color: Colors.red,
                              fontFamily: 'Lora',
                              letterSpacing: 1.0,
                            ),
                          )),
                      enableRotation: true,
                      minScale: PhotoViewComputedScale.covered,
                    ),
                  ),
                  if (this._chatMessageCategoryHolder[index] == ChatMessageTypes.Video)
                    Center(
                      child: IconButton(
                        iconSize: 100.0,
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          print(
                              "Opening Path is: ${this._allConversationMessages[index].keys.first.split("+")[1]}");

                          final OpenResult openResult = await OpenFile.open(this
                              ._allConversationMessages[index]
                              .keys
                              .first
                              .split("+")[1]);
                          if (mounted) {
                            setState(() {
                              this._typedText.clear();
                              this._isLoading = false;
                              this._writeTextPresent = false;
                            });
                          }
                       //   openFileResultStatus(openResult: openResult);
                        },
                      ),
                    ),
                ],
              ),
            )),
        _conversationMessageTime(
            this._allConversationMessages[index].values.first.split("+")[0],
            index),
      ],
    );
  }
}
