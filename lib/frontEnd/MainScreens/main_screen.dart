import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Backend/firebase/Auth/email_and_pwd_auth.dart';
import '../../Backend/firebase/Auth/fb_auth.dart';
import '../../Backend/firebase/Auth/google_auth.dart';
import '../Auth_UI/log_in.dart';
import '../MenuScreens/SupportScreens/support_screen.dart';
import '../MenuScreens/about_screen.dart';
import '../MenuScreens/profile_screen.dart';
import '../MenuScreens/settings_screen.dart';
import 'chatAndActivityScreen.dart';
import 'general_options_section.dart';
import 'logs_collection.dart';

//sayfa icinde hareket eden bi animasyon olacagi icin statful widgettan miras almasi lazim
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        //appbar altinda sekmeler/kkisimlar koymak icin tree/agac ilk basta TabController widgeti koymamiz lazim
        length: 3, //ve length ile kac tane kisim olacagi belirleyebilirz
        child: WillPopScope(
          //geri sayfaya gitmek icin telefon altindaki buttoni bassak bile gitmeyeck cunku onWillPop ozelligine false verdik
          onWillPop: () async {
            if (_currIndex > 0)
              return false;
            else {
              return true;
            }
          },
          child: Scaffold(
            backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
            drawer: _drawer(),
            appBar: AppBar(
              systemOverlayStyle:
                  SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
              backgroundColor: const Color.fromRGBO(25, 39, 52, 1),
              elevation: 10.0,
              shadowColor: Colors.white70,
              shape: RoundedRectangleBorder(
                //appbar'in alt kismi daire gibi veya yuvarlamak icin shap ozelligi kullaniriz
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
                side: BorderSide(
                    width:
                        0.7), //appbar'in etrafi kalan yapmak icin side ozelligi kullandim
              ),
            /* leading: IconButton(
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
                icon: Icon(Icons.menu),
              )*/
              // centerTitle: true,
              title: Text(
                "Chat App",
                style: TextStyle(
                    fontSize: 25.0, fontFamily: 'Lora', letterSpacing: 1.0),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.search_outlined,
                    size: 25.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 20.0,
                  ),
                  child: IconButton(
                    tooltip:
                        'Refresh', //eger refresh dugmesi basili tutsak bize Refresh kelimesi cikar
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: 25.0,
                    ),
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
                  ),
                ),
              ],
              bottom: _bottom(), //appbar altindaki kisminaa sekmeler/kisimlar eklemek icin bottom ozelligi kullandim
            ),
            //her sekme veya kisim icin ayri bi content/iceri vermek icin Scaffold'taki body ozelligine TabBarView widget verdim/kullandim
            body: TabBarView(
              children: [
                ChatAndActivityScreen(),
                LogsCollection(),
                GeneralMessagingSection(),
              ],
            ),
          ),
        ));
  }

  //appbar altindaki kismi yapmak icin asagidaki fonksyonu kullanacz
  TabBar _bottom() {
    //appbar altinda farkli sekmeler/kismimlar eklemek icin ve arasinda gecis yapmak icin TabBar widgeti kullanmamiz lazimj
    return TabBar(
      indicatorPadding: EdgeInsets.only(
          left: 20.0, right: 20.0), //indicator/gösterge appbar'da sectigmiz kisim altinda cizginin boyutu ayarladik
      indicator: UnderlineTabIndicator(
        //sekmeleri secince altindaki cizginin rengi ve kalınlık derecesini ayarlamak icin indicator ozelligi kullandim
        borderSide: BorderSide(width: 3.0, color: Colors.greenAccent),
        insets: EdgeInsets.symmetric(horizontal: 15.0),//insets ozelligi Seçili sekmenin alt çizgisini sekmenin sınırına göre ayarliyor.
      ),
      labelColor: Colors.greenAccent, //sectigmiz kisminin  rengi yesil olack
      unselectedLabelColor: Colors.white60, //appbar'da secilmeyen kismin rengi beyaz olack

      //automaticIndicatorColorAdjustment: true,
      labelStyle: TextStyle(
        fontFamily: 'Lora',
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      ),
      onTap: (index) {
        print("\nIndex is: $index");
          setState(() {//sekmeler arasindaki degismeleri gormek icin sekmenin indexi setState icinde koymamiz lazim
            _currIndex = index;
          });
      },
      //TabBar widget icinde en onemli ozellik tabs Tab tipinden bi list aliyor sekmelere adi veya icon vermek icin kullanilir
      tabs: [
        Tab(
          child: Text(
            "Chats",
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              // color: _currIndex==0? Colors.greenAccent:Colors.white
            ),
          ),
        ),
        Tab(
          child: Text(
            "Calls",
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              //  color: _currIndex==1? Colors.greenAccent:Colors.white
            ),
          ),
        ),
        Tab(
          icon: Icon(
            Icons.store,
            size: 25.0,
            // color: _currIndex==2? Colors.greenAccent:Colors.white,
          ),
        ),
      ],
    );
  }
  Widget _drawer(){
    return Drawer(
      elevation: 10.0,
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: const Color.fromRGBO(34, 48, 60, 1),
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
                    },
                    child: CircleAvatar(
                      backgroundImage: ExactAssetImage('assets/images/google.png'),
                      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
                      radius: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.height *
                          (1.2 / 8) /
                          2.5
                          : MediaQuery.of(context).size.height *
                          (2.5 / 8) /
                          2.5,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  _menuOptions(Icons.person_outline_rounded, 'Profile'),
                  SizedBox(
                    height: 10.0,
                  ),
                  _menuOptions(Icons.settings, 'Setting'),
                  SizedBox(
                    height: 10.0,
                  ),
                  _menuOptions(Icons.support_outlined, 'Support'),
                  SizedBox(
                    height: 10.0,
                  ),
                  _menuOptions(Icons.description_outlined, 'About'),
                  SizedBox(
                    height: 30.0,
                  ),
                  exitButtonCall(),
                ],
              ),
            ),

          ],
        ),
      ),
    );

  }
  Widget _menuOptions(IconData icon, String optionName) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(
        milliseconds: 500,
      ),
      closedElevation: 0.0,
      openElevation: 3.0,
      closedColor: const Color.fromRGBO(34, 48, 60, 1),
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      onClosed: (value) {
        // print('Profile Page Closed');
        // if (mounted) {
        //   setState(() {
        //     ImportantThings.findImageUrlAndUserName();
        //   });
        // }
      },
      openBuilder: (context, openWidget) {
        if (optionName == 'Profile')
          return ProfileScreen();
        else if (optionName == 'Setting')
          return SettingsWindow();
        else if (optionName == 'Support')
          return SupportMenuMaker();
        else if (optionName == 'About') return AboutSection();
        return Center();

      },

      closedBuilder: (context, closeWidget) {
        return SizedBox(
          height: 60.0,
          child: Container(
            margin: EdgeInsets.only(left: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: Colors.lightBlue,
                  size: 30.0,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  optionName,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },

/*openBuilder: (BuildContext context, openWidget )
      { return Container(); },*/


    );
  }
  Widget exitButtonCall() {
    return GestureDetector(
      onTap: () async {
        //SystemNavigator ne yapar Sistem gezinme yığınının belirli yönlerini kontrol eder/يتحكم في جوانب محددة من حزمة التنقل في النظام.
        await SystemNavigator.pop(animated: true);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.exit_to_app_rounded,
            color: Colors.redAccent,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            'Exit',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
