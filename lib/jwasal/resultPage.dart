import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final String riskLevel;

  ResultPage({super.key, required this.score, required this.riskLevel});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int riskrevel = 0;

  Color? _getProgressColor(String riskLevel) {
    if (riskLevel == '자살 거의 없음') {
      riskrevel = 1;
      return Colors.green;
    } else if (riskLevel == '자살 위험성 낮음') {
      riskrevel = 2;
      return Colors.yellow;
    } else if (riskLevel == '자살 위험도 높음') {
      riskrevel = 4;
      return Colors.red;
    } else {
      riskrevel = 4;
      return Colors.red; // 기본 색상 설정
    }
  }

  String _getResultText(String riskLevel) {
    if (riskLevel == '자살 거의 없음') {
      return '자살 거의 없음';
    } else if (riskLevel == '자살 위험성 낮음') {
      return '자살 과거력이 있었거나 자살 계획에 대한 생각을 보고하였지만, 우발적인 자살 시도를 보일 가능성은 낮습니다.';
    } else if (riskLevel == '자살 위험도 높음') {
      return '자살 가능성이 있다고 보고하였거나 자살 사고나 행동을 저지할 수 있는 보호요인이 없다고 보고하였습니다. \n추가적인 평가나 정신건강 전문가의 도움을 받아보시기를 권해드립니다.';
    } else {
      return '점수 범위를 벗어났습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    String resultText = _getResultText(widget.riskLevel);
    Color? progressColor = _getProgressColor(widget.riskLevel);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('CHA 앱 - 결과'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              '자살 위험성 진단',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '위험도: ${widget.riskLevel}',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: riskrevel / 4.0, // riskrevel에 따른 길이 조절
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              color: progressColor,
            ),
            SizedBox(height: 20),
            Text(
              resultText,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
