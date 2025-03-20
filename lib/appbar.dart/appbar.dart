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
  double _fabIconSize = 120.0; // Standard-Größe

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
            icon: Image.asset('lib/images/icon.png', width: 0, height: 0),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      // Verwenden Sie ein Container statt FloatingActionButton
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 15),
        width: _fabIconSize,
        height: _fabIconSize,
        child: GestureDetector(
          onTap: () {
            _onItemTapped(1);
          },
          onLongPress: () {
            setState(() {
              _fabIconSize = 350.0; // Deutlich größer beim Gedrückthalten
              print("Size increased to: $_fabIconSize"); // Debug-Ausgabe
            });
          },
          onLongPressUp: () {
            setState(() {
              _fabIconSize = 100.0; // Zurück zur Standard-Größe
              print("Size reset to: $_fabIconSize"); // Debug-Ausgabe
            });
          },
          child: AnimatedContainer(
            duration: Duration(
              milliseconds: 200,
            ), // Animation für flüssigeren Übergang
            width: _fabIconSize,
            height: _fabIconSize,
            child: Image.asset(
              'lib/images/icon.png',
              fit: BoxFit.contain, // Wichtig: Behält Proportionen bei
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
