from app import db
from werkzeug.security import generate_password_hash, check_password_hash
import datetime
from pytz import timezone

class User(db.Model):

    __tablename__ = 'usertable'

    id = db.Column(db.Integer, primary_key=True)
    username= db.Column(db.String(100), unique=True)
    email = db.Column(db.String(100), unique=True)
    password = db.Column(db.String(256))
    confirmed = db.Column(db.Boolean, nullable=False, default=False)
    balance = db.Column(db.Integer)
    transaction_id = db.Column(db.Integer)
    def set_password(self, password):
        self.password = generate_password_hash(
            password,
            method='sha256'
        )
    def check_password(self, password):
        return check_password_hash(self.password, password)

    def __repr__(self):
        return '<User {}>'.format(self.email)


class Transaction(db.Model):

    __tablename__ = 'transactiontable'

    id = db.Column(db.Integer, primary_key=True)
    fromuser_id = db.Column(db.Integer)
    touser_id = db.Column(db.Integer)
    amount = db.Column(db.Integer)
    date = db.Column(db.DateTime, default=datetime.datetime.now(timezone('Asia/Karachi')))
class BillTransaction(db.Model):

    __tablename__ = 'billtransactiontable'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer)
    company = db.Column(db.String(100))
    bill_type = db.Column(db.String(100))
    amount = db.Column(db.Integer)
    date = db.Column(db.DateTime, default=datetime.datetime.now(timezone('Asia/Karachi')))