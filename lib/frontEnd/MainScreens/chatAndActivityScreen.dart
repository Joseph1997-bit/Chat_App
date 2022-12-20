import 'package:animations/animations.dart';
import 'package:bitirme_projesi1/frontEnd/Services/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../Backend/firebase/OnlineDatabaseManagment/cloud_data_managment.dart';
import '../../Backend/sqlite_management/local_database_management.dart';
import '../../Global_Uses/constants.dart';
import '../../Global_Uses/enum.dart';
import '../Services/ChatManagement/chat_screen.dart';

class ChatAndActivityScreen extends StatefulWidget {
  const ChatAndActivityScreen({Key? key}) : super(key: key);

  @override
  State<ChatAndActivityScreen> createState() => _ChatAndActivityScreenState();
}

class _ChatAndActivityScreenState extends State<ChatAndActivityScreen> {
 // final List<String> _allUserConnectionActivity = ['ibo','joseph','mariya','yahya','nergis','mohhamed','inas','alhuriya','];
  final List<String> _allConnectionsUserName = [];
  bool _isLoading = false;

  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  final LocalDatabase _localDatabase = LocalDatabase();

  static final FirestoreFieldConstants _firestoreFieldConstants =
  FirestoreFieldConstants();

  /// For New Connected User Data Entry
  Future<void> _checkingForNewConnection(
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
   //degiskenler veya parametreler tipi QueryDocumentSnapshot oldugu icin o yuzden boyle uzun yazildi
    if (mounted) {
      setState(() {
        this._isLoading = true;
      });
    }
//bu queryDocumentSnapshot simdiki kullanicinin documenti ve icindeki alanlari temsil ediyor ve get method ile istedigmiz bilgiyi getirebiliriz.
    //get kullanark bilgil almak icin String degerleri yerine enum degeri kullandim hata olmasin diye.connectionRequest ="connection_request"
    final List<dynamic> _connectionRequestList = queryDocumentSnapshot.get(_firestoreFieldConstants.connectionRequest);

    _connectionRequestList.forEach((connectionRequestData) {
      //parametre olara gelen bilgiller eger isteği kabul etyse asagidaki islemleri yapilsin
      if (connectionRequestData.values.first.toString() == OtherConnectionStatus.Invitation_Accepted.toString() ||
          connectionRequestData.values.first.toString() == OtherConnectionStatus.Request_Accepted.toString()) {
       //docs parametresi parametre olarak gelen kullanicilarin documentleri temsil  ediyor
        docs.forEach((everyDocument) async {//docs tum kullanicilarin documentleri temsil ediyor
          if (everyDocument.id == connectionRequestData.keys.first.toString()) {//diger kullanicilarin accept durumu simdiki kullanicinin ayni ise diger kullanicilarin bilgileri getirp ekranda gosterecz
            final String _connectedUserName = everyDocument.get(_firestoreFieldConstants.userName);//get metohd ile String degerleri yerine enum kullaniyoz hata olmasin diye
            final String _token = everyDocument.get(_firestoreFieldConstants.token);
            final String _about = everyDocument.get(_firestoreFieldConstants.about);
            final String _accCreationDate = everyDocument.get(_firestoreFieldConstants.creationDate);
            final String _accCreationTime = everyDocument.get(_firestoreFieldConstants.creationTime);
             //isteği kabul ettikten sonra _allConnectionsUserName listesine kullanici adi ekleyip widget ve initState icinde koydugmuz icin otomatik gosterileck
            if (mounted) {
              setState(() {
                if (!_allConnectionsUserName.contains(_connectedUserName))
                  _allConnectionsUserName.add(_connectedUserName);
              });
            }
            //kullanici bilgileri asagidaki fonksyonu kullanark isert fonksyon icindeki maplara ekliyoz ve true dondurck
            final bool _newConnectionUserNameInserted = await _localDatabase.insertOrUpdateDataForThisAccount(
                userName: _connectedUserName,
                userMail: everyDocument.id,
                userToken: _token,
                userAbout: _about,
                userAccCreationDate: _accCreationDate,
                userAccCreationTime: _accCreationTime);
               //diger kullanicilarin bilgileri map'lara atiktan sonra her kullanici icin ayri bi tablo olusturyoz bilgileri saklamak icin
            if (_newConnectionUserNameInserted==true) {
              await _localDatabase.createTableForEveryUser(
                  userName: _connectedUserName);
            }
          }
        });
      }
    });

    if (mounted) {
      setState(() {
        this._isLoading = false;
      });
    }
  }

  /// Fetch Real Time Data From Cloud Firestore
  Future<void> _fetchRealTimeDataFromCloudStorage() async {
    final realTimeSnapshot =
    await this._cloudStoreDataManagement.fetchRealTimeDataFromFirestore();
//if there is any changes in dataBase it will listen  and change it for us.And every document is a querySnapshot
    realTimeSnapshot!.listen((querySnapshot) {
      querySnapshot.docs.forEach((queryDocumentSnapshot) async {
        //tum documenleri getirip realTimeSnapshot'a atiktan sonra ve forEach dongusu ile siraladik
        //sonra eger document id'si simdiki kullanici emaile esit ise document bilgileri _checkingForNewConnection fonksyona at
        //document id'si users email olarak ayarladik
        if (queryDocumentSnapshot.id == FirebaseAuth.instance.currentUser!.email.toString()) {
        //simdiki kullanicinin email/documenti bulduktan sonra asagidaki method ile reqyseleri bakip bulabilirz
          await _checkingForNewConnection(
              queryDocumentSnapshot, querySnapshot.docs);
        }
      });
    });
  }

  //ekran acilir acilmaz initState sayesinde conected listesi yada kullanicilar gosterileck
  @override
  void initState() {
    _fetchRealTimeDataFromCloudStorage();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
          floatingActionButton: _externalConnectionManagement(),
        body: LoadingOverlay(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          progressIndicator: const CircularProgressIndicator(
            backgroundColor: Colors.black87,
          ),
          isLoading: _isLoading,
          child: ListView(
            children: [
               // _activityList(context),
              _connectionList(context),
            ],
          ),
        ),
      ),
    );
  }

/*  Widget _activityList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20.0,
        left: 10.0,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height * (1.5 / 8)
          : MediaQuery.of(context).size.height * (3 / 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Make ListView Horizontally
        itemCount: _allUserConnectionActivity.length,
        itemBuilder: (context, index) {
          return _activityCollectionList(context, index);
        },
      ),
    );
  }*/

  /*Widget _activityCollectionList(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 18),
      padding: EdgeInsets.only(top: 3.0),
      height: MediaQuery.of(context).size.height * (1.5 / 8),
      child: Column(
        children: [
          Stack(
            children: [
              if (_allUserConnectionActivity[index].contains('[[[new_activity]]]'))
                Container(
                  height: MediaQuery.of(context).orientation == Orientation.portrait
                          ? (MediaQuery.of(context).size.height *
                                  (1.2 / 7.95) /
                                  2.5) *
                              2
                          : (MediaQuery.of(context).size.height *
                                  (2.5 / 7.95) /
                                  2.5) *
                              2,
                  width:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? (MediaQuery.of(context).size.height *
                                  (1.2 / 7.95) /
                                  2.5) *
                              2
                          : (MediaQuery.of(context).size.height *
                                  (2.5 / 7.95) /
                                  2.5) *
                              2,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    value: 1.0,
                  ),
                ),
              OpenContainer(
                //fotolar normalde kare olarak ekranda gosterilir arka rengi saklamak icin vr fotoyu daire olarak gosteremk icin OpenContainer widgeti kullanip arka rengini ayarladik
                closedColor: const Color.fromRGBO(34, 48, 60, 1),
                openColor: const Color.fromRGBO(34, 48, 60, 1),
                middleColor: const Color.fromRGBO(34, 48, 60, 1),
                closedElevation: 0.0,
                closedShape: CircleBorder(),
                transitionDuration: Duration(
                  milliseconds: 500,
                ),
                transitionType: ContainerTransitionType.fadeThrough,
                openBuilder: (context, openWidget) {
                  return Center();
                },
                closedBuilder: (context, closeWidget) {
                  return CircleAvatar(
                    backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
                    backgroundImage:
                        ExactAssetImage('assets/images/google.png'),
                    radius: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height * (1.2 / 8) / 2.5
                        : MediaQuery.of(context).size.height * (2.5 / 8) / 2.5,
                  );
                },
              ),
              index == 0 // This is for current user Account
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.height * (0.7 / 8) - 10 : MediaQuery.of(context).size.height * (1.5 / 8) - 10,
                        left: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width / 3 - 65 : MediaQuery.of(context).size.width / 8 - 15,
                      ),
                      child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.lightBlue,
                          ),
                          child: GestureDetector(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.height *
                                      (1.3 / 8) / 2.5 * (3.5 / 6) : MediaQuery.of(context).size.height * (1.3 / 8) / 2,
                            ),
                          )),
                    )
                  : const SizedBox(),
            ],
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: 7.0,
            ),
            child: Text(
              'Generation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  Widget _connectionList(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Container(
        margin: EdgeInsets.only(
          //Orientation demeki cihazın yatay veya dikey modda olup olmadığıni kontrol etmek icin kullaniriz
            top: MediaQuery.of(context).orientation == Orientation.portrait ? 0.0 : 0.0),
        padding: const EdgeInsets.only(top: 18.0, bottom: 30.0),
        height: MediaQuery.of(context).size.height * (12.15 / 15),//container'in boyutu ve icindeki listView gosterme sekli ayarlamk icin height kullandim
        decoration: BoxDecoration(
          color: const Color.fromRGBO(31, 51, 71, 1),//container'in rengi
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              spreadRadius: 0.0,
              offset: const Offset(0.0, -5.0), // shadow direction: bottom right
            )
          ],
       //   borderRadius: const BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
          border: Border.all( //chat kismi secince icindeki alana veya Containere sinir vermek icin border kullandim
            color: Colors.black26,
            width: 2.0,
          ),
        ),
          //Yeniden sıralanabilir bi listView ekranda gelen mesajlari siralamsi veya yerleri  degistirmek  icin kulanacm.Degistirmek icin mesaji basili tutsak yeterli oacak
        child: ReorderableListView.builder(
          itemCount: _allConnectionsUserName.length,
          itemBuilder: (context, index) {
            final chat=_allConnectionsUserName[index];
            return chatTileContainer(context, index,chat);
          },  onReorder: (oldIndex, newIndex) {
          setState(() {
            if(newIndex>oldIndex)newIndex--;
            final chat = _allConnectionsUserName.removeAt(oldIndex);
            _allConnectionsUserName.insert(newIndex, chat);//yeni indec silnen index yerine gecer
          });
        },

        ),
      ),
    );
  }

  Widget chatTileContainer(BuildContext context, int index, String _userName) {
    return Card(
        key: ValueKey('$index'),
        elevation: 0.0,
        color: const Color.fromRGBO(31, 51, 71, 1),
        child: Container(
          padding: EdgeInsets.only(left: 1.0, right: 1.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              backgroundColor: Color.fromRGBO(31, 51, 71, 1),
              foregroundColor: Colors.lightBlueAccent,
            ),
            onPressed: () {
              print("Chat List Pressed");
            },
            child: Row(
              //kullaici fotografi ve adi ve saat ayni satirda koymak icin Row kullandim
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  //bi elemani veya fotoya basip onu buyutmek icin story/hikaye gibi OpenContainer widgeti kullanilir
                  child: OpenContainer(
                    //bu container kullanicinin fotolarina ait olack oYuzden icindeki ozellikler hepsi fotoya uygulanacak
                    //fotolar normalde kare olarak ekranda gosterilir arka rengi saklamak icin ve fotoyu daire olarak gosteremk icin closedColor ozelligi kullanip arka rengini ayarladik
                    closedColor: const Color.fromRGBO(31, 51, 71, 1),//closedColor fotoyu acmadan once rengi
                    openColor: const Color.fromRGBO(31, 51, 71, 1),//openColor fotoyu actiktan sonra rengi nasil olacagini belirliyo
                    middleColor: const Color.fromRGBO(31, 51, 71, 1),//middleColor fotoya bastiktan sonra gosdterilen renk
                    closedShape: CircleBorder(),//Shape of the container while it is closed.  When the container is opened it will transition from this shape to openShape.
                    closedElevation: 0.0,
                    transitionDuration: Duration(microseconds: 500),//transitionDuration ozelligi fotoya basinca onu buyutmek icin ne kada zaman alacagi belirliyo
                    transitionType: ContainerTransitionType.fadeThrough,//transitionType ozelligi fotoyu buyutunce degisme sekli nasil olacagini belirlio
                    openBuilder: (_, __) {//fotoyu veya elemana bastiktan sonra iceri nasil veya ne cikacagini belirliyo ve hersey olabilir veya koyabilirz
                      return Center();
                    },
                    closedBuilder: (_, __) {//closedBuilder ozelligi fotoyu/buttoni basmadan once widget'in sekli' nasil olacagini karar verio.ve her widget kullanabilirz
                      return CircleAvatar(
                        radius: 30.0,
                        backgroundColor: const Color.fromRGBO(31, 51, 71, 1),
                        child: Image.asset('assets/images/empty_proile.png',fit: BoxFit.cover,),
                        //getProperImageProviderForConnectionsCollection(
                        //    _userName),
                      );
                    },
                  ),
                ),
                //kullanici adi ve asgadaki mesaji icin OpenContainer kullandim ona basinca mesaj sayfasi cikacak
                OpenContainer(
                  closedColor: const Color.fromRGBO(31, 51, 71, 1),
                  openColor: const Color.fromRGBO(31, 51, 71, 1),
                  middleColor: const Color.fromRGBO(31, 51, 71, 1),
                  closedElevation: 0.0,
                  openElevation: 0.0,
                  transitionDuration: Duration(milliseconds: 500),
                  transitionType: ContainerTransitionType.fadeThrough,
                  openBuilder: (context, openWidget) {
                    return ChatScreen(userName:_userName ,);
                  },
                  closedBuilder: (context, closeWidget) {
                    return Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 2 + 30,
                      padding: EdgeInsets.only(//kullanici adicard oratasinda koymak icin padding ozelligi kullandim
                        top: 5.0,
                        bottom: 5.0,
                        left: 5.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            //eger kullanici adi uzunlugu 18 karakterden daha buyukse 18.'i harf'tan sonra  uc nokta olarak goster
                            _userName.length <= 18 ? _userName : '${_userName.replaceRange(18, _userName.length, '...')}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),

                          /// For Extract latest Conversation Message
//                          _latestDataForConnectionExtractPerfectly(_userName)
                          Text(
                            'User connected',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                      top: 2.0,
                      bottom: 2.0,
                    ),
                    child: Column(
                      children: [
                        Text('12:00'),
                        SizedBox(
                          height: 10.0,
                        ),
                        Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
  //diger kullanicilara istek atmak icin ayri bi method olusturdum
  Widget _externalConnectionManagement() {
    return OpenContainer(
      closedColor: Colors.teal,
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      closedShape: CircleBorder(),
      closedElevation: 15.0,
      transitionDuration: Duration(
        milliseconds: 500,
      ),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (_, __) {
        return SearchScreen();
      },
      closedBuilder: (_, __) {
        return Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 37.0,
          ),
        );
      },
    );
  }

}
