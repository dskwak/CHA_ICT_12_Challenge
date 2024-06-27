import 'package:flutter/material.dart';
import 'package:backend/goout.dart';
class ResultPage extends StatelessWidget {
  final int score;
  Color? _getProgressColor(int score) {
    if (score >= 0 && score <= 4) {
      return Colors.green;
    } else if (score >= 5 && score <= 9) {
      return Colors.red[100];
    } else if (score >= 10 && score <= 14) {
      return Colors.red[200];
    } else {
      return Colors.red; // 기본 색상 설정
    }
  }
  const ResultPage({Key? key, required this.score}) : super(key: key);
  String _getResultText(int score) {
    if (score >= 0 && score <= 4) {
      return '주의가 필요할 정도의 과도한 걱정이나 불안을 보고하지 않았습니다.';
    } else if(score >=5 &&score <= 9) {
      return  '다소 경미한 수준의 걱정과 불안을 보고하였습니다. 주의깊은 관찰과 관심이 필요합니다.';
    }
    else if (score >= 10&& score <=14) {
      return '주의가 필요한 수준의 과도한 걱정과 불안을 보고하였습니다. 추가적인 평가나 정신건강 전문가의 도움을 받아보시기를 권해 드립니다.';
    } else if (score >= 15 && score <= 21) {
      return '일상생활에 지장을 초래할 정도의 과도하고 심한 걱정과 불안을 보고하였습니다. 추가적인 평가나 정신건강 전문가의 전문가의 도움을 받아 보시기를 권해 드립니다.';
    } else {
      return '점수 범위를 벗어났습니다. \n에러: 문의 바랍니다.';
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
              value: score / 21.0, // assuming the score is out of 100
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
    if (score >= 0 && score <= 4) {
      return '정상';
    } else if (score >=5 &&score <= 9) {
      return '경미한수준';
    } else if (score >= 10&& score <=14) {
      return '중간수준';
    } else if (score >= 15 && score <= 21) {
      return '심한수준';
    }
    else {
      return '점수 범위를 벗어났습니다.';
    }
  }
}
