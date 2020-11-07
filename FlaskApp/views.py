from flask import Blueprint, redirect, render_template, flash, url_for, request, session
from flask_login import current_user, login_required, login_user, UserMixin, logout_user
from flask_bootstrap import Bootstrap
from wtforms.fields import DateField

from __init__ import db, login_manager
from forms import *
from tables import *
from models import Users

import simplejson as json #"pip install simplejson"
import psycopg2
import psycopg2.extras
import math
from decimal import *
from datetime import date, timedelta
import datetime

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey
from sqlalchemy import inspect

import datetime
view = Blueprint("view", __name__)

@login_manager.user_loader
def load_user(username):
    if username is not None:
        return Users.query.filter_by(username=username).first()
        #return current_user
    else:
        return None

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

def is_user_a_parttime_caretaker(current_user):
    query = "SELECT * FROM PartTime WHERE username = '{}'".format(current_user.username)
    exists_user = db.session.execute(query).fetchone()
    if exists_user is None:
        return False
    return True

def is_user_a_fulltime_caretaker(current_user):
    query = "SELECT * FROM FullTime WHERE username = '{}'".format(current_user.username)
    exists_user = db.session.execute(query).fetchone()
    if exists_user is None:
        return False
    return True

def is_user_a_admin(current_user):
    query = "SELECT * FROM PCSAdmin WHERE username = '{}'".format(current_user.username)
    exists_user = db.session.execute(query).fetchone()
    if exists_user is None:
        return False
    return True

@view.route("/")
@view.route("/home")
def home():
    if not current_user.is_authenticated:
        return render_template('home_unauthenticated.html')
    elif current_user.is_authenticated:
        checkPO = "SELECT username from PetOwners WHERE username = '{}'".format(current_user.username)
        checkPT = "SELECT username from PartTime WHERE username = '{}'".format(current_user.username)
        checkFT = "SELECT username from FullTime WHERE username = '{}'".format(current_user.username)
        checkAdmin = "SELECT username from PCSAdmin WHERE username = '{}'".format(current_user.username)

        if db.session.execute(checkPO).first() is not None and db.session.execute(checkPT).first() is not None:
            usertype = "Pet Owner and Part Time CareTaker"
            return render_template('home_po_ptct.html', usertype=usertype)
        elif db.session.execute(checkPO).first() is not None and db.session.execute(checkFT).first() is not None:
            usertype = "Pet Owner and Full Time CareTaker"
            return render_template('home_po_ftct.html', usertype=usertype)
        elif db.session.execute(checkPO).first() is not None:
            usertype = "Pet Owner"
            return render_template('home_petowner.html', usertype=usertype)
        elif db.session.execute(checkPT).first() is not None:
            usertype = "Part Time CareTaker"
            return render_template('home_parttimect.html', usertype=usertype)
        elif db.session.execute(checkFT).first() is not None:
            usertype = "Full Time Caretaker"
            return render_template('home_fulltimect.html', usertype=usertype)
        elif db.session.execute(checkAdmin).first() is not None:
            usertype = "PCS Administrator"
            return render_template('home_admin.html', usertype=usertype)

@view.route("/about")
def about():
    return render_template('about.html')

@view.route("/caretakers")
def caretakers():
    return render_template('available-caretakers.html')

# Page to bid for a caretaker
@view.route("/bid")
def bid():
    username = request.args.get('username')
    query = "SELECT DISTINCT username, email, area, gender \
             FROM Users WHERE username = '{}'".format(username)
    selected = db.session.execute(query)
    selected = list(selected)
    table = SelectedCaretaker(selected)
    table.border = True
    return render_template('bid.html', table=table)

@view.route("/reg_poct", methods=["GET", "POST"])
def reg_poct():
    form = PetOwnerCareTakerRegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        email = form.email.data
        password = form.password.data
        area = form.area.data
        gender = form.gender.data
        select = form.select.data
        mode = form.mode_of_transport.data
        payment = form.mode_of_payment.data
        queryusername = "SELECT * FROM users WHERE username = '{}'".format(username)
        exists_user = db.session.execute(queryusername).fetchone()
        queryemail = "SELECT * FROM users WHERE email = '{}'".format(email)
        exists_email = db.session.execute(queryemail).fetchone()
        if exists_user:
            form.username.errors.append("Username {} is already taken.".format(username))
        elif exists_email:
            form.email.errors.append("Email {} is already in use.".format(email))
        else:
            query = "INSERT INTO users(username, email, area, gender, password) VALUES ('{}', '{}', '{}', '{}', '{}')"\
                .format(username, email, area, gender, password)
            db.session.execute(query)
            insertct = "INSERT INTO CareTakers(username) VALUES ('{}')".format(username)
            db.session.execute(insertct)
            insertpt = "INSERT INTO PartTime(username) VALUES ('{}')".format(username)
            insertft = "INSERT INTO FullTime(username) VALUES ('{}')".format(username)
            if (select == '1'):
                db.session.execute(insertpt)
            elif (select == '2'):
                db.session.execute(insertft)
            query2 = "INSERT INTO PetOwners(username) VALUES ('{}')".format(username)
            db.session.execute(query2)
            query5 = "INSERT INTO PreferredTransport(username, transport) VALUES ('{}', '{}')".format(username, mode)
            db.session.execute(query5)
            query6 = "INSERT INTO PreferredModeOfPayment(username, modeOfPayment) VALUES ('{}', '{}')".format(username, payment)
            db.session.execute(query6)
            ## Automatically inserted stuff into CareTakerSalary table using insert_into_salary_after_caretaker_insertion_trigger
            ## Automatically inserted stuff into CareTakerAvailability using insert_into_CareTakerAvailability_after_caretaker_insertion_trigger
            db.session.commit()
            flash("You have successfully signed up as a Pet Owner and CareTaker!", 'success')
            return redirect(url_for('view.home'))
    return render_template("reg_poct.html", form=form)

@view.route("/reg_ct", methods=["GET", "POST"])
def reg_ct():
    form = CareTakerRegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        email = form.email.data
        password = form.password.data
        area = form.area.data
        gender = form.gender.data
        select = form.select.data
        mode = form.mode_of_transport.data
        payment = form.mode_of_payment.data
        queryusername = "SELECT * FROM users WHERE username = '{}'".format(username)
        exists_user = db.session.execute(queryusername).fetchone()
        queryemail = "SELECT * FROM users WHERE email = '{}'".format(email)
        exists_email = db.session.execute(queryemail).fetchone()
        if exists_user:
            form.username.errors.append("Username {} is already taken.".format(username))
        elif exists_email:
            form.email.errors.append("Email {} is already in use.".format(email))
        else:
            query = "INSERT INTO users(username, email, area, gender, password) VALUES ('{}', '{}', '{}', '{}', '{}')"\
                .format(username, email, area, gender, password)
            db.session.execute(query)
            insertct = "INSERT INTO CareTakers(username) VALUES ('{}')".format(username)
            db.session.execute(insertct)
            insertpt = "INSERT INTO PartTime(username) VALUES ('{}')".format(username)
            insertft = "INSERT INTO FullTime(username) VALUES ('{}')".format(username)
            if (select == '1'):
                db.session.execute(insertpt)
            elif (select == '2'):
                db.session.execute(insertft)
            query5 = "INSERT INTO PreferredTransport(username, transport) VALUES ('{}', '{}')".format(username, mode)
            db.session.execute(query5)
            query6 = "INSERT INTO PreferredModeOfPayment(username, modeOfPayment) VALUES ('{}', '{}')".format(username, payment)
            db.session.execute(query6)
            ## Automatically inserted stuff into CareTakerSalary table using insert_into_salary_after_caretaker_insertion_trigger
            ## Automatically inserted stuff into CareTakerAvailability using insert_into_CareTakerAvailability_after_caretaker_insertion_trigger
            db.session.commit()
            flash("You have successfully signed up as a CareTaker!", 'success')
            return redirect(url_for('view.home'))
    return render_template("reg_ct.html", form=form)

@view.route("/reg_po", methods=["GET", "POST"])
def reg_po():
    form = PetOwnerRegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        email = form.email.data
        password = form.password.data
        area = form.area.data
        gender = form.gender.data
        queryusername = "SELECT * FROM users WHERE username = '{}'".format(username)
        exists_user = db.session.execute(queryusername).fetchone()
        queryemail = "SELECT * FROM users WHERE email = '{}'".format(email)
        exists_email = db.session.execute(queryemail).fetchone()
        if exists_user:
            form.username.errors.append("Username {} is already taken.".format(username))
        elif exists_email:
            form.email.errors.append("Email {} is already in use.".format(email))
        else:
            query1 = "INSERT INTO users(username, email, area, gender, password) VALUES ('{}', '{}', '{}', '{}', '{}')"\
                .format(username, email, area, gender, password)
            db.session.execute(query1)
            query2 = "INSERT INTO PetOwners(username) VALUES ('{}')".format(username)
            db.session.execute(query2)
            db.session.commit()
            flash("You have successfully signed up as a Pet Owner!", 'success')
            return redirect(url_for('view.home'))
    return render_template("reg_po.html", form=form)

# Will be inserted into the caretaker table
@view.route("/registration", methods=["GET", "POST"])
def registration():
    form = RegistrationForm()
    if form.validate_on_submit():
        if 'po' in request.form:
            return redirect(url_for('view.reg_po'))
        elif 'ct' in request.form:
            return redirect(url_for('view.reg_ct'))
        elif 'poct' in request.form:
            return redirect(url_for('view.reg_poct'))
    return render_template("registration.html", form=form)

""" # old registration for reference
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
        mode = form.mode_of_transport.data
        payment = form.mode_of_payment.data
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
                query5 = "INSERT INTO PreferredTransport(username, transport) VALUES ('{}', '{}')".format(username, mode)
                db.session.execute(query5)

                if payment == '1':
                    db.session.execute("INSERT INTO PreferredModeOfPayment(username, modeOfPayment) VALUES ('{}', '{}')".format(username, 'Credit Card'))
                elif payment == '2':
                    db.session.execute("INSERT INTO PreferredModeOfPayment(username, modeOfPayment) VALUES ('{}', '{}')".format(username, 'Cash'))

                ## Automatically inserted stuff into CareTakerSalary table using insert_into_salary_after_caretaker_insertion_trigger
                ## Automatically inserted stuff into CareTakerAvailability using insert_into_CareTakerAvailability_after_caretaker_insertion_trigger
            db.session.commit()
            ##return "You have successfully signed up as a caretaker!"
            flash("You have successfully signed up!", 'success')
            return redirect(url_for('view.home'))
    return render_template("registration.html", form=form)
"""

@view.route("/registration_admin", methods=["GET", "POST"])
def registration_admin():
    form = AdminRegistrationForm()
    if form.validate_on_submit():
        username = form.username.data
        email = form.email.data
        password = form.password.data
        area = form.area.data
        gender = form.gender.data
        query = "SELECT * FROM users WHERE username = '{}'".format(username)
        exists_user = db.session.execute(query).fetchone()
        if exists_user:
            form.username.errors.append("{} is already in use.".format(username))
        else:
            query = "INSERT INTO users(username, email, area, gender, password) VALUES ('{}', '{}', '{}', '{}', '{}')"\
                .format(username, email, area, gender, password)
            db.session.execute(query)
            query_insert_into_admin = "INSERT INTO PCSAdmin(username) VALUES ('{}')"\
                .format(username)
            db.session.execute(query_insert_into_admin)
            db.session.commit()
            flash("You have successfully signed up as an admin!", 'success')
            return redirect(url_for('view.home'))
    return render_template("registration_admin.html", form=form)


@view.route("/login", methods=["GET", "POST"])
def login():
    form = LoginForm()
    if form.is_submitted():
        print("username entered:", form.username.data)
        print("password entered:", form.password.data)
    if form.validate_on_submit():
        user = Users.query.filter_by(username=form.username.data).first()
        if user is not None:
            correct_password = form.password.data == user.password
            ##user = "SELECT * FROM users WHERE username = '{}'".format(form.username.data)
        if user is None:
            flash('Username does not exist, please register for an account first if you have yet to done so.', 'Danger')
        elif user and correct_password:
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

"""
Not sure how to display the special care as well
"""
@view.route("/petlist", methods=["POST", "GET"])
@login_required
def petlist():
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

@view.route("/pet_individual_history", methods=["POST","GET"])
@login_required
def pet_individual_history():
    owner = current_user.username
    pet_name = request.args.get('pet_name')
    query_history = "SELECT bid_id, ctusername, pet_name, rating, review, start_date, end_date, completed \
                        FROM Bids WHERE pet_name = '{}' AND owner = '{}' ORDER BY end_date DESC".format(pet_name, owner)
    pet_history = db.session.execute(query_history)
    pet_history = list(pet_history)
    table = PetIndividualHistory(pet_history)
    table.border = True
    return render_template("pet_individual_history.html", table=table)

@view.route("/pet-special-care", methods=["POST","GET"])
@login_required
def view_special_care():
    owner = current_user.username
    if is_user_a_petowner(current_user) == False:
        flash("You are not a pet owner, sign up as one first!", 'error')
        return redirect(url_for('view.home'))
    pet_name = request.args.get('pet_name')
    query1 = "SELECT care FROM RequireSpecialCare WHERE owner = '{}' AND pet_name = '{}'".format(owner, pet_name)
    carelist = db.session.execute(query1)
    carelist = list(carelist)
    table = specialCarePet(carelist)
    table.border = True
    return render_template("pet-special-care.html", table=table)

"""
If possible, see if can add smt like "Are you sure you want to delete" before deleting.
"""
@view.route("/deletepet", methods=["POST", "GET"])
@login_required
def deletepet():
    pet_name = request.args.get('pet_name')
    query = "DELETE FROM OwnedPets WHERE pet_name = '{}'".format(pet_name)
    db.session.execute(query)
    db.session.commit()
    return redirect(url_for('view.petlist'))

"""
Create a route to edit pet details
@view.route("/editpet", methods=["POST", "GET"])
def editpet():
"""
# For now, I made it such that he will put prices for the pets he want to take care of
# To make our life easier, everytime user wanna update, he need to redo this form.

# There is a small issue where pet owners can access this page, tried to fix it but failed, PO still can access
@view.route("/part-time-set-price", methods=["POST", "GET"])
@login_required
def part_time_set_price():
    if is_user_a_parttime_caretaker(current_user) == False:
        flash("Only part time care takers can set their prices", 'Danger')
        return redirect(url_for('view.home'))
    form=PartTimeSetPriceForm()
    if form.validate_on_submit():
        deleteCurrentPriceQuery = "DELETE FROM PartTimePriceList WHERE username = '{}'".format(current_user.username)
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
            dogquery = "INSERT INTO PartTimePriceList (pettype, username, price)  VALUES('{}', '{}', '{}')"\
                .format("Dog", current_user.username, Dog)
            db.session.execute(dogquery)
        if Cat:
            catquery = "INSERT INTO PartTimePriceList (pettype, username, price)  VALUES('{}', '{}', '{}')"\
                .format("Cat", current_user.username, Cat)
            db.session.execute(catquery)
        if Rabbit:
            rabbitquery = "INSERT INTO PartTimePriceList (pettype, username, price)  VALUES('{}', '{}', '{}')"\
                .format("Rabbit", current_user.username, Rabbit)
            db.session.execute(rabbitquery)
        if Hamster:
            hamsterquery = "INSERT INTO PartTimePriceList (pettype, username, price)  VALUES('{}', '{}', '{}')"\
                .format("Hamster", current_user.username, Hamster)
            db.session.execute(hamsterquery)
        if Fish:
            fishquery = "INSERT INTO PartTimePriceList (pettype, username, price)  VALUES('{}', '{}', '{}')"\
                .format("Fish", current_user.username, Fish)
            db.session.execute(fishquery)
        if Mice:
            micequery = "INSERT INTO PartTimePriceList (pettype, username, price)  VALUES('{}', '{}', '{}')"\
                .format("Mice", current_user.username, Mice)
            db.session.execute(micequery)
        if Terrapin:
            terrapinquery = "INSERT INTO PartTimePriceList (pettype, username, price)  VALUES('{}', '{}', '{}')"\
                .format("Terrapin", current_user.username, Terrapin)
            db.session.execute(terrapinquery)
        if Bird:
            birdquery = "INSERT INTO PartTimePriceList (pettype, username, price)  VALUES('{}', '{}', '{}')"\
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
    if is_user_a_fulltime_caretaker(current_user) == False:
        flash("Only part time Full Timers can access this page!", 'Danger')
        return redirect(url_for('view.home'))
    if form.validate_on_submit():
        deleteCurrentPriceQuery = "DELETE FROM FullTimePriceList WHERE username = '{}'".format(current_user.username)
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
            dogquery = "INSERT INTO FullTimePriceList (username, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Dog")
            db.session.execute(dogquery)
        if Cat == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Cat")).fetchone()[0]
            catquery = "INSERT INTO FullTimePriceList (username, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Cat")
            db.session.execute(catquery)
        if Rabbit == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Rabbit")).fetchone()[0]
            rabbitquery = "INSERT INTO FullTimePriceList (username, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Rabbit")
            db.session.execute(rabbitquery)
        if Hamster == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Hamster")).fetchone()[0]
            hamsterquery = "INSERT INTO FullTimePriceList (username, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Hamster")
            db.session.execute(hamsterquery)
        if Fish == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Fish")).fetchone()[0]
            fishquery = "INSERT INTO FullTimePriceList (username, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Fish")
            db.session.execute(fishquery)
        if Mice == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Mice")).fetchone()[0]
            micequery = "INSERT INTO FullTimePriceList (username, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Mice")
            db.session.execute(micequery)
        if Terrapin == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Terrapin")).fetchone()[0]
            terrapinquery = "INSERT INTO FullTimePriceList (username, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Terrapin")
            db.session.execute(terrapinquery)
        if Bird == "Yes":
            price = db.session.execute("SELECT price FROM DefaultPriceList WHERE pettype = '{}'".format("Bird")).fetchone()[0]
            birdquery = "INSERT INTO FullTimePriceList (username, price, pettype)  VALUES('{}', '{}', '{}')"\
                .format(current_user.username, price, "Bird")
            db.session.execute(birdquery)
        db.session.commit()
        flash("You have successfully selected the pet types you want to take care of!", 'success')
        return redirect(url_for('view.home'))
    return render_template('full-time-choose-pettype.html', form=form)

"""
Set a route for the care takers to set their availability dates
NOTE: Completed, automated the adding to CareTakerAvailability table such
that when a caretaker is created, will by default add every date from today to 2020-12-31 (for now, switch to 2021-12-31 in final implementation)
to the availability table and he will be available
"""
"""
Set a route for care takers to update their availability dates, meaning, for them to take leaves
"""
@view.route("/caretaker-update-availability", methods=["POST", "GET"])
@login_required
def caretaker_update_availability():
    form = UpdateAvailabilityForm()
    if is_user_a_caretaker(current_user) == False:
        flash("Only Care Takers can take leave and set their availability dates", 'Danger')
        return redirect(url_for('view.home'))

    if form.validate_on_submit():
        leaveDate = form.leaveDate.data
        try:
            query2 = "UPDATE CareTakerAvailability SET leave = true WHERE username = '{}' AND date = '{}'"\
                .format(current_user.username, leaveDate)
            db.session.execute(query2)
            db.session.commit()
            flash('You have successfully udpdated your availability', 'Success')
        except Exception:
            flash ('You cannot take leave on this day')
            db.session.rollback()
    display_query = "SELECT date, pet_count, leave, available FROM CareTakerAvailability WHERE username = '{}' ORDER BY date".format(current_user.username)
    display = db.session.execute(display_query)
    display = list(display)
    table = CareTakerAvailability(display)
    table.border = True
    return render_template("caretaker-update-availability.html" ,form=form, table=table)

"""
Workflow for bidding
1. search for a CareTaker
2. bring user to a page showing a table of available caretakers (order by rating)
    a. The page should have a link beside each caretaker to bid and bring the user to a bid page
3. At the bid page, the user will select the pet he wants the care taker to take care of
    a. Make sure pet types match
    b. Make sure that the pet is available to be taken care of during those days. (how to make sure this)
    c. Insert a row into the Bid table
    d. Update the pet count for the respecitive dates in the availability table
4. End of Bidding!

Take care finish. - Workflow
1. Care taker can click on "completed care taking" (to be implemented) on a page which shows his list of transactions
2. Update the bid to be a completed bid (means the whole taking care process has ended)
3. According to the current rating of user (before rating changes), update the salary table
    a. Add number of pet days
    b. Add earnings to the total earnings of the user
    c. Update the rating of the user after
4. End!
"""
# NOT COMPLETED. NEED SOMEONE WRITE THE QUERY AND IMPORT DATA TO TEST OUT
@view.route("/search-caretaker", methods=["POST", "GET"])
@login_required
def search_caretaker():
    form = SearchCareTakerForm()

    if is_user_a_petowner(current_user) == False:
        flash("You are not a pet owner, sign up as one first!", 'error')
        return redirect(url_for('view.home'))

    if form.validate_on_submit():
        employment = form.employment_type.data
        category = form.category.data
        rating = form.rating.data
        transport = form.transport.data
        payment = form.payment.data
        startDate = form.startDate.data
        endDate = form.endDate.data

        if endDate < startDate or startDate < datetime.date.today():
            error1 = ""
            error2 = ""
            if endDate < startDate:
                error1 = "Error submitting form: Start date cannot be later than End date!"
            if startDate < datetime.date.today():
                error2 = "Error submitting form: Start date cannot be a date before today!"
            return render_template('search-caretaker.html', form=form, error1=error1, error2=error2)
        else:
            if employment == "1": #part time
                searchquery = "SELECT DISTINCT username, gender, CASE WHEN rating >= 4.5 THEN price * 1.5 WHEN rating >=4 THEN price * 1.25 ELSE price END price, rating \
                            FROM users U \
                            NATURAL JOIN PartTimePriceList \
                            NATURAL JOIN CareTakers \
                            NATURAL JOIN PreferredTransport \
                            NATURAL JOIN PreferredModeOfPayment \
                            NATURAL JOIN CareTakerAvailability \
                            WHERE pettype = '{}' AND rating >= '{}' \
                            AND transport = '{}' AND modeofpayment = '{}' \
                            AND U.username <> '{}'\
                            AND True = ALL(SELECT available \
                            FROM CaretakerAvailability C \
                            WHERE C.username = U.username \
                            AND C.date >= '{}' \
                            AND C.date <= '{}') \
                            ".format(category, rating, transport, payment, current_user.username, startDate, endDate)
                filtered = db.session.execute(searchquery)
                filtered = list(filtered)
                table = FilteredCaretakers(filtered)
                table.border = True
            elif employment == "2":#full time
                searchquery = "SELECT DISTINCT username, gender, CASE WHEN rating >= 4.5 THEN price * 1.5 WHEN rating >=4 THEN price * 1.25 ELSE price END price, rating \
                            FROM users U\
                            NATURAL JOIN FullTimePriceList \
                            NATURAL JOIN CareTakers \
                            NATURAL JOIN PreferredTransport \
                            NATURAL JOIN PreferredModeOfPayment \
                            NATURAL JOIN CareTakerAvailability \
                            WHERE pettype = '{}' AND rating >= '{}' \
                            AND transport = '{}' AND modeofpayment = '{}' \
                            AND U.username <> '{}'\
                            AND True = ALL(SELECT available \
                            FROM CaretakerAvailability C \
                            WHERE C.username = U.username \
                            AND C.date >= '{}' \
                            AND C.date <= '{}') \
                            ".format(category, rating, transport, payment, current_user.username, startDate, endDate)

                filtered = db.session.execute(searchquery)
                filtered = list(filtered)
                table = FilteredCaretakers(filtered)
                table.border = True
            session['selectedCaretaker'] = [employment, category, rating, transport, payment, startDate.strftime('%Y-%m-%d'), endDate.strftime('%Y-%m-%d')]
            #return redirect(url_for('view.test_filtered'), table = table, tempdata = tempdata)
            return render_template("filtered-available-caretakers.html", table=table, startDate=startDate, endDate=endDate)
    return render_template('search-caretaker.html', form=form)

@view.route("/selected_filtered_caretaker_history", methods=["POST", "GET"])
@login_required
def selected_filtered_caretaker_history():
    caretaker = request.args.get('username')
    history_query = "SELECT ctusername, O.owner, O.pet_name, category, review, rating, start_date, end_date \
                        FROM Bids NATURAL JOIN OwnedPets O WHERE ctusername = '{}'".format(caretaker)
    history = db.session.execute(history_query)
    history = list(history)
    table = SelectedCareTakerIndividualHistory(history)
    table.border = True
    return render_template("selected_filtered_caretaker_history.html", table=table)

@view.route("/petowner-bids", methods=["POST", "GET"])
@login_required
def petowner_bids():
    caretaker = request.args.get('username')
    ownedpetsquery = "SELECT * FROM ownedpets WHERE owner = '{}' AND category ='{}' AND pet_name NOT IN (SELECT pet_name FROM bids where owner = '{}')".format(current_user.username, session['selectedCaretaker'][1], current_user.username)
    ownedpets = db.session.execute(ownedpetsquery)
    ownedpets = list(ownedpets)
    ownedpets = SelectPet(ownedpets)

    isParttime = "SELECT * FROM PartTime WHERE username = '{}'".format(caretaker)
    exists = db.session.execute(isParttime).fetchone()
    if exists is None:
        pricelistquery = "SELECT pettype, CASE WHEN rating >= 4.5 THEN price * 1.5 WHEN rating >=4 THEN price * 1.25 ELSE price END price FROM DefaultPriceList NATURAL JOIN Caretakers WHERE username = '{}' AND pettype='{}'".format(caretaker, session['selectedCaretaker'][1])
        prices=db.session.execute(pricelistquery)
        prices=list(prices)
        prices = PriceList(prices)
    else:
        pricelistquery = "SELECT pettype, CASE WHEN rating >= 4.5 THEN price * 1.5 WHEN rating >=4 THEN price * 1.25 ELSE price END price FROM parttimepricelist NATURAL JOIN Caretakers WHERE username='{}' AND pettype='{}'".format(caretaker, session['selectedCaretaker'][1])
        prices=db.session.execute(pricelistquery)
        prices=list(prices)
        prices = PriceList(prices)
    price_to_pay = json.dumps(Decimal(db.session.execute("SELECT CASE WHEN rating >= 4.5 THEN price * 1.5 WHEN rating >=4 THEN price * 1.25 ELSE price END price \
                                        FROM DefaultPriceList NATURAL JOIN Caretakers WHERE username = '{}' AND pettype='{}'".format(caretaker, session['selectedCaretaker'][1])).fetchone()[0]), use_decimal=True)
    session['price_to_pay'] = price_to_pay
    session['selectedCaretakerUsername'] = caretaker
    return render_template("bid.html", username=caretaker, pet_table=ownedpets, prices=prices)

"""
TODO: find the price per day and insert it inside as well.
For now i just put 0 cus quite confused.
"""
@view.route("/petowner-select-pet", methods=["POST", "GET"])
@login_required
def petowner_bid_selected():
    #[employment, category, rating, transport, payment, startDate, endDate]
    ctusername = session['selectedCaretakerUsername']
    owner = current_user.username
    pet_name = request.args.get('pet_name')
    mode_of_transport = session['selectedCaretaker'][3]
    mode_of_payment = session['selectedCaretaker'][4]
    completed = 'f'
    start_date = session['selectedCaretaker'][5]
    end_date = session['selectedCaretaker'][6]
    price = session['price_to_pay']
    bidid = db.session.execute("SELECT COUNT(*) FROM BIDS").fetchone()[0] + 1
    query = "INSERT INTO bids (bid_id, ctusername, owner, pet_name, mode_of_transport, mode_of_payment, completed, \
    start_date, end_date, price_per_day) VALUES ('{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}')". \
    format(bidid, ctusername, owner, pet_name, mode_of_transport, mode_of_payment, completed, start_date, end_date, price)

    db.session.execute(query)
    db.session.commit()

    flash('You have successfully added {}'.format(request.args.get('pet_name')), 'Success')
    return redirect(url_for('view.search_caretaker'))


@view.route("/testing", methods=["POST","GET"])
@login_required
def testing():
    form = TestForm()
    x = []
    if form.validate_on_submit():
        pet = request.form.get('animal')
        x.append(pet)
        return redirect(url_for('view.testing_output', x=x))
    return render_template('testing.html', form=form, x=x)

@view.route("/testing_output", methods=["POST","GET"])
@login_required
def testing_output():
    x=request.args.get('x', None)
    return render_template('testing_output.html',  x=x)


"""
I decided to have 3 tables for pet owners to see
1. Incomplete transactions
2. Completed but they havent gave a rating and review
3. Completed and they have already gave a rating and review
Set a route for the pet owners to see their COMPLETED transactions that they have already reviewed
"""
@view.route("/petowner_incomplete_transactions", methods=["POST", "GET"])
@login_required
def petowner_incomplete_transactions():
    owner = current_user.username
    if is_user_a_petowner(current_user) == False:
        flash("You are not a Pet Owner, sign up as one first!", 'error')
        return redirect(url_for('view.home'))

    query_for_incomplete = "SELECT B.bid_id, B.CTusername, B.pet_name, OP.category, start_date, end_date, price_per_day \
                            FROM Bids B NATURAL JOIN OwnedPets OP \
                            WHERE completed = FALSE AND B.owner = '{}' \
                            ORDER BY end_date DESC".format(owner)
    incompletelist = db.session.execute(query_for_incomplete)
    incompletelist = list(incompletelist)
    table = PetOwnerIncompleteTransactions(incompletelist)
    table.border = True


    return render_template("petowner_incomplete_transactions.html", table=table)

@view.route("/petowner_completed_transactions_without_review", methods=["POST", "GET"])
@login_required
def petowner_completed_transactions_without_review():
    owner = current_user.username
    if is_user_a_petowner(current_user) == False:
        flash("You are not a Pet Owner, sign up as one first!", 'error')
        return redirect(url_for('view.home'))

    query_for_completed = "SELECT B.bid_id, B.CTusername, B.pet_name, OP.category, review, rating, start_date, end_date, price_per_day \
                            FROM Bids B NATURAL JOIN OwnedPets OP \
                            WHERE completed = TRUE AND B.owner = '{}' AND rating IS NULL AND review IS NULL \
                            ORDER BY end_date DESC".format(owner)
    completedlist = db.session.execute(query_for_completed)
    completedlist = list(completedlist)
    table = PetOwnerCompletedTransactionsWithoutReview(completedlist)
    table.border = True
    return render_template("petowner_completed_transactions_without_review.html", table=table)

@view.route("/petowner_give_review", methods=["POST", "GET"])
@login_required
def petowner_give_review():
    bid_id = request.args.get('bid_id')
    form = PetOwnerSendReviewForm()
    if form.validate_on_submit():
        review = form.review.data
        rating = form.rating.data
        query = "UPDATE Bids SET review = '{}', rating = '{}' WHERE bid_id = '{}'".format(review, rating, bid_id)
        db.session.execute(query)
        db.session.commit()
        flash('You have successfully submitted your review!')
        return redirect(url_for('view.petowner_completed_transactions_with_review'))
    return render_template("petowner_give_review.html", form=form)


@view.route("/petowner_completed_transactions_with_review", methods=["POST", "GET"])
@login_required
def petowner_completed_transactions_with_review():
    owner = current_user.username
    if is_user_a_petowner(current_user) == False:
        flash("You are not a Pet Owner, sign up as one first!", 'error')
        return redirect(url_for('view.home'))

    query_for_completed = "SELECT B.bid_id, B.CTusername, B.pet_name, OP.category, review, rating, start_date, end_date, price_per_day \
                            FROM Bids B NATURAL JOIN OwnedPets OP \
                            WHERE completed = TRUE AND B.owner = '{}' AND rating IS NOT NULL AND review IS NOT NULL \
                            ORDER BY end_date DESC".format(owner)
    completedlist = db.session.execute(query_for_completed)
    completedlist = list(completedlist)
    table = PetOwnerCompletedTransactionsWithReview(completedlist)
    table.border = True
    return render_template("petowner_completed_transactions_with_review.html", table=table)



"""
Set a route for thE CARE TAKERS to see their COMPLETED transactions
"""
@view.route("/caretaker_completed_transactions", methods=["POST", "GET"])
@login_required
def caretaker_completed_transactions():
    caretaker = current_user.username
    if is_user_a_caretaker(current_user) == False:
        flash("You are not a CareTaker, sign up as one first!", 'error')
        return redirect(url_for('view.home'))
    query_for_completed = "SELECT B.bid_id, B.owner, B.pet_name, OP.category, review, rating, start_date, end_date, price_per_day \
                            FROM Bids B NATURAL JOIN OwnedPets OP \
                            WHERE completed = TRUE AND CTusername = '{}' \
                            ORDER BY end_date DESC".format(caretaker)
    completedlist = db.session.execute(query_for_completed)
    completedlist = list(completedlist)
    table = CareTakerCompletedTransactions(completedlist)
    table.border = True
    return render_template("caretaker_completed_transactions.html", table=table)

"""
Set a route for thE CARE TAKERS to see their INCOMPLETE/UPCOMING transactions
"""
@view.route("/caretaker_incomplete_transactions", methods=["POST", "GET"])
@login_required
def caretaker_incomplete_transactions():
    caretaker = current_user.username
    if is_user_a_caretaker(current_user) == False:
        flash("You are not a CareTaker, sign up as one first!", 'error')
        return redirect(url_for('view.home'))
    query_for_incomplete = "SELECT B.bid_id, B.owner, B.pet_name, OP.category, start_date, end_date, price_per_day \
                            FROM Bids B NATURAL JOIN OwnedPets OP \
                            WHERE completed = FALSE AND CTusername = '{}' \
                            ORDER BY start_date".format(current_user.username)
    incompletelist= db.session.execute(query_for_incomplete)
    incompletelist = list(incompletelist)
    table = CareTakerIncompleteTransactions(incompletelist)
    table.border = True
    return render_template("caretaker_incomplete_transactions.html", table=table)

@view.route("/caretaker_complete_transaction", methods=["POST", "GET"])
@login_required
def caretaker_complete_transaction():
    bid_id = request.args.get('bid_id')
    query = "UPDATE Bids SET completed = TRUE WHERE bid_id = '{}'".format(bid_id)
    db.session.execute(query)
    db.session.commit()
    return redirect(url_for('view.caretaker_completed_transactions'))

"""
Set a route for a user to delete his account
"""
@view.route("/deleteusers", methods = ["POST", "GET"])
@login_required
def delete_users():
    username = current_user.username
    logout_user()
    query = "DELETE FROM users WHERE username = '{}'".format(username)
    db.session.execute(query)
    db.session.commit()
    return redirect(url_for('view.home'))

"""
Set a route for caretakers to see their salary
"""
@view.route("/caretaker_profile", methods = ["POST", "GET"])
@login_required
def caretaker_profile():
    if is_user_a_caretaker(current_user) == False:
        flash("You are not a CareTaker, sign up as one first!", 'error')
        return redirect(url_for('view.home'))
    query = "SELECT year, month, petdays, final_salary \
        FROM CareTakerSalary C \
        WHERE C.username = '{}' \
        AND ((SELECT date_part('year', (SELECT current_timestamp)) > C.year) \
        OR ((SELECT date_part('year', (SELECT current_timestamp)) = C.year) \
        AND (SELECT date_part('month', (SELECT current_timestamp)) > C.month))) \
        ORDER BY C.year DESC, C.month DESC \
        LIMIT 10".format(current_user.username)
    salary_list = list(db.session.execute(query))
    table = Caretakersalary(salary_list)
    table.border = True
    form = searchsalaryForm()
    if form.validate_on_submit():
        search_salary_query = "SELECT year, month, petdays, final_salary \
        FROM CareTakerSalary \
        WHERE username = '{}' \
        AND year = '{}' \
        AND month = '{}'".format(current_user.username, form.year.data, form.month.data)
        search_salary = list(db.session.execute(search_salary_query))
        search_entry_table = Caretakersalary(search_salary)
        return render_template("search_salary.html", username = current_user.username, search_entry_table = search_entry_table)
    return render_template("caretaker_profile.html", username = current_user.username, salary_table = table, form = form)


"""
route for admin to go to a admin only page to see summary pages
"""
@view.route("/admin_page", methods = ["POST", "GET"])
@login_required
def admin_page():
    if is_user_a_admin(current_user) == False:
        flash("You are not an admin and not allowed to access this page!", 'error')
        return redirect(url_for('view.home'))
    return render_template('admin_page.html')

"""
Route for pet owner to view the care takers in their area
"""
@view.route("/petowner_view_caretakers_samearea", methods = ["POST", "GET"])
@login_required
def petowner_view_caretakers_samearea():
    if is_user_a_petowner(current_user) == False:
        flash("You are not a pet owner and not allowed to access this page!", 'error')
        return redirect(url_for('view.home'))
    pet_owner_area_query = "SELECT U.area \
                        FROM PetOwners P NATURAL JOIN Users U \
                        WHERE U.username = '{}'".format(current_user.username)
    pet_owner_area = db.session.execute(pet_owner_area_query).fetchone()[0]

    query = "SELECT username, rating \
                FROM caretakers NATURAL JOIN Users U NATURAL JOIN FullTime \
                WHERE area = '{}' \
                UNION \
                SELECT username, rating \
                FROM caretakers NATURAL JOIN Users U NATURAL JOIN PartTime \
                WHERE area = '{}'".format(pet_owner_area, pet_owner_area)
    fulltime_list = db.session.execute(query)
    fulltime_list = list(fulltime_list)
    table = PetOwnerViewFullTime(fulltime_list)
    table.border = True
    return render_template("petowner_view_caretakers_samearea.html", table=table)

@view.route("/caretaker_individual_history", methods = ["POST", "GET"])
@login_required
def caretaker_individual_history():
    username = request.args.get('username')
    history_query = "SELECT ctusername, B.pet_name, O.category, B.review, B.rating, B.start_date, B.end_date \
                        FROM BIDS B NATURAL JOIN OwnedPets O \
                        WHERE B.CTusername = '{}'".format(username)
    history_list = db.session.execute(history_query)
    history_list = list(history_list)
    table = CareTakerIndividualHistory(history_list)
    table.border = True
    return render_template("caretaker_individual_history.html", table=table)

"""
Set the routes for the admin to see some of the summary pages
IDEAS LIST DOWN HERE
"""
@view.route("/admin_view_pet_category_and_price_summary", methods = ["POST", "GET"])
@login_required
def admin_view_pet_category_and_price_summary():
    query = "SELECT pettype, ROUND(AVG(price), 2) AS avg_price \
            FROM (SELECT price, pettype FROM fulltimepricelist \
            UNION \
            SELECT  price, pettype \
            FROM PARTTIMEPRICELIST) AS dummy \
            GROUP BY dummy.pettype"
    summary = db.session.execute(query)
    summary = list(summary)
    table = SummaryPetCategoryAndPrice(summary)
    table.border = True
    return render_template("admin_view_pet_category_and_price_summary.html", table=table)

@view.route("/admin_view_jobs_per_month_summary", methods = ["POST", "GET"])
@login_required
def admin_view_jobs_per_month_summary():
    query = "SELECT * FROM TotalJobPerMonthSummary ORDER BY YEAR, MONTH"
    ls = db.session.execute(query)
    ls = list(ls)
    table = TotalJobPerMonthSummaryTable(ls)
    table.border = True
    return render_template("admin_view_jobs_per_month_summary.html", table=table)

@view.route("/admin_view_underperforming_caretakers", methods = ["POST", "GET"])
@login_required
def admin_view_underperforming_caretakers():
    form =  AdminViewUnderperformingCareTakerForm()
    if form.validate_on_submit():
        year = form.year.data
        month = form.month.data

        underperforming_query = "SELECT username, rating_in_month \
                    FROM (SELECT DISTINCT username, ROUND(AVG(B.rating), 2) AS rating_in_month \
                        FROM CareTakerSalary S \
                        INNER JOIN Bids B ON B.CTusername = S.username \
                        WHERE S.year = '{}' \
                            AND S.month = '{}' \
                            AND petdays < 20 AND completed = True \
                            AND (EXTRACT(YEAR FROM B.start_date) = '{}' OR EXTRACT(YEAR FROM B.end_date) = '{}') \
                            AND (EXTRACT(MONTH FROM B.start_date) = '{}' OR EXTRACT(MONTH FROM B.end_date) = '{}') \
                            GROUP BY username) AS DUMMY \
                    WHERE rating_in_month < 3.5 \
                    ORDER BY rating_in_month \
                    LIMIT 10".format(year, month, year, year, month, month)

        underperformers = db.session.execute(underperforming_query)
        underperformers = list(underperformers)
        table = UnderperformersTable(underperformers)
        table.border = True
        return render_template("admin_view_underperforming_caretakers.html", table=table, form=form)
    return render_template("admin_view_underperforming_caretakers.html", form = form)

@view.route("/admin_view_jobs_by_pet_type_summary", methods = ["POST", "GET"])
@login_required
def admin_view_jobs_by_pet_type_summary():
    query = "WITH cte(year, month, dog, cat, bird, terrapin, rabbit, hamster, fish, mice) AS ( \
        SELECT CTS.year, CTS.month, CASE WHEN dog IS NULL THEN 0 ELSE dog END dog, \
                                    CASE WHEN cat IS NULL THEN 0 ELSE cat END cat, \
                                    CASE WHEN bird IS NULL THEN 0 ELSE bird END bird, \
                                    CASE WHEN terrapin IS NULL THEN 0 ELSE terrapin END terrapin, \
                                    CASE WHEN rabbit IS NULL THEN 0 ELSE rabbit END rabbit, \
                                    CASE WHEN hamster IS NULL THEN 0 ELSE hamster END hamster, \
                                    CASE WHEN fish IS NULL THEN 0 ELSE fish END fish, \
                                    CASE WHEN mice IS NULL THEN 0 ELSE mice END mice \
        FROM CareTakerSalary CTS \
        LEFT JOIN \
        (SELECT C.year, C.month, COUNT(*) AS dog \
        FROM CareTakerSalary C RIGHT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O\
        WHERE (C.year = EXTRACT(YEAR FROM B.start_date) AND C.month = EXTRACT(MONTH FROM B.start_date)) \
        AND O.category = 'Dog' \
        GROUP BY C.year, C.month) AS dummy1 ON CTS.year = dummy1.year AND CTS.month = dummy1.month \
        LEFT JOIN \
        (SELECT C.year, C.month, COUNT(*) AS cat \
        FROM CareTakerSalary C RIGHT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
        WHERE (C.year = EXTRACT(YEAR FROM B.start_date) AND C.month = EXTRACT(MONTH FROM B.start_date)) \
        AND O.category = 'Cat' \
        GROUP BY C.year, C.month) AS dummy2 ON dummy2.year = CTS.year AND dummy2.month = CTS.month \
        LEFT JOIN \
        (SELECT C.year, C.month, COUNT(*) AS bird \
        FROM CareTakerSalary C RIGHT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
        WHERE (C.year = EXTRACT(YEAR FROM B.start_date) AND C.month = EXTRACT(MONTH FROM B.start_date)) \
        AND O.category = 'Bird' \
        GROUP BY C.year, C.month) AS dummy3 ON dummy3.year = CTS.year AND dummy3.month = CTS.month \
        LEFT JOIN \
        (SELECT C.year, C.month, COUNT(*) AS terrapin \
        FROM CareTakerSalary C RIGHT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
        WHERE (C.year = EXTRACT(YEAR FROM B.start_date) AND C.month = EXTRACT(MONTH FROM B.start_date)) \
        AND O.category = 'Terrapin' \
        GROUP BY C.year, C.month) AS dummy8 ON CTS.year = dummy8.year AND CTS.month = dummy8.month \
        LEFT JOIN \
        (SELECT C.year, C.month, COUNT(*) AS rabbit \
        FROM CareTakerSalary C RIGHT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
        WHERE (C.year = EXTRACT(YEAR FROM B.start_date) AND C.month = EXTRACT(MONTH FROM B.start_date)) \
        AND O.category = 'Rabbit' \
        GROUP BY C.year, C.month) AS dummy4 ON CTS.year = dummy4.year AND CTS.month = dummy4.month \
        LEFT JOIN \
        (SELECT C.year, C.month, COUNT(*) AS hamster \
        FROM CareTakerSalary C RIGHT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
        WHERE (C.year = EXTRACT(YEAR FROM B.start_date) AND C.month = EXTRACT(MONTH FROM B.start_date)) \
        AND O.category = 'Hamster' \
        GROUP BY C.year, C.month) AS dummy5 ON CTS.year = dummy5.year AND CTS.month = dummy5.month \
        LEFT JOIN \
        (SELECT C.year, C.month, COUNT(*) AS fish \
        FROM CareTakerSalary C RIGHT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
        WHERE (C.year = EXTRACT(YEAR FROM B.start_date) AND C.month = EXTRACT(MONTH FROM B.start_date)) \
        AND O.category = 'Fish' \
        GROUP BY C.year, C.month) AS dummy6 ON CTS.year = dummy6.year AND CTS.month = dummy6.month \
        LEFT JOIN \
        (SELECT C.year, C.month, COUNT(*) AS mice \
        FROM CareTakerSalary C RIGHT JOIN Bids B ON C.username = B.CTusername NATURAL JOIN OwnedPets O \
        WHERE (C.year = EXTRACT(YEAR FROM B.start_date) AND C.month = EXTRACT(MONTH FROM B.start_date)) \
        AND O.category = 'Mice' \
        GROUP BY C.year, C.month) AS dummy7 ON CTS.year = dummy7.year AND CTS.month = dummy7.month \
      ) \
      select year, month, dog, cat, bird, terrapin, rabbit, hamster, fish, mice, \
      (dog + cat + bird + terrapin + rabbit + hamster + fish + mice) AS total \
      FROM cte \
      ORDER BY year, month"
    summary = db.session.execute(query)
    summary = list(summary)
    table = NuumberOfJobsByPetTypeTable(summary)
    table.border = True
    return render_template("admin_view_jobs_by_pet_type_summary.html", table=table)

@view.route("/admin_view_earnings", methods = ["POST", "GET"])
@login_required
def admin_view_earnings():
    query = "WITH cte(year, month, full_time_earnings, part_time_earnings) AS ( \
      SELECT Dummy1.year, Dummy1.month, Dummy1.full_time_earnings, Dummy2.part_time_earnings \
      FROM (SELECT year, month, SUM(earnings) AS full_time_earnings \
            FROM CareTakerSalary C \
            WHERE C.username in (SELECT username FROM FullTime) \
            GROUP BY C.year, C.month) AS Dummy1 \
            NATURAL JOIN \
            (SELECT year, month, SUM(earnings) AS part_time_earnings \
            FROM CareTakerSalary C \
            WHERE C.username in (SELECT username FROM PartTime) \
            GROUP BY C.year, C.month) AS Dummy2 \
      ORDER BY year, month \
    ) \
    SELECT month, ROUND(AVG(full_time_earnings),2) AS full_time_earnings_avg, \
                  ROUND(AVG(part_time_earnings),2) AS part_time_earnings_avg, \
                  ROUND(AVG(full_time_earnings) + AVG(part_time_earnings), 2) AS total_earnings_avg \
    FROM cte \
    GROUP BY month"
    summary = db.session.execute(query)
    summary = list(summary)
    table = AdminViewEarningsSummary(summary)
    table.border = True
    return render_template("admin_view_earnings.html", table=table)



@view.route("/user_update_password", methods = ["POST", "GET"])
@login_required
def user_update_password():
    form = ChangePasswordForm()
    if form.validate_on_submit():
        old_password = form.old_password.data
        new_password = form.new_password.data
        query = "UPDATE Users SET password = '{}' WHERE username = '{}'".format(new_password, current_user.username)
        db.session.execute(query)
        db.session.commit()
    flash('Successfully changed password!', 'success')
    return render_template("update_password.html", form=form)
