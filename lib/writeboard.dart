import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

Future<bool> savePost(String title, String content, String? boardType, String? isAnonymous, List<dynamic> imgs, List<String> options) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (boardType == null || isAnonymous == null || title.isEmpty) {
    return false;
  }

  // Use List<String> instead of Set<String>
  List<String> badWords = ["씨발","시발","느금마","애미","장애","병신","ㅄ","ㅂㅅ","미친", "ㅁㅊ", "개새끼","지랄", "ㅈㄹ", "고아", "엠창", "루저","썅년", "씹새끼","아가라","염병","정신병","정병","좆밥","짱깨"];

  // Replace bad words with asterisks
  badWords.forEach((word) {
    content = content.replaceAll(word, "*" * word.length);
  });

  if (boardType != 'vote' && content.isEmpty) {
    return false;
  }

  try {
    final response = await http.post(
      Uri.parse('https://sirihack.pythonanywhere.com/addPost'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'boardType': boardType,
        'isAnonymous': isAnonymous,
        'resources': imgs,  // 인코딩 필요 없음
        'token': token ?? '',
        'options': options,  // 인코딩 필요 없음
      }),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      return result['result'] != 'error';
    } else {
      debugPrint('Failed to save post: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('Exception: $e');
    return false;
  }
}

class _CommunityPageState extends State<CommunityPage> {
  String? boardType;
  String? isAnonymous = '이름 공개';
  String postTitle = '';
  String content = '';
  List<dynamic> imgs = [];
  List<String> options = [''];

  final Map<String, String> boardTypeMap = {
    '일반': 'normal',
    '공지': 'notification',
    '봉사자 모집': 'volunteer',
    '투표': 'vote',
  };

  void _addOption() {
    setState(() {
      options.add('');
    });
  }

  void _removeOption(int index) {
    setState(() {
      options.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: Text('CHA'),
        centerTitle: true,
        actions: [
          Icon(Icons.person),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '커뮤니티',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  hintText: '제목',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  postTitle = value;
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('종류 선택'),
                      value: boardType,
                      onChanged: (newValue) {
                        setState(() {
                          boardType = newValue;
                        });
                      },
                      items: boardTypeMap.keys.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('익명 여부'),
                      value: isAnonymous,
                      onChanged: (newValue) {
                        setState(() {
                          isAnonymous = newValue;
                        });
                      },
                      items: <String>['이름 공개', '익명']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: boardType == '투표'
                    ? ListView.builder(
                  itemCount: options.length + 1,
                  itemBuilder: (context, index) {
                    if (index == options.length) {
                      return TextButton(
                        onPressed: _addOption,
                        child: Text('항목 추가', style: TextStyle(color: Colors.pink)),
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: '항목 ${index + 1}',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              options[index] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeOption(index),
                        ),
                      ],
                    );
                  },
                )
                    : TextFormField(
                  textAlign: TextAlign.left,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    hintText: '내용을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    content = value;
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    bool isSaved = await savePost(
                      postTitle,
                      content,
                      boardTypeMap[boardType],  // 한글 값을 영어로 매핑하여 전달
                      isAnonymous,
                      imgs,
                      options,
                    );
                    if (isSaved) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BoardPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('게시글 저장 실패 관리자에게 문의하세요')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('업로드'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
