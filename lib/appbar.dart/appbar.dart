import 'package:byteclub/main.dart';
import 'package:byteclub/pages/homepage.dart';
import 'package:byteclub/pages/innovationpage.dart';
import 'package:byteclub/pages/profilpage.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double _fabIconSize = 60; // Initial size for the FAB icon

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
            icon: Image.asset('lib/images/icon.png', width: 24, height: 24),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          setState(() {
            _fabIconSize = 80; // Increase size on long press
          });
        },
        onLongPressUp: () {
          setState(() {
            _fabIconSize = 60; // Reset size when long press is released
          });
        },
        child: FloatingActionButton(
          onPressed: () {
            _onItemTapped(1);
          },
          child: Image.asset(
            'lib/images/icon.png',
            width: _fabIconSize,
            height: _fabIconSize,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
