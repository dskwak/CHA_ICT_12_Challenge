import 'package:flutter/material.dart';
import 'package:backend/goout.dart';
class ResultPage extends StatelessWidget {
  final int score;
  Color? _getProgressColor(int score) {
    if (score >= 0 && score < 1) {
      return Colors.green;
    } else if (score == 2) {
      return Colors.red[100];
    } else if (score >= 3 && score < 5) {
      return Colors.red;
    } else {
      return Colors.red; // 기본 색상 설정
    }
  }
  const ResultPage({Key? key, required this.score}) : super(key: key);
  String _getResultText(int score) {
    if (score >= 0 && score <= 1) {
      return '일상생활 적응에 지장을 초래할만한 외상 사건 경험이나 이와 관련된 인지적,정서적,행동문제를 거의 보고하지 않았습니다.';
    } else if (score ==2) {
      return '외상 사건과 관련된 반응으로 불편감을 호소하고 있습니다. 평소보다 일상생활에 적응하는데 어려움을 느끼신다면 추가적인 평가나 정신건강 전문가의 도움을 받아보시기를 권해 드립니다.';
    } else if (score >= 3 && score <= 5) {
      return '외상 사건과 관련된 반응으로 심한 불편감을 호소하고 있습니다. 평소보다 일상생활에 적응하는데 어려움을 느낄 수 있습니다. 추가적인 평가나 정신건강 전문가의 도움을 받아보시기를 권해드립니다.';
    } else {
      return '점수 범위를 벗어났습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    String resultText = _getResultText(score);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('CHA 앱 - 결과'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showExitConfirmationDialog(context); // 여기에서 showExitConfirmationDialog 호출
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '총점: $score',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: score / 5.0, // assuming the score is out of 100
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              color: _getProgressColor(score),
            ),
            SizedBox(height: 20),
            Text(
              '위험도 수준: ${_getResultLevel(score)}',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                resultText,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getResultLevel(int score) {
    if (score >= 0 && score <= 1) {
      return '정상';
    } else if (score == 2) {
      return '주의요망';
    } else if (score >= 3 && score <= 5) {
      return '심한 수준';
    } else {
      return '점수 범위를 벗어났습니다.';
    }
  }
}
