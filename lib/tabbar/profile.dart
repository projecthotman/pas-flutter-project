import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project/login_page.dart';
// import 'package:project/tabbar/master.dart';

import '../models/home_response.dart';
import '../models/login_response.dart';

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

  late Future<String> _name, _email;
  LoginResponseModel? loginResponseModel;
  HomeResponseModel? homeResponseModel;
  Future<void> logout(BuildContext context, SharedPreferences prefs) async {
    prefs.remove("token");
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  void initState() {
    super.initState();
    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });

    _email = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("email") ?? "";
    });
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
                        backgroundImage: ExactAssetImage('assets/img/profile.png'),
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
                      const SizedBox(
                        height: 14,
                      ),
                      buildEmailFutureBuilder(_email),
                      const SizedBox(
                        height: 14,
                      ),
                      
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
            SizedBox(
              width: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      // ignore: use_build_context_synchronously
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
