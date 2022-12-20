import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

class LogsCollection extends StatefulWidget {
  const LogsCollection({Key? key}) : super(key: key);

  @override
  State<LogsCollection> createState() => _LogsCollectionState();
}

class _LogsCollectionState extends State<LogsCollection> {
  final List<String> _callingConnection = [
    'JOSEPH',
    'ALHURIYA',
    'YOUSIF',
    'MOHAMMED',
    'ENAS',
    'GOOGLE'
  ];
  final _isLoading=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        body: LoadingOverlay(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          progressIndicator: const CircularProgressIndicator(
            backgroundColor: Colors.black87,
          ),
          isLoading: this._isLoading,
          child: Container(//yazilan kullanici adi fotosu ve simgesi hepsi bu container icinde olacak ve listView kullanark icinde her kullanici icin ayri bi container olack
            margin: const EdgeInsets.all(12.0),
            width: double.maxFinite,
            height: double.maxFinite,
            //listView verilen listeye gore containerlar olusturack ve her container icinde ayri bi kullanici adi fotosu ve simgesi olacaktir
            child: ListView.builder(
              itemCount: this._callingConnection.length,
              itemBuilder: (upperContext, index) => _everyConnectionHistory(index),
            ),
          ),
        ),
      ),
    );

  }
  Widget _everyConnectionHistory(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),//containerler arasinda asagidan bosluk birakmak icin kullanilir
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 30.0,//container icindeki fotografi boyutunu ayarlamak icin kullanacz
            backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
            backgroundImage: ExactAssetImage('assets/images/callsUser.PNG'),
            //getProperImageProviderForConnectionsCollection(
            //    _userName),
          ),
          Text(
            this._callingConnection[index],
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          IconButton(
            icon: Icon(
              Icons.call,
              size: 30.0,
              color: Colors.green,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
