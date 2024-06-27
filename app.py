from flask import Flask, render_template
from flask_mail import Mail, Message
from flask_cors import CORS
from flask import jsonify
from flask import request
from datetime import datetime
from dateutil.relativedelta import relativedelta
import json
import jwt
import sqlite3
import random
import os
app = Flask(__name__)
CORS(app)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DBroute = os.path.join(BASE_DIR, 'member.db')
SECRET_KEY = '24407'
#ibxx vkyw cgwb vdaj
app.config['MAIL_SERVER']='smtp.gmail.com'
app.config['MAIL_PORT'] = 465
app.config['MAIL_USERNAME'] = 'cha4help@gmail.com'
app.config['MAIL_PASSWORD'] = 'ibxx vkyw cgwb vdaj'
app.config['MAIL_USE_TLS'] = False
app.config['MAIL_USE_SSL'] = True


mail = Mail(app)


def parseJWT(jwtstr):
    print(jwtstr)
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
@app.route('/login', methods=['GET'])
def login():
    conn = sqlite3.connect(DBroute, check_same_thread=False)
    c = conn.cursor()

    username = request.args.get('username')
    password = request.args.get('password')

    # Debugging 출력
    print(username, password)

    # username과 password만으로 인증
    c.execute('SELECT * FROM member WHERE username=? AND password=?', (username, password))
    result = c.fetchone()
    c.close()
    conn.close()

    if result:
        payload = {
            'id': username,
            'role': result[4],
            'exp': datetime.today() + relativedelta(years=1000)
        }
        return jsonify(
            result="success",
            access_token=jwt.encode(payload, SECRET_KEY, algorithm="HS256")
        )

    return jsonify(
        result="error",
        ErrType="UserNotFound"
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
    conn = sqlite3.connect(DBroute, check_same_thread=False)
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
    conn = sqlite3.connect(DBroute, check_same_thread=False)
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
@app.route('/addWebPost', methods=['POST'])
def addWebPost():
    try:
        params = request.form

        Token = params.get('token')
        Title = params.get('title', '')
        Content = params.get('content', '')
        boardType = params.get('boardType')
        isAnonymous = params.get('isAnonymous')
        resources = params.get('resources', '[]')
        voteOpts = request.form.getlist('options[]')

        print(f"Received data: Title={Title}, Content={Content}, boardType={boardType}, isAnonymous={isAnonymous}, resources={resources}, voteOpts={voteOpts}")

        if not Title:
            return jsonify(result='error', message='Title is required')

        conn = sqlite3.connect(DBroute, check_same_thread=False)
        c = conn.cursor()

        payload = parseJWT(Token)
        print(f"Parsed JWT: {payload}")

        if payload['result'] != 'success':
            return jsonify(result='error', message='Invalid Token')

        c.execute('select * from member where username=?', (payload['username'], ))
        user = c.fetchone()

        if not user:
            return jsonify(result='error', message='User not found')

        userID = user[0]

        c.execute("select * from user_suspension where userid=? AND ? < ENDDATE", (userID, (datetime.today().strftime('%Y%m%d'))))
        isBan = c.fetchone()

        if isBan:
            return jsonify(result='error', message='User is suspended')

        if boardType not in ['normal', 'vote', 'notification', 'volunteer']:
            if payload['role'] != 'admin':
                return jsonify(result='error', message='Access Denied')

        if boardType == 'vote' and not voteOpts:
            return jsonify(result='error', message='Vote options required')

        writer = '익명' if isAnonymous == '익명' else payload['username']

        writeDate = datetime.today().strftime("%Y%m%d")

        # Convert resources to JSON string
        resources_str = json.dumps(resources)

        c.execute('insert into board (title, content, Type, writer, resources, likes, writeDate, views, report) values (?,?,?,?,?, 0, ?, 0, 0)',
                  (Title, Content, boardType, writer, resources_str, writeDate))

        c.execute('select boardID from board where title = ? AND writer = ?', (Title, writer))
        boardID2 = c.fetchone()[0]

        if boardType == 'vote':
            c.execute('insert into voteID (boardID) values (?)', (boardID2,))
            c.execute('select VOTEID from voteID where BoardID = ?', (boardID2, ))
            voteID = c.fetchone()[0]

            voteOptsList = [opt.strip() for opt in voteOpts if opt.strip()]
            for voteName in voteOptsList:
                c.execute('insert into VOTEOPTS (voteid, name, count) values (?, ?, 0)', (voteID, voteName))

        c.close()
        conn.commit()
        conn.close()
        return jsonify(result="success")
    except Exception as e:
        print(f"Error: {e}")
        return jsonify(result='error', message=str(e))

@app.route('/addPost', methods=['POST'])
def addPost():
    try:
        params = request.get_json()

        Token = params.get('token')
        Title = params.get('title', '')
        Content = params.get('content', '')
        boardType = params.get('boardType')
        isAnonymous = params.get('isAnonymous')
        resources = params.get('resources', [])
        voteOpts = params.get('options', [])

        print(f"Received data: Title={Title}, Content={Content}, boardType={boardType}, isAnonymous={isAnonymous}, resources={resources}, voteOpts={voteOpts}")

        if not Title:
            return jsonify(result='error', ErrType='TitleRequired')

        conn = sqlite3.connect(DBroute, check_same_thread=False)
        c = conn.cursor()

        payload = parseJWT(Token)
        print(f"Parsed JWT: {payload}")

        if payload['result'] != 'success':
            return jsonify(result='error', ErrType='Invalid Token')

        c.execute('select * from member where username=?', (payload['username'], ))
        user = c.fetchone()

        if not user:
            return jsonify(result='error', ErrType='UserNotFound')

        userID = user[0]

        c.execute("select * from user_suspension where userid=? AND ? < ENDDATE", (userID, (datetime.today().strftime('%Y%m%d'))))
        isBan = c.fetchone()

        if isBan:
            return jsonify(result='error', ErrType='UserSuspended')

        if boardType not in ['normal', 'vote', 'notification', 'volunteer']:
            if payload['role'] != 'admin':
                return jsonify(result='error', ErrType='Access Denied')

        if boardType == 'vote' and not voteOpts:
            return jsonify(result='error', ErrType='VoteOptionsRequired')

        writer = '익명' if isAnonymous == '익명' else payload['username']

        writeDate = datetime.today().strftime("%Y%m%d")

        # Convert resources to JSON string
        resources_str = json.dumps(resources)

        c.execute('insert into board (title, content, Type, writer, resources, likes, writeDate, views, report) values (?,?,?,?,?, 0, ?, 0, 0)',
                  (Title, Content, boardType, writer, resources_str, writeDate))

        c.execute('select boardID from board where title = ? AND writer = ?', (Title, writer))
        boardID2 = c.fetchone()[0]

        if boardType == 'vote':
            c.execute('insert into voteID (boardID) values (?)', (boardID2,))
            c.execute('select VOTEID from voteID where BoardID = ?', (boardID2, ))
            voteID = c.fetchone()[0]

            voteOptsList = [opt.strip() for opt in voteOpts if opt.strip()]
            for voteName in voteOptsList:
                c.execute('insert into VOTEOPTS (voteid, name, count) values (?, ?, 0)', (voteID, voteName))

        c.close()
        conn.commit()
        conn.close()
        return jsonify(result="success")
    except Exception as e:
        print(f"Error: {e}")
        return jsonify(result='error', message=str(e))


@app.route('/changeLike', methods=['POST'])
def changeLike():
    try:
        BoardID = request.form.get('boardID')
        Who = request.form.get('token')

        username = parseJWT(Who)['username']

        conn = sqlite3.connect(DBroute, check_same_thread=False)
        c = conn.cursor()
        result = ''

        c.execute('select * from LIKES where BOARDID = ? and USERNAME = ?', (BoardID, username))
        result = c.fetchone()
        if result is None:
            c.execute('insert into LIKES (BOARDID, USERNAME) values (?, ?)', (BoardID, username))
            c.execute('select likes from board where BOARDID= ?', (BoardID,))
            LikeCount = c.fetchone()[0]
            newLikeCount = LikeCount + 1
            c.execute('update board set likes=? where BOARDID =?', (newLikeCount, BoardID))
            conn.commit()
            response = jsonify(result='liked', likes=newLikeCount)
        else:
            c.execute('delete from LIKES where BOARDID = ? and USERNAME = ?', (BoardID, username))
            c.execute('select likes from board where BOARDID= ?', (BoardID,))
            LikeCount = c.fetchone()[0]
            newLikeCount = LikeCount - 1
            c.execute('update board set likes=? where BOARDID =?', (newLikeCount, BoardID))
            conn.commit()
            response = jsonify(result='unliked', likes=newLikeCount)

        c.close()
        conn.close()
        return response
    except Exception as e:
        return jsonify(result='error', message=str(e)), 500
@app.route("/getOnePost", methods=['POST'])
def getOnePost():
    BoardID = request.form.get('boardID')

    conn = sqlite3.connect(DBroute, check_same_thread=False)
    c = conn.cursor()
    c.execute('select * from board where boardID=?',(BoardID,))
    return jsonify(c.fetchOne())

@app.route('/addViews', methods=['POST'])  # POST 메소드로 설정
def addViews():
    BoardID = request.form.get('boardID')
    if not BoardID:
        return 'No boardID provided', 400

    conn = sqlite3.connect(DBroute, check_same_thread=False)
    c = conn.cursor()
    c.execute('SELECT views FROM board WHERE boardID = ?', (BoardID,))
    tempCount = c.fetchone()
    if tempCount:
        new_view_count = tempCount[0] + 1
        c.execute('UPDATE board SET views = ? WHERE boardID = ?', (new_view_count, BoardID))
    c.close()
    conn.commit()
    conn.close()
    return '', 204  # No content 응답


@app.route('/getVoteData', methods=['POST'])
def getVote():
    try:
        boardID = request.form.get('boardID')
        token = request.form.get('token')

        username = parseJWT(token)['username']

        conn = sqlite3.connect(DBroute, check_same_thread=False)
        c = conn.cursor()

        print(f"Fetching vote data for boardID: {boardID}, username: {username}")

        c.execute('select voteID from voteID where boardID = ?', (boardID, ))
        voteID = c.fetchone()
        if voteID is None:
            raise Exception(f"No voteID found for boardID: {boardID}")

        voteID = voteID[0]
        c.execute('select * from voteOpts where VOTEID = ?', (voteID, ))
        data = c.fetchall()
        print(f"Vote options: {data}")

        c.execute('select username, voteoptsid from voterList where VOTEID = ? AND USERNAME = ?', (voteID, username))
        voter = c.fetchone()
        voteNum = 0

        if voter:
            voteNum = voter[1]

        print(f"Voter: {voter}")
        return jsonify(
            voteData=data,
            whereVote=voteNum
        )
    except Exception as e:
        print(f"Error in getVoteData: {e}")
        return jsonify(result='error', message=str(e)), 500


@app.route("/vote", methods=['POST'])
def vote():
    voteID = request.form.get('voteID')
    token = request.form.get('token')

    USERNAME = parseJWT(token)['username']

    VOTEOPTSID = request.form.get('voteOptsID')

    conn = sqlite3.connect(DBroute, check_same_thread=False)
    c = conn.cursor()

    c.execute('insert into voterList (voteID, username, voteoptsid) values (?, ?, ?)', (voteID, USERNAME, VOTEOPTSID))
    c.execute('select count from voteOpts where VOTEOPTSID = ?', (VOTEOPTSID, ))
    count = c.fetchone()[0]

    c.execute('update voteOpts set count = ? where VoteOptsID = ?', (count +1, VOTEOPTSID))

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

        conn = sqlite3.connect(DBroute, check_same_thread=False)
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

    conn = sqlite3.connect(DBroute, check_same_thread=False)
    c = conn.cursor()

    c.execute('SELECT * FROM comments WHERE boardID=?', (BoardID,))
    comments = c.fetchall()
    if not comments:
        return jsonify(result='error', message="No comments found"), 404

    comments_list = []
    for comment in comments:
        print(f"CommentData - {comment[0]} {comment[3]} {comment[1]} {comment[2]} {comment[4]}")
        comment_dict = {
            "comment_id": comment[0],
            "board_id": comment[3],
            "writer": comment[1],
            "content": comment[2],
            "write_date": comment[4]
        }
        comments_list.append(comment_dict)

    return jsonify(result='success', comments=comments_list[::-1])


@app.route('/addComment', methods=['POST'])
def addComment():

    params = request.get_json()

    token = params['token']

    print(token)

    boardID = params['boardID']
    Writer = params['Writer']
    Content = params['Content']

    conn = sqlite3.connect(DBroute, check_same_thread=False)
    c = conn.cursor()

    username = ''

    print("addComment Data : ", token, boardID, Writer, Content);

    if(parseJWT(token)['result'] == 'success'):
         username = parseJWT(token)['username']
    else:
        print("parsing error")
        return jsonify(
            result= "error")

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

    print("suspension error")
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

    conn = sqlite3.connect(DBroute, check_same_thread=False)
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

    conn = sqlite3.connect(DBroute, check_same_thread=False)
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

    conn = sqlite3.connect(DBroute, check_same_thread=False)
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
    return render_template('login_web.html')
@app.route('/login_web', methods=['GET'])
def login_web():
    conn = sqlite3.connect(DBroute, check_same_thread=False)
    c = conn.cursor()

    username = request.args.get('username')
    password = request.args.get('password')
    usertype = request.args.get('type', "")
    userTypeStr = f"%{usertype}%"
    print(username, password, userTypeStr)
    c.execute('select * from member where username=? and password=? AND role LIKE ?',
              (username, password, userTypeStr))
    result = c.fetchone()
    c.close()
    conn.close()
    if result:
        payload = {
            'id': username,
            'role': result[4],
            'exp': datetime.today() + relativedelta(years=1000)
        }
        return jsonify(
            result="success",
            access_token=jwt.encode(payload, SECRET_KEY, algorithm="HS256")
        )
    return jsonify(
        result="error",
        ErrType="UserNotFound"
    )

@app.route('/addUser')
def addUser():
    return render_template('addUser.html')

@app.route('/control_user')
def control_user():

    search = request.args.get('keyword')
    keyword = f'%{search}%'

    conn = sqlite3.connect(DBroute)
    c  = conn.cursor()
    user_data = c.execute('select member.id, member.username, member.email, user_suspension.startdate, user_suspension.enddate, user_suspension.StopCount from member LEFT JOIN user_suspension ON member.id = user_suspension.USERID where member.username LIKE ?', (keyword, )).fetchall()

    return render_template('control_user.html', userData = user_data)

@app.route('/ban_user', methods=['POST'])
def ban_user():
    userID = request.form.get('userID')
    days = request.form.get('days')

    conn = sqlite3.connect(DBroute, check_same_thread=False)
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