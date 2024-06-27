import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(home: FindIdPasswordPage()));
}

class FindIdPasswordPage extends StatefulWidget {
  const FindIdPasswordPage({super.key});

  @override
  _FindIdPasswordPageState createState() => _FindIdPasswordPageState();
}

class _FindIdPasswordPageState extends State<FindIdPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  Map<String, dynamic> userInfo = {}; // Move userInfo here to class level

  void _sendMail(String email) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/sendMail'),
      body: {'email': email},
    );
    // Handle response if needed
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('인증코드가 전송되었습니다.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일 전송 실패')));
    }
  }

  Future<void> _showInfo(String magicKey, String email) async {
    final response = await http.post(
      Uri.parse('https://sirihack.pythonanywhere.com/checkCode'),
      body: {'email': email, 'code': magicKey},
    );

    Map<String, dynamic> result = jsonDecode(response.body);
    setState(() {
      userInfo = result; // Update userInfo with the fetched data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          'CHA',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
            color: Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Text(
                '아이디/비밀번호 찾기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: '이메일',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _sendMail(_emailController.text);
                    },
                    child: Text('인증코드 전송'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: '인증번호 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showInfo(_codeController.text, _emailController.text);
                  },
                  child: Text(
                    '아이디 찾기',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (userInfo.isNotEmpty)
                userInfo['result'] == 'error'
                    ? Text(
                  '잘못된 코드',
                  style: TextStyle(color: Colors.red),
                )
                    : Text('아이디 : ${userInfo['userData'][0]}, 비밀번호 : ${userInfo['userData'][1]}'),
            ],
          ),
        ),
      ),
    );
  }
}
