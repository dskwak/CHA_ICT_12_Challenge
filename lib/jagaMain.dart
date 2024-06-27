import 'package:flutter/material.dart';
import 'package:backend/boolan.dart';
import 'package:backend/drawbar.dart';
import 'package:backend/jwasal.dart';
import 'package:backend/sincha.dart';
import 'package:backend/testsec.dart';
import 'package:backend/waasang.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // 앱 전체 배경색을 흰색으로 설정
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정
          iconTheme: IconThemeData(color: Colors.black), // 앱바 아이콘 색상 설정
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 30), // 앱바 제목 색상 설정
        ),
      ),
      home: JagaMain(), // Use the correct class here
    ),
  );
}

class JagaMain extends StatelessWidget { // Renamed class to follow Dart naming conventions
  const JagaMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 앱 화면 배경색을 흰색으로 설정
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정
            iconTheme: IconThemeData(color: Colors.black), // 앱바 아이콘 색상 설정
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CHA앱',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black, // 제목 색상 설정
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Image.asset('assets/img.png'),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: [
              IconButton(
                icon: Image.asset('assets/profile.png'),
                onPressed: () {},
              ),
            ],
            floating: true,
            pinned: true,
            snap: false,
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  buildCard(context, 'assets/mujind.png', '우울증 진단', '약 2~3분', WooWool()),
                  buildCard(context, 'assets/boolanee.png', '불안증 진단', '약 1~2분', Boolan()),
                  buildCard(context, 'assets/saljwa.png', '자살 위험성 진단', '1분 미만', jwasal()),
                  buildCard(context, 'assets/sinchap.png', '신체증상 진단', '3~4분', sincha()),
                  buildCard(context, 'assets/wasangwoo.png', '외상후 스트레스 진단', '1분 미만', waasang()),

                ],
              ),
            ),
          ),
        ],
      ),
      drawer: DrawerBar(),
    );
  }

  Widget buildCard(BuildContext context, String imagePath, String title, String time, Widget route) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 3),  // 검정색 테두리 추가
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => route));
        },
        child: Container(
          height: 160, // 카드의 높이 설정
          color: Colors.grey[100], // 카드 안의 배경색을 연한 회색으로 설정
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Image.asset(imagePath, width: 120, height: 120, fit: BoxFit.cover), // 이미지 크기 설정
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(time),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
