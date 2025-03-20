import 'package:byteclub/main.dart';
import 'package:byteclub/pages/homepage.dart';
import 'package:byteclub/pages/innovationpage.dart';
import 'package:byteclub/pages/profilpage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[Page1(), Page2(), Page3()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'lib/images/icon.png',
              width: 24, // Set the width to fit the icon size
              height: 24, // Set the height to fit the icon size
            ),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(1);
        },
        child: Image.asset(
          'lib/images/icon.png',
          width: 60, // Set the width to fit the icon size
          height: 60, // Set the height to fit the icon size
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
