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

class _MasterTabbarState extends State<MasterTabbar> {
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    pageController = PageController(initialPage: pageIndex);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: <Widget>[
          const homepage.HomePage(),
          const simpanpage.SimpanPage(),
          profile.Profile(),
        ],
        onPageChanged: onPageChanged,
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
          pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
        },
        index: pageIndex, // Ini akan menjaga ikon yang aktif sesuai dengan halaman yang aktif
      ),
    );
  }
}
