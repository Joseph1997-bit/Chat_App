
import 'package:flutter/material.dart';

import 'log_in.dart';
import 'sign_up.dart';

Widget commonTextFormField({required String hintText,required String? Function(String?)? validator,required TextEditingController?  textEditingController, double bottomPadding=40.0}) {
  return Container(
    padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: bottomPadding),
    child: TextFormField(
      validator: validator,
      controller: textEditingController,
      style:const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:const TextStyle(color: Colors.white70),
        enabledBorder:const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.lightBlue,
            width: 2.0,
          ),
        ),
      ),
    ),
  );
}

Widget authButton({required BuildContext context,required String buttonName}) {
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
        onPressed: () {},
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
// Widget signUpSocialMediaIntegrationButtons(BuildContext context) {
//   return Container(
//     width: MediaQuery.of(context).size.width,
//     padding: EdgeInsets.all(20.0),
//     child: Center(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           GestureDetector(
//             onTap: (){
//               print('preesed google');
//             },
//             child: Image.asset(
//               'assets/images/google.png',
//               width: 60.0,
//             ),
//           ),
//           SizedBox(
//             width: 60.0,
//           ),
//           GestureDetector(
//             onTap: (){
//               print('preesed Facebook');
//             },
//             child: Image.asset(
//               'assets/images/fbook.png',
//               width: 60.0,
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

Widget switchAnotherAuthScreen({required BuildContext context,required String text,required String buttonName}) {
  return ElevatedButton(
    onPressed: () {
      if (buttonName == "Log-In") {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LogInScreen(),
            )); }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (_) =>const SignUpScreen()));}
    },
    style: ElevatedButton.styleFrom(
        elevation: 0.0, backgroundColor: const Color.fromRGBO(34, 48, 60, 1)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:  [
        Text(
          text,
          style:const TextStyle(
              color: Colors.white, fontSize: 16.0, letterSpacing: 1.0),
        ),
        Text(
          buttonName,
          style:const TextStyle(
              color: Colors.blueAccent, fontSize: 16.0, letterSpacing: 1.0),
        ),
      ],
    ),
  );
}