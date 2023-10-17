import 'package:flutter/material.dart';

import 'profile.dart' as profile;

import 'package:project/simpanPage.dart' as simpanpage;
import 'package:project/homePage.dart' as homepage;

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() {
  runApp(const MaterialApp(
    title: "Tab Bar",
    home: MasterTabbar(),
  ));
}

class MasterTabbar extends StatefulWidget {
  const MasterTabbar({super.key});

  @override
  State<MasterTabbar> createState() => _MasterTabbarState();
}

class _MasterTabbarState extends State<MasterTabbar> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: const <Widget>[
          homepage.HomePage(),
          simpanpage.SimpanPage(),
          profile.ProfilePage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 50,
        color: const Color(0xFF688E4E),
        backgroundColor: Colors.white,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.add, size: 30, color: Colors.white),
          Icon(Icons.account_circle, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          controller.animateTo(index);
        },
      ),
    );
  }
}
