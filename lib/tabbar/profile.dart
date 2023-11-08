
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as myHttp;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project/loginPage.dart';
import 'package:project/tabbar/master.dart';

import '../models/home-response.dart';
import '../models/login-response.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

  Future<void> logout(BuildContext context, SharedPreferences prefs) async {
  prefs.remove("token");
  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
}


class _ProfilePageState extends State<ProfilePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Future<String> _name, _token, _email;
  LoginResponseModel? loginResponseModel;
  HomeResponseModel? homeResponseModel;
  Future<void> logout(BuildContext context, SharedPreferences prefs) async {
    prefs.remove("token");
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });

    _email = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("email") ?? "";
    });
  }

  Future getData() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _token
    };
    var response = await myHttp.get(
        Uri.parse('https://cek-wa.com/presensi/public/api/get-presensi'),
        headers: headers);
    print("Response dari server: " + response.body);
    loginResponseModel =
        LoginResponseModel.fromJson(json.decode(response.body));

    // Pastikan bahwa data telah dimuat dengan benar
    if (loginResponseModel != null && loginResponseModel!.data != null) {
      final userEmail = loginResponseModel!.data!.email;
      // Simpan email ke dalam _email
      setState(() {
        _email = Future.value(userEmail);
      });
    }
  }

  Widget buildNameFutureBuilder(Future<String> future) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return Text(
              snapshot.data!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          } else {
            return const Text(
              "-",
              style: TextStyle(fontSize: 18),
            );
          }
        }
      },
    );
  }

  Widget buildEmailFutureBuilder(Future<String> future) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return Text(
              snapshot.data!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          } else {
            return const Text(
              "-",
              style: TextStyle(fontSize: 18),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 36, bottom: 25, left: 14),
              child: Row(
                children: [
                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2.0,
                        color: const Color(0xFF688E4E),
                      ),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            ExactAssetImage('assets/img/profile.png'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildNameFutureBuilder(_name),
                      SizedBox(
                        height: 14,
                      ),
                      buildEmailFutureBuilder(
                          _email), // Menampilkan email pengguna
                    ],
                  )
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
              ),
              height: 1,
              width: 350,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await logout(context, prefs);
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Color(0xFF688E4E),
                      ),
                      title: Text('Log Out'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
