import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'PostView.dart';
import 'login.dart';
import 'writeboard.dart';
import 'drawbar.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: BoardPage()));
}

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  int startPage = 1;
  int now = 1;
  String boardType = 'normal';
  String search = '';
  late Future<List<List<dynamic>>> boardData;
  late Future<int> pageSize;
  int PageMax = 0;
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.arguments == true) {
      loadData();
    }
  }

  void checkLoginStatus() async {
    isLogin = await hasToken();
    if (!isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  void loadData() {
    setState(() {
      boardData = getData(now, boardType, search);
      pageSize = getPageSize(boardType, search);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrawerBar()),
            );
            if (result == true) {
              loadData();
            }
          },
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '커뮤니티',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            SearchBar(
              trailing: [Icon(Icons.search)],
              elevation: MaterialStateProperty.all(1),
              onSubmitted: (value) {
                setState(() {
                  now = 1;
                  startPage = 1;
                  search = value;
                  loadData();
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                buildTextButton('일반', 'normal'),
                buildTextButton('공지', 'notification'),
                buildTextButton('봉사자 모집', 'volunteer'),
                buildTextButton('투표', 'vote'),
                Expanded(
                  child: TextButton(
                    child: Text(
                      '글쓰기',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CommunityPage()),
                      );
                      if (result == true) {
                        loadData();
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<List<dynamic>>>(
                future: boardData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No data available');
                  } else {
                    return ListView(
                      children: snapshot.data!.map((posting) {
                        return Column(
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                // 클릭한 게시물의 조회수를 증가시킵니다.
                                await http.post(
                                  Uri.parse('https://sirihack.pythonanywhere.com/addViews'),
                                  body: {'boardID': posting[0].toString()},
                                );

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityScreen(posting),
                                  ),
                                );
                                if (result == true) {
                                  loadData();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 30),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '${posting[1]} [${posting[3]}]',
                                      style: TextStyle(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${posting[2]} | ${posting[5]?.substring(0, 4)}.${posting[5]?.substring(4, 6)}.${posting[5]?.substring(6, 8)}',
                                      style: TextStyle(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        if (startPage > 1) {
                          startPage = startPage - 5;
                          if (startPage < 1) {
                            startPage = 1;
                          }
                          now = startPage;
                          loadData();
                        }
                      });
                    },
                  ),
                  FutureBuilder<int>(
                    future: pageSize,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Text('No data available');
                      } else {
                        int totalPageCount = snapshot.data!;
                        PageMax = totalPageCount;
                        return Row(
                          children: List.generate(5, (index) {
                            int pageIndex = index + startPage;
                            if (pageIndex <= totalPageCount) {
                              return TextButton(
                                onPressed: () {
                                  setState(() {
                                    now = pageIndex;
                                    loadData();
                                  });
                                },
                                child: Text(
                                  '$pageIndex',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: now == pageIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: now == pageIndex ? 27 : 20,
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          }),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        if (startPage + 5 <= PageMax) {
                          startPage = startPage + 5;
                          now = startPage;
                          loadData();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextButton(String text, String type) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            boardType = type;
            now = 1; // 페이지를 1로 설정
            startPage = 1; // 시작 페이지를 1로 설정
            loadData();
          });
        },
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: boardType == type ? FontWeight.bold : FontWeight.normal,
            fontSize: boardType == type ? 20 : 16,
          ),
        ),
      ),
    );
  }
}

Future<List<List<dynamic>>> getData(int page, String boardType, String search) async {
  final response = await http.post(
    Uri.parse('https://sirihack.pythonanywhere.com/showBoard'),
    body: {
      'page': page.toString(),
      'type': boardType,
      'search': search,
    },
  );

  List<dynamic> jsonResponse = json.decode(response.body);
  List<List<dynamic>> result = jsonResponse.map((item) {
    if (item[7] == 'vote') {
      return List<dynamic>.from(item)..add(true); // Adding a flag for vote posts
    } else {
      return List<dynamic>.from(item)..add(false); // Adding a flag for non-vote posts
    }
  }).toList();
  return result;
}

Future<int> getPageSize(String boardType, String search) async {
  final response = await http.post(
    Uri.parse('https://sirihack.pythonanywhere.com/getPageSize'),
    body: {
      'type': boardType,
      'search': search,
    },
  );

  var jsonResponse = json.decode(response.body);
  int pageSize = jsonResponse['pageSize'];
  return pageSize;
}

Future<bool> hasToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  debugPrint(token);
  return token != null;
}
