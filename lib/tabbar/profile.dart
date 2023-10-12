import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("halaman profile", style: TextStyle(fontSize: 30)),
            Padding(padding: EdgeInsets.all(10)),
            Image.asset("img/profile.png", width: 350),
          ],
        ),
      ),
    );
  }
}
