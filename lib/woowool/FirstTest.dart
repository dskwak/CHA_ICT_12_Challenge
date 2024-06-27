import 'package:flutter/material.dart';
import 'package:backend/woowool/resultPage.dart'; // 결과 페이지 import
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
  final List<int?> _selectedValues = List<int?>.filled(9, null); // Store selected values for each question

  final List<String> _questions = [
    '일 또는 여가 활동을 하는데 흥미나 즐거움을 느끼지 못함',
    '기분이 가라앉거나.우울하거나.희망이 없음',
    '피곤하다고 느끼거나 기운이 거의 없음',
    '잠이 들거나 계속 잠을 자는 것이 어려움. 또는 잠을 너무 많이 잠',
    '입맛이 없거나 과식을 함',
    '자신을 부정적으로 봄 – 혹은 자신이 실패자라고 느끼거나 자신 또는 가족을 실망시킴',
    '신문을 읽거나 텔레비전 보는 것과 같은 일에 집중하는 것이 어려움',
    '다른 사람들이 주목할 정도로 너무 느리게 움직이거나 말을 함 또는 반대로 평상시보다 많이 움직여서, 너무 안절부절 못하거나 들떠 있음',
    '자신이 죽는 것이 더 낫다고 생각하거나 어떤 식으로든 자신을 해칠것이라고 생각함',
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
              _buildTextWithRadio('7일 이상 방해 받았다', 2),
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
