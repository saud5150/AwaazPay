from base64 import b64encode
from flask import Flask, render_template, redirect, request, url_for,jsonify
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from flask_mail import Mail,Message
from itsdangerous import URLSafeTimedSerializer
import datetime
from pytz import timezone
from encrypt import decrypt_with_AES
import time
app = Flask(__name__)

app.config['SECRET_KEY'] = '!9m@S-dThyIlW[pHQbN^'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///foo.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECURITY_PASSWORD_SALT'] = '!9m@S-dThyIlW[pHQbN^salt'

app.config['MAIL_SERVER'] = 'smtp.googlemail.com'
app.config['MAIL_USE_TLS'] = False
app.config['MAIL_USE_SSL'] = True
app.config['MAIL_PORT'] = 465
app.config['MAIL_USERNAME'] = "hbutt877877@gmail.com"
app.config['MAIL_PASSWORD'] = 'ffclpzfakzsdboxu'
app.config['MAIL_DEFAULT_SENDER'] = "hbutt877877@gmail.com"

mail = Mail(app)

db = SQLAlchemy(app)
from models import User,Transaction,BillTransaction

db.create_all()
if(User.query.filter_by(username = 'gepco').first() is None):
    db.session.add( User(username = 'gepco',email = 'gepco@gmail.com',password = generate_password_hash('12345678', method='sha256'),confirmed=True,balance=0) )
db.session.commit()

@app.route('/signin',methods = ['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    secret_key = data.get('key')
    if(decryption(secret_key)==False):
        return 'error'
    user = User.query.filter_by(username = username).first()
    if user:
        if check_password_hash(user.password, password):
            if(user.confirmed is False):
                return 'Please confirm your email first.'
            return 'account login sccuessfully'
        else:
            return "wrong username or password"
    else:
        return "wrong username or password"


@app.route('/signup', methods=['POST'])
def signup():
    try:
        data = request.get_json()
        username = data.get('username')
        # if(' ' in username):
        #     return 'error'
        email = data.get('email')
        password = data.get('password')
        secret_key = data.get('key')
        if(decryption(secret_key)==False):
            return 'error'
        if(User.query.filter_by(username=username).first()):
            return "username already exists"
        if(User.query.filter_by(email=email).first()):
            return 'email already exists'
        hashed_password = generate_password_hash(password, method='sha256')
        new_user = User(
            username = username,
            email = email,
            password = hashed_password,
            confirmed=False,
            balance=100
            )
        token = generate_confirmation_token(new_user.email)
        confirm_url = url_for('confirm_email', token=token, _external=True)
        html = render_template('activate.html', confirm_url=confirm_url)
        subject = "AwaazPay! Please confirm your email"
        send_email(new_user.email, subject, html)
        db.session.add(new_user)
        db.session.commit()
        return 'account created sccuessfully'
    except:
        return 'error occured'



@app.route('/fetchbalance', methods=['POST'])
def fetchbalance():
    try:
        data = request.get_json()
        username = data.get('username')
        secret_key = data.get('key')
        if(decryption(secret_key)==False):
            return 'error'
        user = User.query.filter_by(username=username).first()
        if(user.confirmed):
            return str(user.balance)
        return 'balance fetch failed'
    except:
        return 'balance fetch failed'



@app.route('/sendmoney', methods=['POST'])
def sendmoney():
    data = request.get_json()
    fromusername = data.get('fromusername')
    tousername = data.get('tousername')
    amount = int(data.get('amount'))
    secret_key = data.get('key')
    if(decryption(secret_key)==False):
        return 'error'
    if(amount<=0):
        return "incorrect amount"
    fromgood = False
    togood = False
    try:
        fromuser = User.query.filter_by(username=fromusername).first()
        if fromuser:
            if(fromuser.balance-amount<0):
                return "low balance"
            else:
                fromgood = True
                fromuser.balance = fromuser.balance-amount
        else:
            return 'error'
        touser = User.query.filter_by(username=tousername).first()
        if(touser):
            togood = True
            touser.balance = touser.balance+amount
        else:
            return 'error'
        if(togood and fromgood):
            transaction = Transaction(fromuser_id=fromuser.id,touser_id=touser.id,amount=amount,date=datetime.datetime.now(timezone('Asia/Karachi')))
            db.session.add(fromuser)
            db.session.add(touser)
            db.session.add(transaction)
            db.session.commit()
            return "success"
        else:
            return 'error'
    except:
        return "error"




@app.route('/paybill', methods=['POST'])
def paybill():
    try:
        data = request.get_json()
        billnumber = int(data.get('billnumber'))
        username = data.get('username')
        company='gepco'
        secret_key = data.get('key')
        if(decryption(secret_key)==False):
            return 'error'
        bill_amount = 20
        if(billnumber<10000000000000 or billnumber>=100000000000000):
            return 'bill number incorrect'
        user = User.query.filter_by(username=username).first()
        bill = User.query.filter_by(username=company).first()
        if user and bill:
            if(user.balance<bill_amount):
                return "low balance"
            else:
                billtransaction = BillTransaction(user_id=user.id,company=company,bill_type='electricity',amount=bill_amount,date=datetime.datetime.now(timezone('Asia/Karachi')))
                user.balance = user.balance-bill_amount
                bill.balance = bill.balance+bill_amount
                db.session.add(billtransaction)
                db.session.add(user)
                db.session.add(bill)
                db.session.commit()
                return "success"
        else:
            return 'error'
    except:
        return 'error'

@app.route('/transactionhistory', methods=['POST'])
def transactionhistory():
    try:
        data = request.get_json()
        username = data.get('username')
        company='gepco'
        secret_key = data.get('key')
        if(decryption(secret_key)==False):
            return 'error'
        user = User.query.filter_by(username=username).first()
        bill = User.query.filter_by(username=company).first()
        return_data = []
        if user and bill:
            all_transactions = []
            negative_transactions = Transaction.query.filter_by(fromuser_id=user.id).all()
            positive_transactions = Transaction.query.filter_by(touser_id=user.id).all()
            bill_transactions = BillTransaction.query.filter_by(user_id=user.id).all()
            for i in negative_transactions:
                all_transactions.append(i)
            for i in positive_transactions:
                all_transactions.append(i)
            for i in bill_transactions:
                all_transactions.append(i)
            for i in all_transactions:
                temp_date = i.date.strftime("%b %d %Y %H:%M:%S")
                if(type(i) is Transaction):
                    if(i.fromuser_id==user.id):
                        temp_username = User.query.filter_by(id=i.touser_id).first()
                        temp_amount = '-'+str(i.amount)
                    elif(i.touser_id==user.id):
                        temp_username = User.query.filter_by(id=i.fromuser_id).first()
                        temp_amount = '+'+str(i.amount)
                    else:
                        temp_amount = 'unavailable'
                    temp_type = 'Transaction'
                elif(type(i) is BillTransaction):
                    temp_username = User.query.filter_by(username=company).first()
                    if(i.user_id==user.id):
                        temp_amount = '-'+str(i.amount)
                    else:
                        temp_amount = 'unavailable'
                    temp_type = 'Bill'
                else:
                    temp_amount = 'unavailable'
                    temp_type = 'unavailable'
                if(temp_username):
                    temp_username = temp_username.username
                else:
                    temp_username = 'unavailable'

                transaction_data = {'date':temp_date,'username':temp_username,'amount':temp_amount,'type':temp_type}
                return_data.append(transaction_data)
            return jsonify(return_data)
        else:
            return 'error'
    except Exception as e:
        return str(e)



@app.route('/confirm/<token>')
def confirm_email(token):
    try:
        email = confirm_token(token)
    except:
        return 'The confirmation link is invalid or has expired.'
    user = User.query.filter_by(email=email).first_or_404()
    if user.confirmed:
        return redirect(url_for('login'))
    else:
        user.confirmed = True
        db.session.add(user)
        db.session.commit()
        return 'You have confirmed your account and can login now. Thanks!'



def generate_confirmation_token(email):
    serializer = URLSafeTimedSerializer(app.config['SECRET_KEY'])
    return serializer.dumps(email, salt=app.config['SECURITY_PASSWORD_SALT'])
def confirm_token(token, expiration=3600):
    serializer = URLSafeTimedSerializer(app.config['SECRET_KEY'])
    try:
        email = serializer.loads(
            token,
            salt=app.config['SECURITY_PASSWORD_SALT'],
            max_age=expiration
        )
    except:
        return False
    return email

def send_email(to, subject, template):
    msg = Message(
        subject,
        recipients=[to],
        html=template,
        sender=app.config['MAIL_DEFAULT_SENDER']
    )
    mail.send(msg)


def decryption(secret_key):
    try:
    	secret_key = decrypt_with_AES(secret_key,"hassan","butt")
    	secret_key = int(secret_key)
    	t = int(time.time())
    	# change 30 to 10 at end of project. 30 for testing only.
    	if(t-secret_key<-10 or t-secret_key>10):
    		return False
    	else:
    		return True
    except:
        return False


if __name__ == "__main__":
    app.run()
