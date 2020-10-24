from flask import Blueprint, redirect, render_template, flash, url_for, request
from flask_login import current_user, login_required, login_user, UserMixin, logout_user
from flask_bootstrap import Bootstrap
from wtforms.fields import DateField

from __init__ import db, login_manager
from forms import *
from tables import *
#from models import Users

import psycopg2
import psycopg2.extras
import math

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey
from sqlalchemy import inspect

view = Blueprint("view", __name__)

class Users(db.Model):
    username = db.Column(db.String, primary_key=True)
    password = db.Column(db.String, nullable=False)
    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def get_id(self):
        return self.username


@login_manager.user_loader
def load_user(username):
    user = Users.query.filter_by(username=username).first()
    return user or current_user

##############################
# Can get away using the below 3 functions for now, but it would be better to find a better method
# to obtain what is the role of the user to restrict and give access selected pages to him
def is_user_a_petowner(current_user):
    query = "SELECT * FROM PetOwners WHERE username = '{}'".format(current_user.username)
    exists_user = db.session.execute(query).fetchone()
    if exists_user is None:
        return False
    return True

def is_user_a_caretaker(current_user):
    query = "SELECT * FROM CareTakers WHERE username = '{}'".format(current_user.username)
    exists_user = db.session.execute(query).fetchone()
    if exists_user is None:
        return False
    return True

# If false, user is a full Time
# If true, user is a part time
def is_user_a_parttime_caretaker(current_user):
    query = "SELECT * FROM PartTime WHERE username = '{}'".format(current_user.username)
    exists_user = db.session.execute(query).fetchone()
    if exists_user is None:
        return False
    return True

@view.route("/")
@view.route("/home")
def home():
    return render_template('home.html')

@view.route("/about")
def about():
    return render_template('about.html')

@view.route("/caretakers")
def caretakers():
    return render_template('available-caretakers.html')

# Page to bid for a caretaker
@view.route("/bid")
def bid():
    return render_template('bid.html')


# Will be inserted into the caretaker table
@view.route("/registration", methods=["GET", "POST"])
def registration():
    form = RegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        email = form.email.data
        password = form.password.data
        area = form.area.data
        gender = form.gender.data
        select1 = form.select1.data ## Indicate what he want to sign up as
        select2 = form.select2.data ## Indicate what he want to be ig he sign up as a care taker.
        ## do something to get if he is a pet owner or care taker
        query = "SELECT * FROM users WHERE username = '{}'".format(username)
        exists_user = db.session.execute(query).fetchone()
        if exists_user:
            form.username.errors.append("{} is already in use.".format(username))
        else:
            query = "INSERT INTO users(username, email, area, gender, password) VALUES ('{}', '{}', '{}', '{}', '{}')"\
                .format(username, email, area, gender, password)
            db.session.execute(query)
            query1 = "INSERT INTO PetOwners(username) VALUES ('{}')".format(username)
            query2 = "INSERT INTO CareTakers(username) VALUES ('{}')".format(username)
            if (select1 == '1'):
                db.session.execute(query1)
            elif (select1 == '2'):
                db.session.execute(query2)
            else:
                db.session.execute(query1)
                db.session.execute(query2)
            if (select1 != '1'):
                query3 = "INSERT INTO PartTime(username) VALUES ('{}')".format(username)
                query4 = "INSERT INTO FullTime(username) VALUES ('{}')".format(username)
                if (select2 == '1'):
                    db.session.execute(query3)
                elif (select2 == '2'):
                    db.session.execute(query4)

            ##db.session.execute(query)
            ##db.session.execute(query2)
            db.session.commit()
            ##return "You have successfully signed up as a caretaker!"
            flash("You have successfully signed up!", 'success')
            return redirect(url_for('view.home'))
    return render_template("registration.html", form=form)

@view.route("/login", methods=["GET", "POST"])
def login():
    form = LoginForm()
    if form.is_submitted():
        print("username entered:", form.username.data)
        print("password entered:", form.password.data)
    if form.validate_on_submit():
        user = Users.query.filter_by(username=form.username.data).first()
        correct_password = form.password.data == user.password
        ##user = "SELECT * FROM users WHERE username = '{}'".format(form.username.data)
        if user is None:
            flash('Username does not exist, please register for an account first if you have yet to done so.', 'Danger')
        if user and correct_password:
            # TODO: You may want to verify if password is correct
            login_user(user, remember=form.remember.data)
            next_page = request.args.get('next')
            flash("You have successfully logged in!", 'success')
            return redirect(next_page) if next_page else redirect(url_for('view.home'))
            ##return redirect("/privileged-page")
            ##flash("You have successfully logged in!", 'success')
            #return redirect(url_for('view.home'))
        else:
            flash('Wrong username or password!', 'Danger')
    return render_template("login.html", form=form)

@view.route("/logout", methods=["GET", "POST"])
def logout():
    logout_user()
    return redirect(url_for('view.home'))

@view.route("/account", methods=["GET", "POST"])
@login_required # means this route can only use when login
def account():
    return render_template("account.html")

## Need a way to find out
@view.route("/registerpet", methods=["GET", "POST"])
@login_required
def registerpet():
    form = PetRegistrationForm()
    #TO CHECK IF HE IS A PET OWNER OR NOT
    #IF HE IS NOT, WILL BE REDIRECTED TO HOME PAGE
    if is_user_a_petowner(current_user) == False:
        flash("You are not a pet owner, sign up as one first!", 'error')
        return redirect(url_for('view.home'))

    if form.validate_on_submit():
        owner = current_user.username
        pet_name = form.pet_name.data
        check_if_pet_exist = "SELECT * FROM OwnedPets WHERE pet_name = '{}' AND owner = '{}'".format(pet_name, owner)
        exist_pet = db.session.execute(check_if_pet_exist).fetchone()
        if exist_pet:
            flash('You already have a pet with the same name!', 'Danger')
            return redirect(url_for('view.registerpet'))
        category = form.category.data
        age = form.age.data
        special_care1 = form.special_care1.data
        special_care2 = form.special_care2.data
        special_care3 = form.special_care3.data
        query1 = "INSERT INTO OwnedPets(owner, pet_name, category, age) VALUES('{}', '{}', '{}','{}')"\
            .format(owner, pet_name, category, age)
        db.session.execute(query1)
        if special_care1 != "":
            special1 = "SELECT care FROM SpecialCare WHERE care = '{}'".format(special_care1)
            special11 = db.session.execute(special1).fetchone()
            if not special11:
                query2 = "INSERT INTO SpecialCare(care) VALUES('{}')"\
                    .format(special_care1)
                db.session.execute(query2)
            query3 = "INSERT INTO RequireSpecialCare(owner, pet_name, care) VALUES('{}', '{}', '{}')"\
                .format(owner, pet_name, special_care1)
            db.session.execute(query3)
        db.session.commit()
        if special_care2 != "":
            special2 = "SELECT care FROM SpecialCare WHERE care = '{}'".format(special_care2)
            special22 = db.session.execute(special2).fetchone()
            if not special22:
                query2 = "INSERT INTO SpecialCare(care) VALUES('{}')"\
                    .format(special_care2)
                db.session.execute(query2)
            query3 = "INSERT INTO RequireSpecialCare(owner, pet_name, care) VALUES('{}', '{}', '{}')"\
                .format(owner, pet_name, special_care2)
            db.session.execute(query3)
        db.session.commit()
        if special_care3 != "":
            special3 = "SELECT care FROM SpecialCare WHERE care = '{}'".format(special_care3)
            special33 = db.session.execute(special3).fetchone()
            if not special33:
                query2 = "INSERT INTO SpecialCare(care) VALUES('{}')"\
                    .format(special_care3)
                db.session.execute(query2)
            query3 = "INSERT INTO RequireSpecialCare(owner, pet_name, care) VALUES('{}', '{}', '{}')"\
                .format(owner, pet_name, special_care3)
            db.session.execute(query3)
        db.session.commit()
        flash("You have successfully register your pet!", 'success')
        return redirect(url_for('view.home'))
    return render_template("register-pet.html", form=form)

## NEED HELP WITH THIS, DK HOW TO DISPLAY A TABLE FROM A QUERY
@view.route("/petlist", methods=["POST", "GET"])
@login_required
def petlist():
    #petlist = []
    owner = current_user.username
    if is_user_a_petowner(current_user) == False:
        flash("You are not a pet owner, sign up as one first!", 'error')
        return redirect(url_for('view.home'))
    query1 = "SELECT pet_name, category, age FROM OwnedPets WHERE owner = '{}' ORDER BY pet_name, category, age".format(owner)
    petlist = db.session.execute(query1)
    petlist = list(petlist)
    table = petList(petlist)
    table.border = True
    return render_template("petlist.html", table=table)

"""Still have errors"""
#Update, 25/10: can now delete pets after clicking on 'delete' button
@view.route("/deletepet", methods=["POST", "GET"])
@login_required
def deletepet():
    pet_name = request.args.get('pet_name')
    query = "DELETE FROM OwnedPets WHERE pet_name = '{}'".format(pet_name)
    db.session.execute(query)
    db.session.commit()
    return redirect(url_for('view.petlist'))

# For now, I made it such that he will put prices for the pets he want to take care of
# To make our life easier, everytime user wanna update, he need to redo this form.
@view.route("/part-time-set-price", methods=["POST", "GET"])
@login_required
def part_time_set_price():
    if is_user_a_parttime_caretaker(current_user) == False:
        flash("Only part time care takers can set their prices", 'Danger')
        return redirect(url_for('view.home'))
    form=PartTimeSetPriceForm()
    if form.validate_on_submit():
        deleteCurrentPriceQuery = "DELETE FROM PartTimePriceList WHERE caretaker = '{}'".format(current_user.username)
        db.session.execute(deleteCurrentPriceQuery)
        Dog = form.Dog.data
        Cat = form.Cat.data
        Rabbit = form.Rabbit.data
        Hamster = form.Hamster.data
        Fish = form.Fish.data
        Mice = form.Mice.data
        Terrapin = form.Terrapin.data
        Bird = form.Bird.data
        if Dog:
            dogquery = "INSERT INTO PartTimePriceList (pettype, caretaker, price)  VALUES('{}', '{}', '{}')"\
                .format("Dog", current_user.username, Dog)
            db.session.execute(dogquery)
        if Cat:
            catquery = "INSERT INTO PartTimePriceList (pettype, caretaker, price)  VALUES('{}', '{}', '{}')"\
                .format("Cat", current_user.username, Cat)
            db.session.execute(catquery)
        if Rabbit:
            rabbitquery = "INSERT INTO PartTimePriceList (pettype, caretaker, price)  VALUES('{}', '{}', '{}')"\
                .format("Rabbit", current_user.username, Rabbit)
            db.session.execute(rabbitquery)
        if Hamster:
            hamsterquery = "INSERT INTO PartTimePriceList (pettype, caretaker, price)  VALUES('{}', '{}', '{}')"\
                .format("Hamster", current_user.username, Hamster)
            db.session.execute(hamsterquery)
        if Fish:
            fishquery = "INSERT INTO PartTimePriceList (pettype, caretaker, price)  VALUES('{}', '{}', '{}')"\
                .format("Fish", current_user.username, Fish)
            db.session.execute(fishquery)
        if Mice:
            micequery = "INSERT INTO PartTimePriceList (pettype, caretaker, price)  VALUES('{}', '{}', '{}')"\
                .format("Mice", current_user.username, Mice)
            db.session.execute(micequery)
        if Terrapin:
            terrapinquery = "INSERT INTO PartTimePriceList (pettype, caretaker, price)  VALUES('{}', '{}', '{}')"\
                .format("Terrapin", current_user.username, Terrapin)
            db.session.execute(terrapinquery)
        if Bird:
            birdquery = "INSERT INTO PartTimePriceList (pettype, caretaker, price)  VALUES('{}', '{}', '{}')"\
                .format("Bird", current_user.username, Bird)
            db.session.execute(birdquery)
        db.session.commit()
        flash("You have successfully set prices for pet types you want to take care of!", 'success')
        return redirect(url_for('view.home'))
    return render_template('part-time-set-price.html', form=form)

@view.route("/full-time-choose-petype", methods=["POST", "GET"])
@login_required
def full_time_choose_pet():
    form = FullTimeChoosePetTypeForm()
    if is_user_a_parttime_caretaker(current_user) == True:
        flash("Only part time Full Timers can access this page!", 'Danger')
        return redirect(url_for('view.home'))
    if form.validate_on_submit():
        deleteCurrentPriceQuery = "DELETE FROM FullTimePriceList WHERE caretaker = '{}'".format(current_user.username)
        db.session.execute(deleteCurrentPriceQuery)
        Dog = form.Dog.data
        Cat = form.Cat.data
        Rabbit = form.Rabbit.data
        Hamster = form.Hamster.data
        Fish = form.Fish.data
        Mice = form.Mice.data
        Terrapin = form.Terrapin.data
        Bird = form.Bird.data
        if Dog == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Dog")).fetchone()[0]
            dogquery = "INSERT INTO FullTimePriceList (caretaker, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Dog")
            db.session.execute(dogquery)
        if Cat == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Cat")).fetchone()[0]
            catquery = "INSERT INTO FullTimePriceList (caretaker, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Cat")
            db.session.execute(catquery)
        if Rabbit == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Rabbit")).fetchone()[0]
            rabbitquery = "INSERT INTO FullTimePriceList (caretaker, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Rabbit")
            db.session.execute(rabbitquery)
        if Hamster == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Hamster")).fetchone()[0]
            hamsterquery = "INSERT INTO FullTimePriceList (caretaker, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Hamster")
            db.session.execute(hamsterquery)
        if Fish == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Fish")).fetchone()[0]
            fishquery = "INSERT INTO FullTimePriceList (caretaker, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Fish")
            db.session.execute(fishquery)
        if Mice == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Mice")).fetchone()[0]
            micequery = "INSERT INTO FullTimePriceList (caretaker, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Mice")
            db.session.execute(micequery)
        if Terrapin == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Terrapin")).fetchone()[0]
            terrapinquery = "INSERT INTO FullTimePriceList (caretaker, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Terrapin")
            db.session.execute(terrapinquery)
        if Bird == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Bird")).fetchone()[0]
            birdquery = "INSERT INTO FullTimePriceList (caretaker, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Bird")
            db.session.execute(birdquery)
        db.session.commit()
        flash("You have successfully selected the pet types you want to take care of!", 'success')
        return redirect(url_for('view.home'))
    return render_template('full-time-choose-pettype.html', form=form)

# NOT COMPLETED. NEED SOMEONE WRITE THE QUERY AND IMPORT DATA TO TEST OUT
@view.route("/search-caretaker", methods=["POST", "GET"])
@login_required
def search_caretaker():
    form = SearchCareTakerForm()
    if is_user_a_petowner(current_user) == False:
        flash("You are not a pet owner, sign up as one first!", 'error')
        return redirect(url_for('view.home'))
    if form.validate_on_submit():
        return redirect(url_for('view.home'))
    return render_template('search-caretaker.html', form=form)

@view.route("/testing", methods=["POST","GET"])
@login_required
def testing():
    form = TestForm()
    if form.validate_on_submit():
        d = form.dt.data.strftime('%x')
        query = "INSERT INTO dummy (date) VALUES('{}')".format(d)
        db.session.execute(query)
        db.session.commit()

        #return form.dt.data.strftime('%x')
    return render_template('testing.html', form=form)


"""
Set a route for the care takers to set their availability dates
"""

"""
Set a route for care takers to update their availability dates
"""

"""
Set a route for the pet owners to bid for a care taker (works hand in hand with searchCaretaker route at line 379)
"""


"""
Set a route for the care takers to see their transactions
"""


"""
Set a route for the pet owners to see their transactions
"""

"""
Set a route for a user to delete his account
"""

"""
Set a route for caretakers to see their salary
"""

"""
Set the routes for the admin to see some of the summary pages
"""


##@view.route("/privileged-page", methods=["GET"])
##@login_required
##def render_privileged_page():
##    return "<h1>Hello, {}!</h1>".format(current_user.username)
