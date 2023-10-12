import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("halaman dashboard", style: TextStyle(fontSize: 30)),
            Padding(padding: EdgeInsets.all(10)),
            Image.asset("img/home.png", width: 350),
          ],
        ),
      ),
    );
  }
}
