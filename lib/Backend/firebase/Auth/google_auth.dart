import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../Global_Uses/enum.dart';

class GoogleAuthentication {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<GoogleSignInResults> signInWithGoogle() async {
    try{
      if(await _googleSignIn.isSignedIn()) {//eger google ile giris yaptiysak giris yapildi yazilack
        print('Already Google  Signed In');
        logOut();
        return GoogleSignInResults.AlreadySignedIn;//AlreadySignIn Enum degeri bize dondurack ve onu kullanarak farkli islemler yapip ekranda gosterebiliriz
      }else {//eger giris yapmadiysak asagidaki islemleri gercekleseck
        final GoogleSignInAccount? _googleUser  = await _googleSignIn.signIn();
        // GoogleSignInResults.SignInNotCompleted;
        if(_googleUser==null) {
          print('Google Sign In Not Completed');
          return  GoogleSignInResults.SignInNotCompleted;
        }else {
          final GoogleSignInAuthentication _googleSignInAuth = await _googleUser.authentication; //login islem basarli bi sekilde yapildiysa GoogleAuthProvider sinifi iki zorunlu parametre aliyo onu kullanarak credential methodu cagirip kullanicinin google bilgileri atioyrz daha sonra firebase'te saklamak icin
          final OAuthCredential _credential = GoogleAuthProvider.credential(
            accessToken: _googleSignInAuth.accessToken,//kimlik/kullanici  bilgileri google tarafindan alacagimizi veya verecegimizi belirliyoz/Facebook bigilerii ayni sekilde saklayabilirz
            idToken: _googleSignInAuth.idToken,
          );
          final UserCredential userCredential = await FirebaseAuth.instance//firebase sitesinde users kismina kgoogle kullanicisinin bilgileri eklemek icin bu methodu kullandik
              .signInWithCredential(_credential);//ve kullanici bilgileri artik firebaste saklayabiliriz

          if (userCredential.user!.email != null) {
            print('Google Sign In Completed');
            return GoogleSignInResults.SignInCompleted;
          } else {
            print('Google Sign In Not completed');
            return GoogleSignInResults.UnexpectedError;
          }

        }

      }

    }
    catch(e) {
      print('Error in Google Sign In ${e.toString()}');
      return GoogleSignInResults.UnexpectedError;
    }

  }



  Future<bool> logOut() async {
    try {
      print('Google Log out');

       await _googleSignIn.disconnect();//Geçerli kullanıcının uygulamayla bağlantısını keser ve önceki kimlik doğrulamasını iptal eder.
      await _googleSignIn.signOut();//cikis yapmak icin kullanilir
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      print('Error in Google Log Out: ${e.toString()}');
      return false;
    }
  }

}

