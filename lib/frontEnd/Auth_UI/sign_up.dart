import '../../Backend/firebase/Auth/email_and_pwd_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../../Backend/firebase/Auth/fb_auth.dart';
import '../../Backend/firebase/Auth/google_auth.dart';
import '../../Global_Uses/enum.dart';
import '../../Global_Uses/reg_exp.dart';
import '../NewUserEntry/new_user_entry.dart';
import 'common_auth_methods.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _signUpKey = GlobalKey();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _conformPwd = TextEditingController();
  bool _isLoading = false;


  final GoogleAuthentication _googleAuthentication = GoogleAuthentication();
  final FacebookAuthentication _facebookAuthentication = FacebookAuthentication();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        body: LoadingOverlay(
          //kayit yaparken bazen zaman aliyo oYuzden bekleme simgesi ekledik ve ekran ortasinda cikacaktir
          isLoading:
          _isLoading, //isLoading ozelligine false degeri versek bekleme simgesi calismaz
          child: Container(
            child: ListView(
              shrinkWrap:
              true, //you can change this behavior so that the ListView only occupies/kapsamak the space it needs (it will still scroll when there more items).
              children: [
                const SizedBox(
                  height: 40.0,
                ),
                const Text(
                  'Sign_Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  'Welcome To Our Chat App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white70,
                  ),
                ),
                Container(
                  //mediaQuery.of'u kullanmak, widget'ların her değiştiklerinde geçerli cihaz boyutlarına ve yerleşim tercihlerine göre kendilerini yeniden oluşturmalarına neden olur.
                  height: MediaQuery.of(context).size.height /
                      1.99, //ListView icinde textForm alanlari sinirlandirmak icin ve tum ekrani kapsamamak icin bunu kullandik(height/1.9)ve ekrani kaydirinca alani gorebiliz
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                    top: 40.0,
                  ),
                  child: Form(//A GlobalKey is used here to identify/tanimlamak the Form and validate/dogrulamak/التحقق من صحة input/girilen biligiler.
                    key: _signUpKey,
                    child: ListView(
                      children: [
                        commonTextFormField(
                            hintText: 'Enter your Email',
                            validator: (inputVal) {
                              //eger girilen degerler regular expresion kurallarina uygun degilse bize hata gosterck
                              if (!emailRegex.hasMatch(inputVal.toString())) {
                                return 'Email Format not Matching';
                              }
                              return null;
                            },
                            textEditingController: _email),
                        commonTextFormField(
                            hintText: 'Enter Password',
                            validator: (String? inputVal) {
                              if (inputVal!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            textEditingController: _pwd),
                        commonTextFormField(
                            hintText: 'Conform Password',
                            validator: (String? inputVal) {
                              if (inputVal!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              if (_pwd.text != _conformPwd.text) {
                                return 'Password and Conform Password Not Same Here';
                              }
                              return null;
                            },
                            textEditingController: _conformPwd),
                        signUpAuthButton(buttonName: 'Sign-up', context: context),
                      ],
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Or Continue With',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                signUpSocialMediaIntegrationButtons(context),
                const SizedBox(
                  height: 10.0,
                ),
                switchAnotherAuthScreen(
                    context: context,
                    text: "Already have an account ? ",
                    buttonName: 'Log-In'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signUpAuthButton(
      {required String buttonName, required BuildContext context}) {
    return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // minimumSize: Size(MediaQuery.of(context).size.width - 60, 30.0),
            elevation: 5.0,
            backgroundColor: const Color.fromRGBO(57, 60, 80, 1),
            padding: const EdgeInsets.only(
              //button icindeki text'e alan/bosluk vermek icin kullandik
              left: 20.0,
              right: 20.0,
              top: 10.0,
              bottom: 10.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          ),
          onPressed: () async {
            //Validates every [FormField] that is a descendant of this [Form], and returns true if there are no errors.
            //Bu [Form]'un alt öğesi olan her [Form Alanı]'nı doğrular ve hata yoksa true değerini döndürür.
            SystemChannels.textInput.invokeMethod('TextInput.hide');//buttoni bastiktan sonra keyboardi saklamak icin kullanilr
            if (_signUpKey.currentState!.validate()) {
              //buttoni bastiktan sonra eger kulanici bilgileri dogru bi sekile girmediyse TextForm altinda uyrai cikacktir
              print('Validated');
              setState(() {
                this._isLoading = true;
              });

              //eger kait islemi dogru bi sekilde yapilirsa Enum sinifi sayesinde signUpCompleted degeri bize verir veya dondurecek bu degeri kullanarak farkli islemler yapabilirz
              final EmailSignUpResults response = await signUpAuth(
                  email: _email.text,
                  pwd: _pwd
                      .text); //create methodu String bi deger aldigi icin textform degisken text ile string'e cevirebilirz
              if (response == EmailSignUpResults.signUpCompleted ) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TakePrimaryUserData()));
                setState(() {
                  this._isLoading = false;
                });
              } else {
                final String msg =
                response == EmailSignUpResults.emailAlreadyPresent
                    ? 'Email Already Present'
                    : 'Sign Up Not Completed';
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg),padding:EdgeInsets.all(22),backgroundColor: Colors.red,));
                setState(() {
                  this._isLoading = false;
                });
              }
            } else {
              print('Not Validated');
            }


          },
          child: Text(
            buttonName,
            style: const TextStyle(
              fontSize: 25.0,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ));
  }


  Widget signUpSocialMediaIntegrationButtons(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async{
                print('preesed google');
                setState(() {
                  this._isLoading = true;
                });
                String msg = '';
                final GoogleSignInResults _googleSignInResults = await this._googleAuthentication.signInWithGoogle();
                //signInGoogle methodu signIncompleted degeri dondururse demeki dogru bi sekilde giris yaptik ve homepage'e gidilecek
                if (_googleSignInResults == GoogleSignInResults.SignInCompleted) {
                  Navigator.pushAndRemoveUntil(//To remove all the routes below the pushed route, use a RoutePredicate(parametrenin degeri) that always returns false
                      context,
                      MaterialPageRoute(builder: (_) => TakePrimaryUserData()),
                          (route) => false);
                  setState(() {//baska sayfaya gitikten sinra artik bekleme simgesi calismasaina gerek yok
                    this._isLoading = false;
                  });
                }
                else {
                  if (_googleSignInResults ==
                      GoogleSignInResults.SignInNotCompleted)
                    msg = 'Sign In not Completed';
                  else if (_googleSignInResults ==
                      GoogleSignInResults.AlreadySignedIn)
                    msg = 'Already Google SignedIn';
                  else
                    msg = 'Unexpected Error Happen';

                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                  setState(() { //uyari ciktiktan sinra artik bekleme simgesi calismasaina gerek yok
                    this._isLoading = false;
                  });
                }
              },
              child: Image.asset(
                'assets/images/google.png',
                width: 60.0,
              ),
            ),
            SizedBox(
              width: 60.0,
            ),
            GestureDetector(
              onTap: () async{
                print('preesed Facebook');
                setState(() {
                  this._isLoading = true;
                });
                String msg = '';
                final FBSignInResults _fbSignInResults =await _facebookAuthentication.facebookLogIn();
                if (_fbSignInResults == FBSignInResults.SignInCompleted) {
                  Navigator.pushAndRemoveUntil(//To remove all the routes below the pushed route, use a RoutePredicate(parametrenin degeri) that always returns false
                      context,
                      MaterialPageRoute(builder: (_) => TakePrimaryUserData()),
                          (route) => false);
                  setState(() {//baska sayfaya gitikten sinra artik bekleme simgesi calismasaina gerek yok
                    this._isLoading = false;
                  });
                }
                else {
                  if (_fbSignInResults ==
                      FBSignInResults.SignInNotCompleted)
                    msg = 'Sign In not Completed';
                  else if (_fbSignInResults ==
                      FBSignInResults.AlreadySignedIn)
                    msg = 'Already FaceBook SignedIn';
                  else
                    msg = 'Unexpected Error Happen';

                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                  setState(() { //uyari ciktiktan sinra artik bekleme simgesi calismasaina gerek yok
                    this._isLoading = false;
                  });
                }
              },
              child: Image.asset(
                'assets/images/fbook.png',
                width: 60.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
