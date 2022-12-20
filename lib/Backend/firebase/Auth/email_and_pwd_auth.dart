import 'package:firebase_auth/firebase_auth.dart';
import '../../../Global_Uses/enum.dart';


Future<EmailSignUpResults> signUpAuth({required String email, required String pwd}) async {
  try {
    //userCredential/kullanıcı Kimlik Bilgileri
    final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pwd);
    if (userCredential.user!.email != null) {
      await userCredential.user!.sendEmailVerification();//register yaptiktan sonra mailimze mesaj geleck dogrulamak icin onu onaylamazsak giris yapamayiz
      return EmailSignUpResults.signUpCompleted;
    } else {
      return EmailSignUpResults.signUpNotCompleted;
    }
  } catch (e) {
    print('Error in Email and Password Sign Up: ${e.toString()}');
    return EmailSignUpResults.emailAlreadyPresent;
  }
}

Future<EmailSignInResults> signInWithEmailAndPassword(
    {required String email, required String pwd}) async {
  try {
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pwd);
    //verified demeki Doğrulama e-postası göndermek için
    if (userCredential.user!.emailVerified)//userCredential/kullanıcı kimlik bilgisi  emailVerified/E-posta Doğrulandı
      //mailimze bi mesaj geleck dogrulamak icin maili acip ordan onaylamamiz gerekiyo yoksa giris yapilmaz
      return EmailSignInResults.signInCompleted;
    else {
      final bool logOutResponse = await logOutFirebase();
      if (logOutResponse )
      {return EmailSignInResults.emailNotVerified;}
      else { return EmailSignInResults.unexpectedError;}
    }
  } catch (e) {
    print('Error in Sign In With Email And Password Authentication: ${e.toString()}');
    return EmailSignInResults.emailOrPasswordInvalid;
  }
}
Future<bool> logOutFirebase() async {
  try {
    await FirebaseAuth.instance.signOut();
    return true;
  } catch (e) {
    return false;
  }
}

