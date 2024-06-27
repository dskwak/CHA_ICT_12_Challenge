import 'package:flutter/material.dart';
import 'package:backend/goout.dart';
class ResultPage extends StatelessWidget {
  final int score;

  Color? _getProgressColor(int score) {
    if (score >= 0 && score <= 4) {
      return Colors.green;
    } else if (score >=5 &&score <= 9) {
      return Colors.red[100];
    } else if (score >= 10&& score <=14) {
      return Colors.red[200];
    } else {
      return Colors.red; // 기본 색상 설정
    }
  }
  const ResultPage({Key? key, required this.score}) : super(key: key);
  String _getResultText(int score) {
    if (score >= 0 && score <= 4) {
      return '적응상의 지장을 초래할만한 우울 관련 증상을 거의 보고하지 않았습니다.';
    } else if(score >=5 &&score <= 9) {
      return  '경미한 수준의 우울감이 있으나 일상생활에 지장을 줄 정도는 아닙니다.';
    }
    else if (score >= 10&& score <=14) {
      return '중간수준의 우울감을 비교적 자주 경험하는 것으로 보고하였습니다. 직업적.사회적 적응에 일부 영향을 미칠 수 있어 주의 깊은 관찰과 관심이 필요합니다.';
    } else if (score >= 15 && score <= 19) {
      return '약간 심한 수준의 우울감을 자주 경험하는 것으로 보고하였습니다. 직업적.사회적 적응에 일부 영향을 미칠 경우. 정신건강 전문가의 도움을 받아 보시기를 권해 드립니다.';
    } else if(score >=20 && score<=27) {
      return '광범위한 우울 증상을 매우 자주.심한 수준에서 경험하는 것으로 보고하였습니다. 일상생활의 다양한 영역에서 어려움이 초래될경우.추가적인 평가나 정신건강 전문가의 도움을 받아보시기를 권해 드립니다.';
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
              value: score / 27.0, // assuming the score is out of 100
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
    } else if (score >= 15 && score <= 19) {
      return '약간심한수준';
    } else if(score >=20 && score<=27) {
      return  '심한수준';
    }
    else {
      return '점수 범위를 벗어났습니다.';
    }
  }
}
