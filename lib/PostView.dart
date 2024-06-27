import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommunityScreen extends StatefulWidget {
  final List<dynamic> data;
  const CommunityScreen(this.data, {super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

Future<Map<String, dynamic>> changeLike(int BoardID) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.post(
    Uri.parse('https://sirihack.pythonanywhere.com/changeLike'),
    body: {
      'boardID': BoardID.toString(),
      'token': token,
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    return {};
  }
}

Future<Map<String, dynamic>> getVoteData(int boardID) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.post(Uri.parse('https://sirihack.pythonanywhere.com/getVoteData'),
      body: {
        'boardID': boardID.toString(),
        'token': token
      });
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    return {};
  }
}

void vote(int VOTEID, int VoteOptsID) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  await http.post(Uri.parse('https://sirihack.pythonanywhere.com/vote'),
      body: {
        'voteID': VOTEID.toString(),
        'token': token,
        'voteOptsID': VoteOptsID.toString()
      });
}
Future<bool> addComment(int BoardID, String Writer, String Content) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  debugPrint(token);
  final response = await http.post(
    Uri.parse('https://sirihack.pythonanywhere.com/addComment'),
    headers: {
      'Content-Type': 'application/json', // JSON 형식으로 데이터를 보내기 위해 헤더를 설정합니다.
    },

    body: jsonEncode({ // body를 JSON 형식으로 변환합니다.
      'token': token,
      'boardID': BoardID.toString(),
      'Writer': Writer,
      'Content': Content
    }),
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> result = jsonDecode(response.body);
    debugPrint(result.toString()); // 서버 응답을 확인합니다.
    if (result['result'] == 'error') {
      return false;
    } else {
      return true;
    }
  } else {
    debugPrint('Error: ${response.body}'); // 오류 메시지를 출력합니다.
    return false;
  }
}
Future<bool> reports(int BoardID) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final response = await http.post(Uri.parse('https://sirihack.pythonanywhere.com/addReport'),
      body: {
        'token': token,
        'boardID': BoardID.toString()
      });

  if (response.statusCode == 200) {
    Map<String, dynamic> result = jsonDecode(response.body);
    if (result['result'] == 'success') {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<List<dynamic>> reloadPost(int BoardID) async {
  final response = await http.post(Uri.parse('https://sirihack.pythonanywhere.com/getOnePost'),
      body: {
        'boardID': BoardID.toString(),
      }
  );

  return jsonDecode(response.body);
}

Future<List<Map<String, dynamic>>> getData(int boardID) async {
  final response = await http.post(
    Uri.parse('https://sirihack.pythonanywhere.com/getComment'),
    body: {'boardID': boardID.toString()},
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    debugPrint(responseData.toString());
    if (responseData['result'] == 'success') {
      return List<Map<String, dynamic>>.from(responseData['comments']);
    } else {
      print('Error: ${responseData['message']}');
      return [];
    }
  } else {
    print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    return [];
  }
}

class _CommunityScreenState extends State<CommunityScreen> {
  late Future<Map<String, dynamic>> voteData;
  late Future<List<Map<String, dynamic>>> commentData;
  String CommentWriter = '';
  String CommentContent = '';
  final TextEditingController writerController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool isReported = false; // 신고 상태를 추적하는 상태 변수

  @override
  void initState() {
    super.initState();
    commentData = getData(widget.data[0]);
    voteData = getVoteData(widget.data[0]);
  }

  void refreshVoteData() {
    setState(() {
      voteData = getVoteData(widget.data[0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isVotePost = widget.data[7] == 'vote'; // Assuming index 7 is the type of post
    bool canVoted = true;

    return Scaffold(
      appBar: AppBar(
        title: Text('CHA'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '커뮤니티',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '[${widget.data[7]}] ${widget.data[1]}\n${widget.data[2]} | ${widget.data[5]?.substring(0, 4)}.${widget.data[5]?.substring(4, 6)}.${widget.data[5]?.substring(6, 8)}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('조회수 ${widget.data[8]} | 추천수 ${widget.data[3]}'),
                  Container(height: 1, color: Colors.blue),
                ],
              ),
            ),
            if (!isVotePost)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 200,
                  child: Text('${widget.data[4]}'),
                ),
              ),

            if (isVotePost)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    FutureBuilder<Map<String, dynamic>>(
                      future: voteData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          var voteDataList = List<List<dynamic>>.from(snapshot.data!['voteData']);
                          int whereVoted = snapshot.data!['whereVote'];
                          debugPrint(whereVoted.toString());
                          return Column(
                            children: voteDataList.map((option) {
                              if (whereVoted == option[3]) {
                                canVoted = false;
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: whereVoted == option[3]
                                            ? ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                        )
                                            : ButtonStyle(),
                                        onPressed: () {
                                          if (canVoted) {
                                            vote(option[0], option[3]);
                                            refreshVoteData();
                                            canVoted = false;
                                          }
                                        },
                                        child: Text('${option[1]}'),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('${option[2]}'), // Replace with actual vote count
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          return Text('No data');
                        }
                      },
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(onPressed: () async {
                  final likeResult = await changeLike(widget.data[0]);
                  if (likeResult.isNotEmpty) {
                    setState(() {
                      widget.data[3] = likeResult['likes']; // 서버 응답의 likes 값으로 업데이트
                    });
                  }
                }, child: Text('추천(${widget.data[3]})')),
                TextButton(onPressed: () async {
                  bool result;
                  if (isReported) {
                    result = await reports(widget.data[0]); // 이미 신고된 경우 취소 기능을 호출하도록 수정 필요
                    if (result) {
                      setState(() {
                        isReported = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('신고가 취소되었습니다.')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('기능이 작동하지 않습니다. 관리자에게 문의하세요')));
                    }
                  } else {
                    result = await reports(widget.data[0]);
                    if (result) {
                      setState(() {
                        isReported = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('정상처리 되었습니다.')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('기능이 작동하지 않습니다. 관리자에게 문의하세요')));
                    }
                  }
                }, child: Text(isReported ? '신고 취소' : '신고')),
              ],
            ),
            Divider(),
            Row(
              children: [
                SizedBox(width: 20),
                Text('댓글',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                    )
                )],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: writerController,
                    onChanged: (value) {
                      CommentWriter = value;
                    },
                    decoration: InputDecoration(
                      hintText: '댓글 쓰기',
                      labelText: '글쓴이',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: contentController,
                    onChanged: (value) {
                      CommentContent = value;
                    },
                    decoration: InputDecoration(
                      hintText: '내용',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 8),
                  TextButton(
                      onPressed: () async {
                        if (CommentWriter.isNotEmpty && CommentContent.isNotEmpty) {
                          bool isSaved = await addComment(widget.data[0], CommentWriter, CommentContent);
                          if (!isSaved) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('댓글 저장 실패 관리자에게 문의하세요')));
                          } else {
                            setState(() {
                              commentData = getData(widget.data[0]); // 댓글 새로고침
                            });
                            writerController.clear();
                            contentController.clear();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('댓글 작성자와 내용을 입력하세요')));
                        }
                      },
                      child: Text('등록')
                  ),

                ],
              ),
            ),
            Divider(),
            FutureBuilder(
              future: commentData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No Comment',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      )
                  );
                } else {

                  final comments = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: comments.map<Widget>((comment) {
                      return Row(
                        children: [
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Divider(),
                              Text(
                                '${comment['writer']}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text('${comment['content']}'),
                              Text(
                                  '${comment['write_date']?.substring(0, 4)}.${comment['write_date']?.substring(4, 6)}.${comment['write_date']?.substring(6, 8)}'),
                              Divider(),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
