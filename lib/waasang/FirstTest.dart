import 'package:flutter/material.dart';
import 'package:backend/waasang/resultpage.dart'; // 결과 페이지 import
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
  final List<int?> _selectedValues = List<int?>.filled(5, null); // Store selected values for each question

  final List<String> _questions = [
    '그 경험에 관한 악몽을 꾸거나, 생각하고 싶지 않은데도 그 경험이 떠오른 적이 있었다.',
    '그 경험에 대해 생각하지 않으려고 애쓰거나, 그 경험을 떠오르게 하는 상황을 피하기 위해 특별히 노력하였다.',
    '늘 주변을 살피고 경계하거나, 쉽게 놀라게 되었다.',
    '다른사람, 일상활동, 또는 주변 상황에 대해 가졌던 느낌이 없어지거나, 그것에 대해 멀어진 느낌이 들었다.',
    '그 사건이나 그 사건으로 인해 생긴 문제에 대해 죄책감을 느끼거나, 자기자신이나 다른 사람에 대한 원망을 멈출 수가 없었다.',
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
