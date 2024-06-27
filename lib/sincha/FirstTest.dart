import 'package:flutter/material.dart';
import 'package:backend/sincha/resultPage.dart'; // 결과 페이지 import
import 'package:backend/goout.dart';

class FirstTest extends StatefulWidget {
  const FirstTest({Key? key}) : super(key: key);

  @override
  _FirstTestState createState() => _FirstTestState();
}

class _FirstTestState extends State<FirstTest> {
  int _score = 0; // Variable to store the score
  int _Tscore = 0;
  int _currentQuestionIndex = 0; // Index to keep track of the current question
  int? _selectedValue;
  final List<int?> _selectedValues = List<int?>.filled(15, null); // Store selected values for each question

  final List<String> _questions = [
    '위통',
    '허리통증',
    '팔,다리,관절(무릎,고관절 등)의 통증',
    '생리기간 동안 생리통 등의문제(여성만 해당)',
    '두통',
    '가슴,흉통',
    '어지러움',
    '기절할 것 같음',
    '심장이 빨리 뜀',
    '숨이 참',
    '성교 중 통증 등의 문제',
    '변비,묽은 변이나 설사',
    '메슥거림,방귀,소화불량',
    '피로감,기운없음',
    '수면의 어려움',
  ];

  void _goToNextQuestion() {
    if (_selectedValue != null) {
      setState(() {
        _score += _selectedValue!;
        _Tscore = _selectedValue!;
        _selectedValues[_currentQuestionIndex] = _selectedValue;
        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
          _selectedValue = _selectedValues[_currentQuestionIndex]; // Restore selected value for next question
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(score: _score),
            ),
          );
        }
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _score -= _Tscore; // Subtract the score of the current question
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
              _buildTextWithRadio('전혀 시달리지 않음', 0),
              SizedBox(height: 20),
              _buildTextWithRadio('약간 시달림', 1),
              SizedBox(height: 25),
              _buildTextWithRadio('대단히 시달림', 2),
              SizedBox(height: 25),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.3, // 30% of the screen width
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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
