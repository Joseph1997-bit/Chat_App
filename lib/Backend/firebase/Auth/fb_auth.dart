
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../../Global_Uses/enum.dart';

class FacebookAuthentication {
  final FacebookAuth _facebookLogin = FacebookAuth.instance;

  Future<FBSignInResults> facebookLogIn() async {
    try {
      if (await _facebookLogin.accessToken == null) {//eger login yapilmadiysa login islemi yap
        final LoginResult _fbLogInResult = await _facebookLogin.login();

        if (_fbLogInResult.status == LoginStatus.success) {
      //    login islem basarli bi sekilde yapildiysa AuthProvider sinifi kullanarak credential methodu cagirip kullanicinin facebook bilgileri atioyrz daha sonra firebase'te saklamak icin
          final OAuthCredential _oAuthCredential = FacebookAuthProvider.credential(
              _fbLogInResult.accessToken!.token);

          if (FirebaseAuth.instance.currentUser != null)//facebookLogIn methodu cagirinca eger firebase kullanarak giris yapildiysa ve kullanici bos degilse cikis yapsin
            FirebaseAuth.instance.signOut();
          //signInWithCredential demeki Kimlik Bilgileri ile Giriş Yap ve AuthCredential bi parametre aliyo bilgileri firebase'te saklamak icin
          final UserCredential fbUser = await FirebaseAuth.instance.signInWithCredential(_oAuthCredential);

          print('Fb Log In Info: ${fbUser.user}    ${fbUser.additionalUserInfo}');

          return FBSignInResults.SignInCompleted;

        }
        return FBSignInResults.UnExpectedError; }
       else {
        print('Already Fb Logged In');
        await logOut();
        return FBSignInResults.AlreadySignedIn;
      }
    } catch (e) {
      print('Facebook Log In Error: ${e.toString()}');
      return FBSignInResults.UnExpectedError;
    }
  }

  Future<bool> logOut() async {
    try {
      print('Facebook Log Out');
      //if the user is logged return one instance of AccessToken/Erişim Simgesi
      if (await _facebookLogin.accessToken != null) {
        await _facebookLogin.logOut();
        await FirebaseAuth.instance.signOut();
        return true;
      }
      return false;
    } catch (e) {
      print('Facebook Log out Error: ${e.toString()}');
      return false;
    }
  }
}