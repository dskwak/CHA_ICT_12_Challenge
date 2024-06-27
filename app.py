from flask import Flask, render_template
from flask_mail import Mail, Message
from flask_cors import CORS
from flask import jsonify
from flask import request
from datetime import datetime
from dateutil.relativedelta import *
import jwt
import sqlite3
import random

app = Flask(__name__)
CORS(app)

SECRET_KEY = '24407'
#ibxx vkyw cgwb vdaj
app.config['MAIL_SERVER']='smtp.gmail.com'
app.config['MAIL_PORT'] = 465
app.config['MAIL_USERNAME'] = 'cha4help@gmail.com'
app.config['MAIL_PASSWORD'] = 'ibxx vkyw cgwb vdaj'
app.config['MAIL_USE_TLS'] = False  
app.config['MAIL_USE_SSL'] = True  


mail = Mail(app)

DBroute = 'database/member.db'

def parseJWT(jwtstr):
    try:
        payload =     jwt.decode(jwtstr, SECRET_KEY, algorithms=['HS256'])
        return {
            "result" : "success",
            "username" : payload["id"],
            "role" : payload["role"]
        }
    except:
        return {
            "result" : "error",
            "ErrType" : "InValidToken"
        }
@app.route('/add', methods=["POST"])
def registMember():
    username = request.form.get('username')
    password = request.form.get('password')
    email = request.form.get('email')
    role = request.form.get('role', default="member")
    register = request.form.get('register', default="")

    conn = sqlite3.connect(DBroute)
    c = conn.cursor()

    c.execute('select * from member where username=?', (username,))
    if(not c.fetchone()):
        if(role == "admin"):
            if(parseJWT(register)["result"] == "success"):
                if(parseJWT(register)["role"] == "admin"):
                    c.execute('insert into member (username, password, email, role) values (?,?,?,?)',(username,password,email, role))
                    conn.commit()
                    c.execute('select * from member where username=?', (username, ))            
                    userID = c.fetchone()[0]
                    print(userID)
                    c.execute('insert into user_suspension (USERID, STARTDATE, ENDDATE, STOPCOUNT) values (?, 10000000, 10000000, 0)', (userID, ))
                    conn.commit()
                    
                    c.close()
                    conn.close()
                    payload = {
                        'id' : username,
                        'role' : role,
                        'exp' : datetime.today() + relativedelta(years=999)
                    }
                    return jsonify(
                        result = "success",
                        access_token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
                    )
                else:
                    
                    c.close()
                    conn.close()
                    return jsonify(
                        result = "error",
                        ErrType = "AccessDenied"
                    )
            else:
                c.close()
                conn.close()       
                return jsonify(
                    result = "error",
                    ErrType = "InValidToken"
                )
        else:
            c.execute('insert into member (username, password, email, role) values (?,?,?,?)',(username,password,email,role))
            conn.commit()
            c.execute('select * from member where username=?', (username, ))            
            userID = c.fetchone()[0]
            c.execute('insert into user_suspension (USERID, STARTDATE, ENDDATE, STOPCOUNT) values (?, 10000000, 10000000, 0)', (userID,))
            conn.commit()
            c.close()
            conn.close()
            payload = {
                'id' : username,
                'role' : role,
                'exp' : datetime.today() + relativedelta(years=999)
            }
            return jsonify(
                result = "success",
                access_token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
            )
    c.close()
    conn.close()
    return jsonify(
        result="error",
        ErrType = "UserAlreadyExists"
    )

@app.route('/login', methods=['POST'])
def login():
    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    username = request.form.get('username')
    password = request.form.get('password')
    usertype = request.form.get('type', default="")
    userTypeStr  = f"%{usertype}%"
    print(username, password, userTypeStr)
    c.execute('select * from member where username=? and password=? AND role LIKE ?',(username, password, userTypeStr))
    result = c.fetchone()
    c.close()
    conn.close()
    if(result):
        payload = {
            'id' : username,
            'role' : result[4],
            'exp' : datetime.today() + relativedelta(years=1000)
        }
        return jsonify(
            result = "success",
            access_token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
        )
    return jsonify(
            result = "error",
            ErrType = "UserNotFound"
        )
'''
@app.route('/addDummyData')
def createDummy():
    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    for i in range(50):
        c.execute('insert into board (title, writer, likes, content, writeDate, resources, type, views, report) values (?, ?, ?, ?, ?, ?, ?, 0, 0)', ('제목' + str(i), '작성자' + str(i), 0, '내용'*i, datetime.today().strftime("%Y%m%d"), '', 'normal' ))
    
    for i in range(50):
        c.execute('insert into board (title, writer, likes, content, writeDate, resources, type, views, report) values (?, ?, ?, ?, ?, ?, ?, 0, 0)', ('제목' + str(i+50), '작성자' + str(i+50), 0, '내용'*i, datetime.today().strftime("%Y%m%d"), '', 'notification' ))
    conn.commit()
    c.close()
    conn.close()
    return 
'''

'''
@app.route('/addDummyComment')
def createDummyComment():
    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c= conn.cursor()

    for i in range(50):
        c.execute('insert into comments (BoardID,writer,content, writeDate) values (103,?,?,?)', ('작성자' + str(i), '내용'*i, datetime.today().strftime("%Y%m%d")))
    c.close()
    conn.commit()
    conn.close()

'''
@app.route('/showBoard', methods=['POST'])
def showBoard():
    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    page = request.form.get('page')
    BoardType = request.form.get('type')
    Search = request.form.get('search')

    Search = f"%{Search}%"
    c.execute('select * from board where type=? and title LIKE ?', (BoardType,Search))
    result = c.fetchall()
    result = result[::-1]
    try:    
        page = int(page)
        return jsonify(result[(page-1)*10: page*10 + 1]
        )
    except:
        return jsonify(c.fetchall())
    

@app.route('/getPageSize', methods=['POST'])    
def getPageSize():
    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    BoardType = request.form.get('type')
    Search = request.form.get('search')
    print("게시판 사이즈 요청")

    Search = f"%{Search}%"
    c.execute('select * from board where type=? and title LIKE ?', (BoardType,Search))
    result = c.fetchall()
    result2 = len(result)//10
    if len(result)%10 != 0:
        result2 += 1

    print('연산결과 : ', result2)
    return jsonify(
        pageSize = result2
    )

@app.route('/addPost', methods=['POST'])
def addPost():
    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    Token = request.form.get('token')

    Title = request.form.get('title')
    Content = request.form.get('content')
    boardType = request.form.get('boardType')
    isAnonymous = request.form.get('isAnonymous')
    resources = request.form.get('resources')
    writer = ''

    payload = parseJWT(Token)

    c.execute('select * from member where username=?', (payload['username'], ))            
    userID = c.fetchone()[0]

    c.execute("select * from user_suspension where userid=? AND ? < ENDDATE", (userID, (datetime.today().strftime('%Y%m%d'))))
    
    isBan = c.fetchone()
    print(isBan)
    if(not isBan):
        if(boardType != 'vote' and boardType != 'normal'):
            if(parseJWT(Token)['result'] == 'success'):
                if(parseJWT(Token)['role'] != 'admin'):
                    return jsonify(
                        result = 'error',
                        ErrType = 'Access Denied'
                    )
            else:
                return jsonify(
                    result = 'error',
                    ErrType = 'Invalid Token'
                )

        if(isAnonymous == '익명'):
            writer = '익명'
        else:
            if(parseJWT(Token)["result"] == 'success'):
                writer = parseJWT(Token)["username"]
            else:
                return jsonify(
                    result = 'error',
                    ErrType = 'Invalid Token'
                )

        print(Title, Content, boardType, isAnonymous, writer, resources)
        c.execute('insert into board (title, content, Type, writer, resources, likes, writeDate, views, report) values (?,?,?,?,?, 0, ?, 0, 0)', (Title, Content, boardType, writer, resources, datetime.today().strftime("%Y%m%d")))
        
        
        
        c.close()
        conn.commit()
        conn.close()
        return jsonify(
            result = "success"
        )
    else:
        c.close()
        conn.commit()
        conn.close()
        return jsonify(
            result = "error"
        )

@app.route('/changeLike', methods=['POST'])
def changeLike():

    BoardID = request.form.get('boardID')
    Who = request.form.get('token')

    username = parseJWT(Who)['username']

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()
    result = ''
    c.execute('select * from LIKES where BOARDID = ? and USERNAME = ?', (BoardID, username))
    result = c.fetchall()
    if(len(result) == 0):
        c.execute('insert into LIKES (BOARDID, USERNAME) values (?, ?)', (BoardID, username))
        c.fetchall()
        c.execute('select likes from board where BOARDID= ?',(BoardID,))
        LikeCount = c.fetchone()
        print(LikeCount, 'like 늘어남')
        c.execute('update board set likes=? where BOARDID =?', (LikeCount[0]+1, BoardID))
    else:
        c.execute('delete from LIKES where BOARDID = ? and USERNAME = ?', (BoardID, username))
        c.fetchall()
        c.execute('select likes from board where BOARDID= ?',(BoardID,))
        LikeCount = c.fetchone()
        print(LikeCount, 'like 줄어듬')
        c.execute('update board set likes=? where BOARDID =?', (LikeCount[0]-1, BoardID))
    c.close()
    conn.commit()
    conn.close()
    return ''

@app.route("/getOnePost", methods=['POST'])
def getOnePost():
    BoardID = request.form.get('boardID')

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()
    c.execute('select * from board where boardID=?',(BoardID,))
    return jsonify(c.fetchOne())

@app.route('/addViews', methods=['POST'])
def addViews():
    BoardID = request.form.get('boardID')

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()
    c.execute('select views from board where boardID = ?',(BoardID,))
    tempCount = c.fetchone()
    c.execute('update board set views = ?', (tempCount[0] + 1,))
    c.close()
    conn.commit()
    conn.close()
    return ''

@app.route('/addReport', methods=['POSt'])
def addReport():
    BoardID = request.form.get('boardID')
    token = request.form.get('token')
    username = ''

    if(parseJWT(token)['result'] == 'success'):
        username = parseJWT(token)['username']

        conn = sqlite3.connect('database/member.db', check_same_thread=False)
        c = conn.cursor()

        c.execute('select * from reports where BoardID = ? AND username = ?', (BoardID, username))
        if(c.fetchone()):
            c.execute('delete from reports where BoardID = ? AND username = ?', (BoardID, username))
            c.execute('select report from board where BoardID = ?', (BoardID, ))
            nowReports = c.fetchone()[0]

            c.execute('update board set report = ? WHERE BoardID = ?', (nowReports-1, BoardID))
        else:
            c.execute('insert into reports (BoardID, username) values (?, ?)', (BoardID, username))
            c.execute('select report from board where BoardID = ?', (BoardID, ))
            nowReports = c.fetchone()[0]

            c.execute('update board set report = ? WHERE BOARDID = ?', (nowReports + 1, BoardID))

        
        c.close()
        conn.commit()
        conn.close()

        return jsonify(
            result = 'success'
        )

    else:
        return jsonify(
            result = 'error'
        )


@app.route('/getComment', methods=['POST'])
def getComment():
    BoardID = request.form.get('boardID')

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    c.execute('select * from comments where boardID=?',(BoardID,))
    return jsonify(c.fetchall()[::-1])


@app.route('/addComment', methods=['POST'])
def addComment():

    token = request.form.get('token')

    boardID = request.form.get('boardID')
    Writer = request.form.get('Writer')
    Content = request.form.get('Content')

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    username = ''

    if(parseJWT(token)['result'] == 'success'):
         username = parseJWT(token)['username']
    else:
        return jsonify(
            result = "error"
        )

    c.execute('select * from member where username = ?', (username,))
    userID = c.fetchone()[0]

    c.execute('select * from user_suspension where userID = ? AND ?  < ENDDATE', (userID, int(datetime.today().strftime('%Y%m%d'))))
    if(not c.fetchone()):
        c.execute('insert into comments (BoardID, writer, content, writeDate) values (?, ?, ?, ?)', (boardID, Writer, Content, datetime.today().strftime("%Y%m%d")))
        c.close()
        conn.commit()
        conn.close()
        return jsonify(
            result = 'success'
        )

    return jsonify(
        result = 'error'
    )


@app.route('/sendMail', methods=['POST'])
def sendMail():
    email = request.form.get('email')
    print(email)

    code = random.randint(111111, 999999)

    msg = Message(subject = 'CHA - 이메일 인증 코드',sender='cha4help@gmail.com', recipients=[email])
    msg.body = f"이메일 인증 코드 : {code}"

    mail.send(msg)

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()
    c.execute('insert into passCode (email, code) values (?, ?)', (email, code))
    c.close()
    conn.commit()
    conn.close()

    return ''

@app.route('/checkCode', methods=['POST'])
def checkCode():
    email = request.form.get('email')
    code = request.form.get('code')

    print(email, code)

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    c.execute('select * from passCode where email = ? AND code = ?', (email, code))
    if(c.fetchone()):
        c.execute('select username, password from member where email = ?', (email, ))
        result1 = c.fetchone()

        c.execute('delete from passCode where email = ?', (email, ))

        c.close()
        conn.commit()
        conn.close()

        return jsonify(
            result = 'success',
            userData = result1
        )


    c.close()
    conn.commit()
    conn.close()

    return jsonify(
        result = 'error'
    )

#For Admin Page
@app.route('/')
def hello_world():
    return render_template('index.html')

@app.route('/checkToken', methods=["POST"])
def checkToken():
    token = request.form.get('token')
    result = parseJWT(token)
    if(result['result'] == 'success'):
        return jsonify(
            result = True)
    else:
        return jsonify(
            result = False)

@app.route('/add_post')
def add_post():
    return render_template('addPost.html')

@app.route('/control_board')
def control_board():

    order_by = request.args.get('orderBy')
    search = request.args.get('keyword')

    keyword = f'%{search}%'

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    if(order_by == 'views'):
        c.execute("select * from board where title LIKE ? order by views DESC", (keyword, ))
    elif(order_by == 'laest'):
        c.execute("select * from board where title LIKE ? order by BOARDID DESC", (keyword, ))    
    elif(order_by == 'report'):
        c.execute("select * from board where title LIKE ? order by report DESC", (keyword, ))

    result = c.fetchall()



    c.close()
    conn.close()

    return render_template('control_board.html', board_data=result, keyword=keyword, orderBy = order_by)

@app.route('/login_admin')
def login_admin():
    return render_template('login.html')

@app.route('/deleteBoard', methods={"POST"})
def deleteBoard():

    try:
        conn = sqlite3.connect('database/member.db')
        c = conn.cursor()

        BoardID =request.form.get('BoardID')
        print(BoardID)

        c.execute('delete from board where BoardID= ?', (BoardID,))

        c.close()
        conn.commit()
        conn.close()
        return jsonify(
            result = True)
    except:
        return jsonify(
            result = False   )

@app.route('/addUser')
def addUser():
    return render_template('addUser.html')

@app.route('/control_user')
def control_user():

    search = request.args.get('keyword')
    keyword = f'%{search}%'

    conn = sqlite3.connect('database/member.db')
    c  = conn.cursor()
    user_data = c.execute('select member.id, member.username, member.email, user_suspension.startdate, user_suspension.enddate, user_suspension.StopCount from member LEFT JOIN user_suspension ON member.id = user_suspension.USERID where member.username LIKE ?', (keyword, )).fetchall()

    return render_template('control_user.html', userData = user_data)

@app.route('/ban_user', methods=['POST'])
def ban_user():
    userID = request.form.get('userID')
    days = request.form.get('days')

    conn = sqlite3.connect('database/member.db', check_same_thread=False)
    c = conn.cursor()

    STARTDATE = int(datetime.today().strftime("%Y%m%d"))
    ENDDATE = 0


    today = datetime.today()
    if(int(days) == 31):
        ENDDATE = (datetime(today.year, today.month, today.day) + relativedelta(months=1)).strftime('%Y%m%d')
    elif(int(days) == 99):
        ENDDATE = 99999999
    else:
        ENDDATE = (datetime(today.year, today.month, today.day) + relativedelta(days=int(days))).strftime('%Y%m%d')



    c.execute('update user_suspension set STARTDATE = ?, ENDDATE = ? where userID = ?', (STARTDATE, ENDDATE, userID))
    c.execute('select * from user_suspension where userid = ?', (userID,))
    stopcount = c.fetchone()[2]
    print("stopCount : " , stopcount)
    c.execute('update user_suspension set STOPCOUNT = ? where USERID = ?', (stopcount+1, userID) )

    c.close()
    conn.commit()
    conn.close()

    return jsonify(
        result = "success"
    )

if __name__ == '__main__':
    app.run('0.0.0.0',port=5000,debug=True)