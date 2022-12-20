
import 'package:flutter/material.dart';

import '../../Backend/firebase/Auth/email_and_pwd_auth.dart';
import '../../Backend/firebase/Auth/fb_auth.dart';
import '../../Backend/firebase/Auth/google_auth.dart';
import '../Auth_UI/log_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () async {
              await    GoogleAuthentication().logOut();
              await logOutFirebase();
              await FacebookAuthentication().logOut();

              Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(
                    builder: (context) => LogInScreen(),
                  ),
                      (route) => false);
            },
            child: const Text('Log Out'),
          ),
        ));
  }
}
