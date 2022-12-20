import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../Backend/firebase/OnlineDatabaseManagment/cloud_data_managment.dart';
import '../../Global_Uses/enum.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _availableUsers = [];
  List<Map<String, dynamic>> _sortedAvailableUsers = [];
  List<dynamic> _myConnectionRequestCollection = [];

  bool _isLoading = false;

  final CloudStoreDataManagement _cloudStoreDataManagement =
  CloudStoreDataManagement();

  Future<void> _initialDataFetchAndCheckUp() async {
    //mounted demeki eger kullanici bu sayfda baska sayfaya gecmediyse o zaman setState calissin
    if (mounted) {
      setState(() {
        this._isLoading = true;
      });
    }

    //getAllUsersListExceptMyAccount methoduna simdiki kullanicinin emali atiyoz ve bu method bize tum kullanicilsri list olark dondureck simdiki kullanici hariç
    final List<Map<String, dynamic>> takeUsers = await _cloudStoreDataManagement.getAllUsersListExceptMyAccount(currentUserEmail: FirebaseAuth.instance.currentUser!.email.toString());

    final List<Map<String, dynamic>> takeUsersAfterSorted = [];

    if (mounted) {
      setState(() {
        takeUsers.forEach((element) {
          if (mounted) {
            setState(() {
              takeUsersAfterSorted.add(element);//tum diger kullanicilari getirdikten sonra ve forEach method ile sirali bi sekilde yaptiktan sonra takeUsersAfterSorted listeye ekliyoz
            });
          }
        });
      });
    }

    final List<dynamic> _connectionRequestList = await _cloudStoreDataManagement.currentUserConnectionRequestList(email: FirebaseAuth.instance.currentUser!.email.toString());

    if (mounted) {
      setState(() {
        _availableUsers = takeUsers;
        _sortedAvailableUsers = takeUsersAfterSorted;
        _myConnectionRequestCollection = _connectionRequestList;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  //search ekrani acilir acilmaz initStat fonksyonu calisir ve icindeki fonksyon calisir ve
  void initState() {
    _initialDataFetchAndCheckUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        body: LoadingOverlay(
          isLoading: _isLoading,
          color: Colors.black54,
          child: Container(
            margin: EdgeInsets.all(12.0),
            width: double.maxFinite,
            height: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Text(
                    'Available Connections',
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  //istedigimz bi kullanici bulmak icin TextField input olarak kullanacm
                  child: TextField(
                    autofocus: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search User Name',
                      hintStyle: TextStyle(color: Colors.white70),
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(width: 2.0, color: Colors.lightBlue)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(width: 2.0, color: Colors.lightBlue)),
                    ),
                    //kullanici tarafin dan girilen arama kelimesi writeText degiskene atilack
                    onChanged: (writeText) {
                      if (mounted) {
                        setState(() {
                          _isLoading = true;
                        });
                      }
                      if (mounted) {
                        setState(() {
                          //arama yaparken veyayaptiktan sonra listenin elamanlari bosaltiyoruz yoksa ayni kullanicilari birden fazla yazilack/gosterilck
                          _sortedAvailableUsers.clear();
                          print('Available Users: ${_availableUsers}');
                          //istedigimz bi kullanici bulmak icin yeterki ayni ilk harfi yazmamiz yeterli ve ona benzeyen tum  kullanicilar listesi cikack
                          _availableUsers.forEach((userNameMap) {//cevirimci/musait olan kullanicilar(_availableUsers) listesinde bi arama yapilack eger girilen harf listede varsa onu _sortedAvailableUsers listesine ekleyip ekran gostermek icin
                            if (userNameMap.values.first.toString().toLowerCase()
                                .startsWith('${writeText.toLowerCase()}'))
                              _sortedAvailableUsers.add(userNameMap);
                            //_sortedAvailableUsers degerleri degisince _initialDataFetchAndCheckUp method ve initState icnde oldugu icin degisklik ekranda gorebiliriz
                            print('userNameMap=: ${userNameMap.values.first.toString()}');
                          });
                        });
                      }

                      if (mounted) {
                        setState(() {
                          this._isLoading = false;
                        });
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  height: MediaQuery.of(context).size.height - 50,
                  width: double.maxFinite,
                  //color: Colors.red,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _sortedAvailableUsers.length,
                    itemBuilder: (connectionContext, index) {
                      return connectionShowUp(index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget connectionShowUp(int index) {
    return Container(
      height: 80.0,
      width: double.maxFinite,
      //color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            //kullanici adi ve hakindaki bilgiler ust uste yazmak icin
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _sortedAvailableUsers[index].values.first.toString().split('[user-name-about-divider]')[0],
                style: TextStyle(color: Colors.orange, fontSize: 20.0),
              ),
              Text(
                    _sortedAvailableUsers[index].values
                    .first
                    .toString()
                    .split('[user-name-about-divider]')[1],
                style: TextStyle(color: Colors.lightBlue, fontSize: 16.0),
              ),
            ],
          ),
          TextButton(
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                    side: BorderSide(
                        color: _getRelevantButtonConfig(//button'in rengini degistirmek icin
                            connectionStateType: ConnectionStateType.ButtonBorderColor,
                            index: index)),
                  )),
              child: _getRelevantButtonConfig(//button'in icndeki adi degistirmek icin
                  connectionStateType: ConnectionStateType.ButtonNameWidget,
                  index: index),
              onPressed: () async {
                final String buttonName = _getRelevantButtonConfig(
                    connectionStateType: ConnectionStateType.ButtonOnlyName,
                    index: index);

                if (mounted) {
                  setState(() {
                    this._isLoading = true;
                  });
                }
//buttoni basinca eger conect kelimesi varsa pending/bekleme olacak ve kullanicinin emaili changeConnectionStatus fonksyona atiyoz diger kullanici ekranda farkli bi secenek gorsun diye(accept)
                if (buttonName == ConnectionStateName.Connect.toString()) {
                  if (mounted) {
                    setState(() {
                      _myConnectionRequestCollection.add({
                        _sortedAvailableUsers[index].keys.first.toString():
                        OtherConnectionStatus.Request_Pending.toString(),
                      });
                    });
                  }
                  //_sortedAvailableUsers icinde tum diger kullanicilar bilgileri veya emialler
                await _cloudStoreDataManagement.changeConnectionStatus(
                      oppositeUserMail:_sortedAvailableUsers[index].keys.first.toString(),
                      currentUserMail: FirebaseAuth.instance.currentUser!.email.toString(),
                      connectionUpdatedStatus: OtherConnectionStatus.Invitation_Came.toString(),
                      currentUserUpdatedConnectionRequest: _myConnectionRequestCollection);

                } else if (buttonName == ConnectionStateName.Accept.toString()) {
                  if (mounted) {
                    setState(() {
                      _myConnectionRequestCollection.forEach((element) {
                        if (element.keys.first.toString() == _sortedAvailableUsers[index].keys.first.toString()) {
                          _myConnectionRequestCollection[_myConnectionRequestCollection.indexOf(element)] = {
                            _sortedAvailableUsers[index].keys.first.toString():
                            OtherConnectionStatus.Invitation_Accepted.toString(),
                          };
                        }
                      });
                    });
                  }

                  await _cloudStoreDataManagement.changeConnectionStatus(
                      storeDataAlsoInConnections: true,
                      oppositeUserMail: _sortedAvailableUsers[index].keys.first.toString(),
                      currentUserMail: FirebaseAuth.instance.currentUser!.email.toString(),
                      connectionUpdatedStatus: OtherConnectionStatus.Request_Accepted.toString(),
                      currentUserUpdatedConnectionRequest: _myConnectionRequestCollection);
                }

                if (mounted) {
                  setState(() {
                    this._isLoading = false;
                  });
                }
              }),
        ],
      ),
    );
  }

  dynamic _getRelevantButtonConfig(
      {required ConnectionStateType connectionStateType, required int index}) {
    bool _isUserPresent = false;
    String _storeStatus = '';//iste atma son durumu kayit etmek icin kullanaczm

    this._myConnectionRequestCollection.forEach((element) {
      //the id of the list is by defult is the user's email.Asagida if icnde emailleri karsilastiriyoruz kullanici cevirimci bulmak icin
      if (element.keys.first.toString() == _sortedAvailableUsers[index].keys.first.toString()) {
        _isUserPresent = true;
        _storeStatus = element.values.first.toString();
      }
    });

    if (_isUserPresent) {
      print('User Present in Connection List');
//eger button'in durmu beklemede veya Davet gelince button'in rengi sari olacaktir
      if (_storeStatus == OtherConnectionStatus.Request_Pending.toString() || _storeStatus == OtherConnectionStatus.Invitation_Came.toString()) {
        if (connectionStateType == ConnectionStateType.ButtonNameWidget)
          //button'in icindeki adi String yazmak icin enum degerli String'e cevirdim toString() method ile
          return Text(_storeStatus == OtherConnectionStatus.Request_Pending.toString()
          //ConnectionStateName kelimesi pending ile beraber text icinde yazmamk icin split fonks kullandim sadece Pending kelimesi ayirdik ve boylece diger textlerde
                ? ConnectionStateName.Pending.toString().split(".")[1].toString()
                : ConnectionStateName.Accept.toString()
                .split(".")[1]
                .toString(),
            style: TextStyle(color: Colors.yellow),
          );
        else if (connectionStateType == ConnectionStateType.ButtonOnlyName)
          return _storeStatus ==
              OtherConnectionStatus.Request_Pending.toString()
              ? ConnectionStateName.Pending.toString()
              : ConnectionStateName.Accept.toString();

        return Colors.yellow;
      } else {
        if (connectionStateType == ConnectionStateType.ButtonNameWidget)
          return Text(
            ConnectionStateName.Connected.toString().split(".")[1].toString(),
            style: TextStyle(color: Colors.green),
          );
        else if (connectionStateType == ConnectionStateType.ButtonOnlyName)
          return ConnectionStateName.Connected.toString();

        return Colors.green;
      }
    } else {
      print('User Not Present in Connection List');
//istek gondermeyince ve accepted kelimesi olmayinca button'in adi connect ve rengi mavi olack
      if (connectionStateType == ConnectionStateType.ButtonNameWidget)
        return Text(
          ConnectionStateName.Connect.toString().split(".")[1].toString(),
          style: TextStyle(color: Colors.lightBlue),
        );
      else if (connectionStateType == ConnectionStateType.ButtonOnlyName)
        return ConnectionStateName.Connect.toString();

      return Colors.lightBlue;
    }
  }
}