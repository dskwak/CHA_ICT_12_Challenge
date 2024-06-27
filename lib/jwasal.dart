import 'package:flutter/material.dart';
import 'package:backend/jwasal/FirstTest.dart';

class jwasal extends StatelessWidget {
  const jwasal({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CHA 앱',
          textAlign: TextAlign.center,
        ),
        titleTextStyle: TextStyle(
          fontSize: 30,
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/profile.png'),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
          child: Column(
            children: [
              Container(
                width: 1000,
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text('자살위험성 자가진단',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 1000,
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  '자살에 관한 생각과 시도 가능성에 대한 검사입니다.* 결과는 자기보고 형식으로 측정되며, 정신과적 진단을 의미하는 것은 아닙니다.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                width: 1000,
                margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                child: Text('더 정확한 진단을 원하시는 경우 전문의와 상담하십시오.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                width: 1000,
                margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                child: RichText(
                  text: TextSpan(
                    text: '본 테스트는 ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black, // 기본 텍스트 색상
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '국가트라우마 센터의 ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '자료를 참고 하였습니다.',
                        style: TextStyle(
                          color: Colors.black, // 기본 텍스트 색상
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1000,
                margin: EdgeInsets.fromLTRB(10, 30, 10, 0),
                child: RichText(
                  text: TextSpan(
                    text: '',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black, // 기본 텍스트 색상
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '당신 자신을 정말',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextSpan(
                        text: ' 해치겠다는 생각을 했던',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' 적이 있습니까?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,40,0,0),
                  child: IconButton(
                    icon: Image.asset('assets/startgunsa.png'),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> FirstTest()));
                    },
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}
