import 'package:flutter/material.dart';
import 'package:backend/boolan/resultpage.dart'; // 결과 페이지 import
import 'package:backend/goout.dart';
class FirstTest extends StatefulWidget {
  const FirstTest({super.key});

  @override
  _FirstTestState createState() => _FirstTestState();
}

class _FirstTestState extends State<FirstTest> {
  int _score = 0; // Variable to store the score
  int _Tscore = 0;
  int _currentQuestionIndex = 0; // Index to keep track of the current question
  int? _selectedValue;
  final List<int?> _selectedValues = List<int?>.filled(7, null); // Store selected values for each question

  final List<String> _questions = [
    '초조하거나 불안하거나 조마조마하게 느낀다.',
    '걱정하는 것을 멈추거나 조절할 수가 없다.',
    '여러 가지 것들에 대해 걱정을 너무 많이 한다.',
    '편하게 있기가 어렵다.',
    '쉽게 짜증이 나거나 쉽게 성을 내게 된다.',
    '너무 안절부절못해서 가만히 있기가 힘들다.',
    '마치 끔찍한 일이 생길 것처럼 두렵게 느껴진다.',
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
              _buildTextWithRadio('전혀 방해받지 않았다', 0),
              SizedBox(height: 20),
              _buildTextWithRadio('며칠동안 방해 받았다', 1),
              SizedBox(height: 20),
              _buildTextWithRadio('2주중 절반이상 방해 받았다', 2),
              SizedBox(height: 20),
              _buildTextWithRadio('거의 매일 방해 받았다', 3),

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
