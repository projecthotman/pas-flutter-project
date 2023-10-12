import 'package:flutter/material.dart';

class Presensi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("halaman Presensi", style: TextStyle(fontSize: 30)),
            Padding(padding: EdgeInsets.all(10)),
            Image.asset("img/tambah.png", width: 350),
          ],
        ),
      ),
    );
  }
}
