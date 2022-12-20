import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../../Global_Uses/constants.dart';
import '../../../Global_Uses/enum.dart';
import '../../../frontEnd/model/previous_message_structure.dart';
import '../../sqlite_management/local_database_management.dart';

class CloudStoreDataManagement {
  final _collectionName='users';
  //final SendNotification _sendNotification = SendNotification();
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<bool> checkThisUserAlreadyPresentOrNot(
      {required String userName}) async {
    //QuerySnapshot Contains the results of a query. It can contain zero or more DocumentSnapshot objects.
    //QuerySnapshot kullanarak firestore'de saklanan tum documentleri cagirp farkli islemlerle kullanabilir.Mesela asagidaki kod ayni user daha once kayit yapip yapmadigini kontrol ediyoz
    try {
      final QuerySnapshot<Map<String, dynamic>> findResults =
          await FirebaseFirestore //QuerySnapshot sinifindan ve map olarak bi degiken olusturdukMap<Anahtar=String,value=dynamic>
              .instance
              .collection(_collectionName) //collection veritabanin adi sayilir
              .where('user_name', isEqualTo: userName) //field adi yazip girilen kullanici adi ile karsilastirma yapbilirz
              .get(); //get methodu Fetch/getirmek/almak the documents for this query/sorgu/talep.

      print('Debug 1: ${findResults.docs.isEmpty}');

      return findResults.docs.isEmpty ? true : false;
    } catch (e) {
      print('Error in Check This User Already Present or not: ${e.toString()}');
      return false;
    }
  }
  Future<bool> registerNewUser(
      {required String userName,
        required String userAbout,
        required String userEmail}) async {
    try {
      //getToken takes vapidKey is a new way to send and receive website push notifications. Your VAPID keys allow you to send web push campaigns/kampanyalar without having to send them through a service like Firebase Cloud Messaging (or FCM)
      final String? _getToken = await FirebaseMessaging.instance.getToken();
//kullanici kayit oldugu tarih ve zaman bu sekilde ekliyoz
      final String currDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final String currTime = "${DateFormat('hh:mm a').format(DateTime.now())}";//hh means Hour in am/pm (1-12) format and a means Am/pm marker
      //FieldValue messagesTimes=FieldValue.serverTimestamp();//uygulamayi farkli yerlerde kullanilabilir oYuzden dogru zamani yazdirmak icin serverTimes methodu kullanmamiz lazim

//collection adi ile beraber kullanici emaili ekliyoz ve onu kullanarak kullanici hakinda asagidaki tum bilgileri firestore'e ekleyebilirz ve bu sekilde sitede document adi kullanici maili olack
      await FirebaseFirestore.instance.doc('$_collectionName/$userEmail').set({//set fonks map olarak bi deger aliyo bilgileri kolay bi sekilde eklemek icin asagidaki gibi

        "about": userAbout,
        "activity": [],
        "connection_request": [],
        "connections": {},
        "creation_date": currDate,
        "creation_time": currTime,
        "phone_number": "",
        "profile_pic": "",
        "token": _getToken.toString(),
        "total_connections": "",
        "user_name": userName,
      });

      return true;
    } catch (e) {
      print('Error in Register new user: ${e.toString()}');
      return false;
    }
  }
  //kullanıcı Kaydı Var veya Yok
  Future<bool> userRecordPresentOrNot({required String email}) async {
    try {
      //A DocumentSnapshot contains data read from a document in your FirebaseFirestore database.And by using subscript syntax to access a specific/belirli field
      //kullanıcı Kaydı yani emalii Var veya Yok kontrol etmek icin DocumentSnapshot sinifindan bi degislen olusturdum
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .doc('${this._collectionName}/$email')
          .get();
      return documentSnapshot.exists;//eger parametre olarak gelen email firebase sitesinde varsa bize mevcut degeri dondursun
    } catch (e) {
      print('Error in user Record Present or not: ${e.toString()}');
      return false;
    }
  }
  Future<Map<String, dynamic>> getTokenFromCloudStore(
      {required String userMail}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .doc('${this._collectionName}/$userMail')
          .get();

      print('DocumentSnapShot is: ${documentSnapshot.data()}');

      final Map<String, dynamic> importantData = Map<String, dynamic>();

      importantData["token"] = documentSnapshot.data()!["token"];
      importantData["date"] = documentSnapshot.data()!["creation_date"];
      importantData["time"] = documentSnapshot.data()!["creation_time"];

      return importantData;
    } catch (e) {
      print('Error in get Token from Cloud Store: ${e.toString()}');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersListExceptMyAccount(
      {required String currentUserEmail}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .get();

      List<Map<String, dynamic>> _usersDataCollection = [];

      querySnapshot.docs.forEach(
              (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) {
                //eger simdiki kullanicinin emaili document emial'e esit degilse demek diger kullanicilar bilgileri getir
                //ve bu sekilde diger kullanicilari getirebilirz
            if (currentUserEmail != queryDocumentSnapshot.id)
              //the id of the Document is the user's email
              _usersDataCollection.add({
                queryDocumentSnapshot.id:
                '${queryDocumentSnapshot.get("user_name")}[user-name-about-divider]${queryDocumentSnapshot.get("about")}',
              });
          });

      print(_usersDataCollection);

      return _usersDataCollection;
    } catch (e) {
      print('Error in get All Users List: ${e.toString()}');
      return [];
    }
  }

//kullanıcının hesabının tum bilgileri veya verileri bu method firebase'ten getiriyor
  Future<Map<String, dynamic>?> _getCurrentAccountAllData(
      {required String email}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .doc('${_collectionName}/$email')
          .get();
     //get() methodu ile Documenti getirdikten sonra icindeki tum bilgileri data() method ile albiliriz.Contains all the data of this document snapshot.
      return documentSnapshot.data();
    } catch (e) {
      print('Error in getCurrentAccountAll Data: ${e.toString()}');
      return {};
    }
  }
//bu fonks mevcut Kullanıcı Bağlantı İstek Listesini getiriyor/donduruyor
  Future<List<dynamic>> currentUserConnectionRequestList(
      {required String email}) async {
    try {
      //kullanicinin tum bilgileri _getCurrentAccountAllData methodu kullanark aliyoz ve _currentUserData degiskene atiyoz
      Map<String, dynamic>? _currentUserData = await _getCurrentAccountAllData(email: email);
      //_currentUserData degisken icinde kullanicinin tum bilgileri sahip olmus ve onu kullanark sadece Bağlantı/conection İstek/request Listesini asagidaki gibi alip bi degiskene atiyoz
      final List<dynamic> _connectionRequestCollection = _currentUserData!["connection_request"];

      print('Collection: $_connectionRequestCollection');

      return _connectionRequestCollection;
    } catch (e) {
      print('Error in Current USer Collection List: ${e.toString()}');
      return [];
    }
  }
  //talep durumu degistirmek icin
  Future<void> changeConnectionStatus({
    required String oppositeUserMail,
    required String currentUserMail,
    required String connectionUpdatedStatus,
    required List<dynamic> currentUserUpdatedConnectionRequest,
    bool storeDataAlsoInConnections = false,
  }) async {
    try {
      print('Come here');

      /// Opposite Connection database Update
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .doc('${_collectionName}/$oppositeUserMail')
          .get();

      Map<String, dynamic>? map = documentSnapshot.data();

      print('Map: $map');

      List<dynamic> _oppositeConnectionsRequestsList = map!["connection_request"];

      int index = -1;

      _oppositeConnectionsRequestsList.forEach((element) {
        if (element.keys.first.toString() == currentUserMail)
          index = _oppositeConnectionsRequestsList.indexOf(element);
      });
     //gelen kullanicinin emaili siliyoruz ve kalan diger kullanicilar _oppositeConnectionsRequestsList'e ekliyoz
      if (index > -1) _oppositeConnectionsRequestsList.removeAt(index);

      print('Opposite Connections: $_oppositeConnectionsRequestsList');

      _oppositeConnectionsRequestsList.add({
        currentUserMail: connectionUpdatedStatus,
      });

      print('Opposite Connections: $_oppositeConnectionsRequestsList');

      map["connection_request"] = _oppositeConnectionsRequestsList;//diger kullanivinin durmunun son hali Map'e atiyoz sakalmak icin sonra firebase'te durumu degistirmek icin

      if (storeDataAlsoInConnections)
        map[FirestoreFieldConstants().connections].addAll({
          currentUserMail: [],
        });
//update methodu kullanark firebase'teki istek durumu degistirebiliriz
      await FirebaseFirestore.instance
          .doc('${_collectionName}/$oppositeUserMail')
          .update(map);

      /// Current User Connection Database Update
      final Map<String, dynamic>? currentUserMap = await _getCurrentAccountAllData(email: currentUserMail);
//tum kullanicin bilgileri getirdikten sonra asagidaki gibi firebase'te connection_request alani bu sekilde ulasabilirz
      currentUserMap!["connection_request"] = currentUserUpdatedConnectionRequest;

      if (storeDataAlsoInConnections)
        currentUserMap[FirestoreFieldConstants().connections].addAll({
          oppositeUserMail: [],
        });
//kullanicinin istek durumum(pending,accepted) currentUserMap degiskene atiktan sonra asagidaki gibi firebase'te degistirebiliriz ve saklayabilirz
      await FirebaseFirestore.instance.doc('${this._collectionName}/$currentUserMail')
          .update(currentUserMap);
    } catch (e) {
      print('Error in Change Connection Status: ${e.toString()}');
    }
  }

  //firebaste'ten tum kullanicilar veya documentleri bu fonksyoun getireck
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>?>
   fetchRealTimeDataFromFirestore() async {
    try {
      return FirebaseFirestore.instance.collection(_collectionName).snapshots();
    } catch (e) {
      print('Error in Fetch Real Time Data : ${e.toString()}');
      return null;
    }
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>?>
  fetchRealTimeMessages() async {
    try {
      return FirebaseFirestore.instance
          .doc('${_collectionName}/${FirebaseAuth.instance.currentUser!.email.toString()}')
          .snapshots();
    } catch (e) {
      print('Error in Fetch Real Time Data : ${e.toString()}');
      return null;
    }
  }

  Future<void> sendMessageToConnection(
      {required String connectionUserName,
        required Map<String, Map<String, String>> sendMessageData,
        required ChatMessageTypes chatMessageTypes}) async {
    try {
      final LocalDatabase _localDatabase = LocalDatabase();

      final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;
//bu fonksyonu kullanark belirli veya istedigmiz bilgiyi veritabanindan getirebilirz
      final String? _getConnectedUserEmail = await _localDatabase.getParticularFieldDataFromImportantTable(userName: connectionUserName,
          getField: GetFieldForImportantDataLocalDatabase.UserEmail);//enum degerleri kullanark userEmail degeri getiriyoz

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .doc("${this._collectionName}/$_getConnectedUserEmail")
          .get();

      final Map<String, dynamic>? connectedUserData = documentSnapshot.data();

      List<dynamic>? getOldMessages =
      connectedUserData![FirestoreFieldConstants().connections]
      [currentUserEmail.toString()];
      if (getOldMessages == null)
        getOldMessages = [];

      getOldMessages.add(sendMessageData);

      connectedUserData[FirestoreFieldConstants().connections]
      [currentUserEmail.toString()] = getOldMessages;

      print(
          "Data checking: ${connectedUserData[FirestoreFieldConstants().connections]}");

      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$_getConnectedUserEmail")
          .update({
        FirestoreFieldConstants().connections:
        connectedUserData[FirestoreFieldConstants().connections],
      }).whenComplete(() async {
        print('Data Send Completed');

        final String? connectionToken =
        await _localDatabase.getParticularFieldDataFromImportantTable(
            userName: connectionUserName,
            getField: GetFieldForImportantDataLocalDatabase.Token);

        final String? currentAccountUserName =
        await _localDatabase.getUserNameForCurrentUser(
            FirebaseAuth.instance.currentUser!.email.toString());

      //  await _sendNotification.messageNotificationClassifier(chatMessageTypes, connectionToken: connectionToken ?? "", currAccountUserName: currentAccountUserName ?? "");
      });
    } catch (e) {
      print('error in Send Data: ${e.toString()}');
    }
  }
  Future<void> removeOldMessages({required String connectionEmail}) async {
    try {
      final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$currentUserEmail")
          .get();

      final Map<String, dynamic>? connectedUserData = documentSnapshot.data();

      connectedUserData![FirestoreFieldConstants().connections]
      [connectionEmail.toString()] = [];

      print(
          "After Remove: ${connectedUserData[FirestoreFieldConstants().connections]}");

      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$currentUserEmail")
          .update({
        FirestoreFieldConstants().connections:
        connectedUserData[FirestoreFieldConstants().connections],
      }).whenComplete(() {
        print('Data Deletion Completed');
      });
    } catch (e) {
      print('error in Send Data: ${e.toString()}');
    }
  }



  /*  Future<void> sendMessageToConnection(
      {required String connectionUserName,
        required Map<String, Map<String, String>> sendMessageData,
        required ChatMessageTypes chatMessageTypes}) async {
    try {
      final LocalDatabase _localDatabase = LocalDatabase();

      final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final String? _getConnectedUserEmail =
      await _localDatabase.getParticularFieldDataFromImportantTable(
          userName: connectionUserName,
          getField: GetFieldForImportantDataLocalDatabase.UserEmail);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$_getConnectedUserEmail")
          .get();

      final Map<String, dynamic>? connectedUserData = documentSnapshot.data();

      List<dynamic>? getOldMessages =
      connectedUserData![FirestoreFieldConstants().connections]
      [currentUserEmail.toString()];
      if (getOldMessages == null) getOldMessages = [];

      getOldMessages.add(sendMessageData);

      connectedUserData[FirestoreFieldConstants().connections]
      [currentUserEmail.toString()] = getOldMessages;

      print(
          "Data checking: ${connectedUserData[FirestoreFieldConstants().connections]}");

      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$_getConnectedUserEmail")
          .update({
        FirestoreFieldConstants().connections:
        connectedUserData[FirestoreFieldConstants().connections],
      }).whenComplete(() async {
        print('Data Send Completed');

        final String? connectionToken =
        await _localDatabase.getParticularFieldDataFromImportantTable(
            userName: connectionUserName,
            getField: GetFieldForImportantDataLocalDatabase.Token);

        final String? currentAccountUserName =
        await _localDatabase.getUserNameForCurrentUser(
            FirebaseAuth.instance.currentUser!.email.toString());

        await _sendNotification.messageNotificationClassifier(chatMessageTypes,
            connectionToken: connectionToken ?? "",
            currAccountUserName: currentAccountUserName ?? "");
      });
    } catch (e) {
      print('error in Send Data: ${e.toString()}');
    }
  }

  Future<void> removeOldMessages({required String connectionEmail}) async {
    try {
      final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$currentUserEmail")
          .get();

      final Map<String, dynamic>? connectedUserData = documentSnapshot.data();

      connectedUserData![FirestoreFieldConstants().connections]
      [connectionEmail.toString()] = [];

      print(
          "After Remove: ${connectedUserData[FirestoreFieldConstants().connections]}");

      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$currentUserEmail")
          .update({
        FirestoreFieldConstants().connections:
        connectedUserData[FirestoreFieldConstants().connections],
      }).whenComplete(() {
        print('Data Deletion Completed');
      });
    } catch (e) {
      print('error in Send Data: ${e.toString()}');
    }
  }

  Future<String?> uploadMediaToStorage(File filePath,
      {required String reference}) async {
    try {
      String? downLoadUrl;

      final String fileName =
          '${FirebaseAuth.instance.currentUser!.uid}${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}';

      final Reference firebaseStorageRef =
      FirebaseStorage.instance.ref(reference).child(fileName);

      print('Firebase Storage Reference: $firebaseStorageRef');

      final UploadTask uploadTask = firebaseStorageRef.putFile(filePath);

      await uploadTask.whenComplete(() async {
        print("Media Uploaded");
        downLoadUrl = await firebaseStorageRef.getDownloadURL();
        print("Download Url: $downLoadUrl}");
      });

      return downLoadUrl!;
    } catch (e) {
      print("Error: Firebase Storage Exception is: ${e.toString()}");
      return null;
    }
  }*/


}

