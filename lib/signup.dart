import 'dart:convert';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(home: SignUpPage()));
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordMatch = true;

  void _checkPasswordMatch() {
    setState(() {
      _isPasswordMatch = _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _handleSignUp() async{
    _checkPasswordMatch();
    if (_isPasswordMatch) {
      final response = await http.post(Uri.parse('https://sirihack.pythonanywhere.com/add'),
      body : {
          'username' : _usernameController.text,
          'password' : _passwordController.text,
          'email' : _emailController.text,
      });

      if(response.statusCode == 200){
        Map<String, dynamic> result = jsonDecode(response.body);
        if(result['result'] == 'error'){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('존재하는 이름입니다.')));
        }else{
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('token', result['access_token']);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardPage(),
            ),
          );
        }


      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 시스템에 오류가 있습니다.')));
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('비밀번호가 맞지 않습니다.')));
    }
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
                '회원가입',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (_) => _checkPasswordMatch(),
              ),
              SizedBox(height: 8),
              const Text(
                '비밀번호는 영문, 숫자, 특수문자를 포함하여 10자 이상이어야 합니다',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isPasswordMatch ? Colors.grey : Colors.red,
                    ),
                  ),
                ),
                obscureText: true,
                onChanged: (_) => _checkPasswordMatch(),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _handleSignUp,
                  child: Text(
                    '회원가입',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
