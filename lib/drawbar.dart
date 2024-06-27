import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'jagaMain.dart';
import '자기계발/jwagi.dart';

class DrawerBar extends StatelessWidget {
  const DrawerBar({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // After removing the token, navigate to the main page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BoardPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Text(
              '바로가기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('커뮤니티'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BoardPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add_box_outlined),
            title: Text('자가진단'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JagaMain()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('자기계발'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Jwagigabal()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('로그아웃'),
            onTap: () async {
              await _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
