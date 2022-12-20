
import 'package:bitirme_projesi1/frontEnd/Auth_UI/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Backend/firebase/OnlineDatabaseManagment/cloud_data_managment.dart';
import 'frontEnd/Auth_UI/log_in.dart';

import 'frontEnd/MainScreens/main_screen.dart';
import 'frontEnd/NewUserEntry/new_user_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
     MaterialApp(
      title: 'Generation',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      home: await SignUpScreen(),
    ),
  );
}

Future<Widget> differentContextDecisionTake() async {
  //eger kullanici degeri bos ise logIn sayfasi acilsin degilse kullanicinin kaydi kontrol edrcz
  if (FirebaseAuth.instance.currentUser == null) {
    return LogInScreen();
  } else {
    //CloudStoreDataManagement sinifindan bi degisken olusturoz onu kullanark sinif icndeki fonksyonlari cagirip calistirbilirz
    final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();

    final bool _dataPresentResponse =
        await _cloudStoreDataManagement.userRecordPresentOrNot(
        email: FirebaseAuth.instance.currentUser!.email.toString());
//userRecord fonksyundan gelen sonuc eger kullanici kaydi varsa homepage acilsin yoksa aboutUser sayfasi acilsin  kullanici bilgileri yazilsin
    return _dataPresentResponse ? MainScreen() : TakePrimaryUserData();
  }

}