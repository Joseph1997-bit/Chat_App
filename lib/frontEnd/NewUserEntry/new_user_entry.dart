import 'package:bitirme_projesi1/frontEnd/MainScreens/home_page.dart';
import 'package:bitirme_projesi1/frontEnd/MainScreens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../Backend/firebase/OnlineDatabaseManagment/cloud_data_managment.dart';
import '../../Backend/sqlite_management/local_database_management.dart';
import '../../Global_Uses/reg_exp.dart';
import '../Auth_UI/common_auth_methods.dart';

class TakePrimaryUserData extends StatefulWidget {
  const TakePrimaryUserData({Key? key}) : super(key: key);

  @override
  State<TakePrimaryUserData> createState() => _TakePrimaryUserDataState();
}

class _TakePrimaryUserDataState extends State<TakePrimaryUserData> {
  bool _isLoading = false;

  final GlobalKey<FormState> _takeUserPrimaryInformationKey =
      GlobalKey<FormState>();

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userAbout = TextEditingController();
  final CloudStoreDataManagement _cloudStoreDataManagement =
      CloudStoreDataManagement();
  final LocalDatabase _localDatabase = LocalDatabase();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 69, 1),
        body: LoadingOverlay(
          //bekleme simgesi icin kullanilir
          isLoading: this._isLoading,
          child: Container(
            margin: EdgeInsets.only(top: 70.0),
            //mediaQuery.of'u , widget'ların her değiştiklerinde geçerli cihaz boyutlarına ve yerleşim tercihlerine göre kendilerini yeniden oluşturmalarına neden olur.
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Form(
              //TextForm altinda uyari gostermek icin form widget kullandim
              key: this._takeUserPrimaryInformationKey,
              child: ListView(
                shrinkWrap:
                    true, ////you can change this behavior so that the ListView only occupies/kapsamak the space it needs (it will still scroll when there more items).
                children: [
                  _upperHeading(),
                  commonTextFormField(
                    bottomPadding: 60.0,
                    hintText: 'User Name',
                    textEditingController: _userName,
                    validator: (inputUserName) {
                      //kullanici tarafindan girilen bilgiler eger bu sartlara uyarsa uyari gostereck uymuyorsa hic bi sey cikmayack
                      if (inputUserName!.length < 6)
                        return "User Name At Least 6 Characters";
                      else if (inputUserName.contains(' ') ||
                          inputUserName.contains('@'))
                        return "Space and '@' Not Allowed...User '_' instead of space";
                      else if (inputUserName.contains('__'))
                        return "'__' Not Allowed...User '_' instead of '__'";
                      /* else if (!emojiRegex.hasMatch(inputUserName))simdilik calismiyor
                        return "Sorry, Emoji Not Supported";*/
                      return null;
                    },
                  ),
                  commonTextFormField(
                      hintText: 'User About',
                      validator: (inputVal) {
                        if (inputVal!.length < 6)
                          return 'User About must have 6 characters';
                        return null;
                      },
                      textEditingController: _userAbout),
                  _saveUserPrimaryInformation()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _upperHeading() {
    return Padding(
      padding: EdgeInsets.only(bottom: 50.0),
      child: Center(
        child: Text(
          'Set Up Your Account',
          style: TextStyle(color: Colors.greenAccent, fontSize: 25.0),
        ),
      ),
    );
  }

  Widget _saveUserPrimaryInformation() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: MaterialButton(
        padding: EdgeInsets.all(15.0),
        elevation: 5.0,
        minWidth: 30.0,
        height: 60.0,
        child: Text(
          'Save',
          style: TextStyle(fontSize: 23.0),
        ),
        color: Colors.tealAccent,
        onPressed: () async {
          String msg = '';
          if (this._takeUserPrimaryInformationKey.currentState!.validate()) {
            print('Validated');

            SystemChannels.textInput.invokeMethod('TextInput.hide');

            setState(() {
              this._isLoading = true;
            });

            final bool canRegisterNewUser = await _cloudStoreDataManagement
                .checkThisUserAlreadyPresentOrNot(
                    userName: this._userName.text);

            if (!canRegisterNewUser) {
              msg = 'User Name Already Present';
            } else {
              final bool _userEntryResponse =
                  await _cloudStoreDataManagement.registerNewUser(
                      userName: this._userName.text,
                      userAbout: this._userAbout.text,
                      userEmail:
                          FirebaseAuth.instance.currentUser!.email.toString());
              if (_userEntryResponse == true) {
                msg = 'User data Entry Successfully';

                /// Calling Local Databases Methods To Intitialize Local Database with required MEthods
                await this._localDatabase.createTableToStoreImportantData();

                final Map<String, dynamic> _importantFetchedData =
                    await _cloudStoreDataManagement.getTokenFromCloudStore(userMail: FirebaseAuth.instance.currentUser!.email.toString());
//getToken fonksyondan gelen bilgileri insertOrUpdateData fonksyona parametre olarak atiyoz ve bu fonksyon datayi local database'te sakliyo sql olark
                await this._localDatabase.insertOrUpdateDataForThisAccount(
                    userName: this._userName.text,
                    userMail: FirebaseAuth.instance.currentUser!.email.toString(),
                    userToken: _importantFetchedData["token"],
                    userAbout: this._userAbout.text,
                    userAccCreationDate: _importantFetchedData["date"],
                    userAccCreationTime: _importantFetchedData["time"]);

                await _localDatabase.createTableForUserActivity(tableName: this._userName.text);

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                    (route) => false);
              } else {
                msg = 'User Data Not Entry Successfully';
              }
            }
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));

          setState(() {
            this._isLoading = false;
          });
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
  }
}
