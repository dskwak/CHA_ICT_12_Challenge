import 'package:flutter/material.dart';
import 'package:backend/jwasal/resultPage.dart'; // 결과 페이지 import
import 'package:backend/goout.dart';

class FirstTest extends StatefulWidget {
  const FirstTest({Key? key}) : super(key: key);

  @override
  _FirstTestState createState() => _FirstTestState();
}

class _FirstTestState extends State<FirstTest> {
  int _score = 0; // Variable to store the score
  int _currentQuestionIndex = 0; // Index to keep track of the current question
  int? _selectedValue;
  final List<int?> _selectedValues = List<int?>.filled(5, null); // Store selected values for each question

  final List<String> _questions = [
    '이전에 당신을 위험에 빠뜨리는 행동을 한 적이 있습니까?',
    '당신 자신을 정말 해칠 방법에 대해 지금도 생각을 하고 있습니까?',
    '생각하는 것과 생각을 행동에 옮기는 것은 큰 차이가 있습니다. 앞으로 한 달 내에는 어느 때라도 당신 자신을 해치거나 당신의 삶을 끝내겠다는 그 생각을 행동으로 옮길 것 같습니까?',
    '당신 자신을 해치려는 당신의 행동을 멈추게 하거나 하지 못하게 막는 것이 있습니까?',
  ];

  void _goToNextQuestion() {
    if (_selectedValue != null) {
      setState(() {
        _score += _selectedValue!;
        _selectedValues[_currentQuestionIndex] = _selectedValue;

        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
          _selectedValue = _selectedValues[_currentQuestionIndex]; // Restore selected value for next question
        } else {
          // 결과 판단 로직 추가
          String riskLevel = _determineRiskLevel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(score: _score, riskLevel: riskLevel),
            ),
          );
        }
      });
    }
  }

  String _determineRiskLevel() {
    // 조건에 따라 자살 위험도를 판단합니다.
    if (_selectedValues.every((value) => value == 0)) {
      return '자살 거의 없음';
    }
    if ((_selectedValues[0] == 1 || _selectedValues[1] == 1) && _selectedValues[2] == 0 && _selectedValues[3] == 0) {
      return '자살 위험성 낮음';
    }
    if (_selectedValues[2] == 1 || _selectedValues[3] == 1) {
      return '자살 위험도 높음';
    }
    return '자살 위험성 낮음';
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _score -= _selectedValues[_currentQuestionIndex] ?? 0; // Subtract the score of the current question
        _selectedValues[_currentQuestionIndex] = null; // Reset the selected value for the current question
        _currentQuestionIndex--;
        _selectedValue = _selectedValues[_currentQuestionIndex]; // Restore selected value for previous question
      });
    }
  }

  void _resetScore() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _selectedValue = null;
      _selectedValues.fillRange(0, _selectedValues.length, null); // Reset all selected values
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        _resetScore();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('CHA 앱'),
          actions: [
            IconButton(
              icon: Image.asset('assets/profile.png'),
              onPressed: () {},
            ),
          ],
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
              SizedBox(
                child: Text(
                  _questions[_currentQuestionIndex],
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTextWithRadio('아니요', 0),
              SizedBox(height: 20),
              _buildTextWithRadio('예', 1),
              SizedBox(height: 25),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.3, // 30% of the screen width
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // 네모 모양
                            ),
                          ),
                        ),
                        onPressed: _goToPreviousQuestion,
                        child: Text(
                          '이전',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white, // 글씨 색상 흰색으로 변경
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.3, // 30% of the screen width
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // 네모 모양
                            ),
                          ),
                        ),
                        onPressed: _goToNextQuestion,
                        child: Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white, // 글씨 색상 흰색으로 변경
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                '${_currentQuestionIndex + 1}/${_questions.length} 페이지',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextWithRadio(String text, int value) {
    bool isSelected = _selectedValue == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedValue = value;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: _selectedValue,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedValue = newValue;
                });
              },
              activeColor: isSelected ? Colors.blue : Colors.black,
            ),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
