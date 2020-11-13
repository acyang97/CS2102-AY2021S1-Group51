## This file is used for generate data

import random
import csv
import math
import datetime
import os

random.seed(1)

def generate_ct_po_admin():
    with open('generate_mock/users_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        users_lst = list(csv_reader)
    users_lst = users_lst[1:]
    caretaker = random.sample(range(0, 27), 10) # range(0, 1500), 1000
    petowner = random.sample(range(0, 27), 10) # range(0, 1500), 1000
    caretaker_lst = [users_lst[idx] for idx in caretaker]
    caretaker_lst = list(map(lambda x: [x[0], random.sample(range(0, 6), 1)[0]], caretaker_lst))
    petowner_lst = [users_lst[idx] for idx in petowner]
    petowner_lst = list(map(lambda x: [x[0]], petowner_lst))
    caretaker_lst = [['username', 'rating']] + caretaker_lst
    petowner_lst = [['username']] + petowner_lst
    with open('generate_mock/ct_mock.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(caretaker_lst)
    with open('generate_mock/po_mock.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(petowner_lst)
    admin_lst = users_lst[len(users_lst)-3:len(users_lst)] # Last 3 users is admin
    admin_lst = list(map(lambda x: [x[0]], admin_lst))
    admin_lst = [['username']] + admin_lst
    with open('generate_mock/admin_mock.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(admin_lst)
    
    
generate_ct_po_admin()

def generate_transport_mode():
    transport_mode = [['transport'], ['Pet Owner Deliver'], ['Care Taker Pick Up'], ['Transfer through PCS Building']]
    with open('generate_mock/transport_mode.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(transport_mode)

generate_transport_mode()


def generate_preferred_transport():
    transport_mode = ['Pet Owner Deliver', 'Care Taker Pick Up', 'Transfer through PCS Building']
    with open('generate_mock/ct_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ct_lst = list(csv_reader)
    ct_lst = ct_lst[1:]
    preferred_transport_lst = list(map(lambda x: [x[0], transport_mode[random.sample(range(0, 3), 1)[0]]], ct_lst))
    preferred_transport_lst = [['username', 'transport']] + preferred_transport_lst
    with open('generate_mock/preferred_transport_mock.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(preferred_transport_lst)

generate_preferred_transport()

def generate_payment_mode():
    payment_mode = [['modeOfPayment'], ['Credit Card'], ['Cash']]
    with open('generate_mock/payment_mode.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(payment_mode)

generate_payment_mode()

def generate_preferred_payment():
    payment_mode = ['Credit Card', 'Cash']
    with open('generate_mock/ct_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ct_lst = list(csv_reader)
    ct_lst = ct_lst[1:]
    preferred_payment_lst = list(map(lambda x: [x[0], payment_mode[random.sample(range(0, 2), 1)[0]]], ct_lst))
    preferred_payment_lst = [['username', 'modeOfPayment']] + preferred_payment_lst
    with open('generate_mock/preferred_payment_mock.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(preferred_payment_lst)

generate_preferred_payment()

def full_time_part_time():
    with open('generate_mock/ct_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ct_lst = list(csv_reader)
    ct_lst = ct_lst[1:]
    num_ct = len(ct_lst)
    pt_ct = random.sample(range(0, num_ct), math.floor(num_ct/2))
    ft_ct = list(set(range(0, num_ct)) - set(pt_ct))
    pt_ct_lst = [ct_lst[idx] for idx in pt_ct]
    ft_ct_lst = [ct_lst[idx] for idx in ft_ct]
    pt_ct_lst = list(map(lambda x: [x[0]], pt_ct_lst))
    ft_ct_lst = list(map(lambda x: [x[0]], ft_ct_lst))
    pt_ct_lst = [['username']] + pt_ct_lst
    ft_ct_lst = [['username']] + ft_ct_lst
    with open('generate_mock/part_time_mock.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(pt_ct_lst)
    with open('generate_mock/full_time_mock.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(ft_ct_lst)

full_time_part_time()

def generate_pet_category():
    category = [['pettype'], ['Dog'], ['Cat'], ['Rabbit'], ['Hamster'], ['Fish'], ['Mice'], ['Terrapin'], ['Bird']]
    with open('generate_mock/pet_category.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(category)

generate_pet_category()

def generate_pet_owned():
    with open('generate_mock/petname_age.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        pname_age = list(csv_reader)
    pname_age = pname_age[1:]
    with open('generate_mock/po_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        po = list(csv_reader)
    po = po[1:]
    with open('generate_mock/pet_category.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        category = list(csv_reader)
    category = category[1:]
    pet_lst = list(map(lambda x: [po[random.sample(range(0, len(po)), 1)[0]][0], x[0], category[random.sample(range(0, len(category)), 1)[0]][0], x[1]], pname_age))
    pet_lst = [['owner', 'pet_name', 'category', 'age']] + pet_lst
    with open('generate_mock/pet_owned.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(pet_lst)

generate_pet_owned()

def special_care():
    s_care = [['care'], ['condition 1'], ['condition 2'], ['condition 3'], ['condition 4'], ['condition 5']]
    with open('generate_mock/special_care.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(s_care)

special_care()

def require_s_care():
    with open('generate_mock/pet_owned.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        pet_lst = list(csv_reader)
    pet_lst = pet_lst[1:]
    with open('generate_mock/special_care.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        special_care_lst = list(csv_reader)
    special_care_lst = special_care_lst[1:]
    require_lst = []
    for pet in pet_lst:
        val = random.sample(range(0, 3), 1)[0]
        if val == 0:
            continue
        idx_lst = random.sample(range(0, len(special_care_lst)), val)
        care_lst = [special_care_lst[idx][0] for idx in idx_lst]
        care_lst = list(map(lambda x: pet[:2] + [x], care_lst))
        require_lst = require_lst + care_lst
    require_lst = [['owner', 'pet_name', 'care']] + require_lst
    with open('generate_mock/require_special_care.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(require_lst)

require_s_care()

"""
def availability():
    with open('generate_mock/ct_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ct_lst = list(csv_reader)
    ct_lst = ct_lst[1:]
    date_lst = []
    reference_date = datetime.datetime.strptime('25052018', "%d%m%Y")
    for i in range(0, 545):
        date_lst.append((reference_date + datetime.timedelta(days = i)).strftime("%m/%d/%Y"))
    availability_lst = []
    for ct in ct_lst:
        lst = []
        for availability_date in date_lst:
            leave = random.sample([True, False], 1)[0]
            if leave:
                lst.append([availability_date, 0, 'TRUE', ct[0], 'FALSE'])
            else:
                pet_count = random.sample(range(0, 6), 1)[0]
                if pet_count == 5:
                    lst.append([availability_date, pet_count, 'FALSE', ct[0], 'FALSE'])
                else:
                    lst.append([availability_date, pet_count, 'FALSE', ct[0], 'TRUE'])
        availability_lst += lst
    availability_lst = [['date', 'pet_count', 'leave', 'username', 'available']] + availability_lst
    with open('generate_mock/availability.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(availability_lst)
"""

def availability():
    with open('generate_mock/ct_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ct_lst = list(csv_reader)
    ct_lst = ct_lst[1:]
    date_lst = []
    reference_date = datetime.datetime.strptime('25052018', "%d%m%Y")
    for i in range(0, 545):
        date_lst.append((reference_date + datetime.timedelta(days = i)).strftime("%m/%d/%Y"))
    availability_lst = []
    for ct in ct_lst:
        lst = []
        for availability_date in date_lst:
            leave = random.sample([True, False], 1)[0]
            if leave:
                lst.append([availability_date, 0, True, ct[0], False])
            else:
                lst.append([availability_date, 0, False, ct[0], True])
        availability_lst += lst
    availability_lst = [['date', 'pet_count', 'leave', 'username', 'available']] + availability_lst
    with open('generate_mock/availability.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(availability_lst)

availability()


def pt_price_list():
    with open('generate_mock/part_time_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        pt_lst = list(csv_reader)
    pt_lst = pt_lst[1:]
    with open('generate_mock/pet_category.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        category = list(csv_reader)
    category = category[1:]
    pt_price_lst = []
    for pt_ct in pt_lst:
        num = random.sample(range(0, 3), 1)[0]
        category_idx = random.sample(range(0, len(category)), num)
        category_care = [category[idx] for idx in category_idx]
        pt_price_lst += list(map(lambda x: [x[0], pt_ct[0], random.sample([50, 55, 60, 75, 80], 1)[0]], category_care))
    pt_price_lst = [['pettype', 'username', 'price']] + pt_price_lst
    with open('generate_mock/part_time_price.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(pt_price_lst)

pt_price_list()

def ft_price_list():
    with open('generate_mock/full_time_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ft_lst = list(csv_reader)
    ft_lst = ft_lst[1:]
    with open('generate_mock/default_price.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        default_price = list(csv_reader)
    default_price = default_price[1:]
    ft_price_lst = []
    for ft_ct in ft_lst:
        num = random.sample(range(0, 3), 1)[0]
        default_price_idx = random.sample(range(0, len(default_price)), num)
        category_care = [default_price[idx] for idx in default_price_idx]
        ft_price_lst += list(map(lambda x: [ft_ct[0], x[1], x[0]], category_care))
    ft_price_lst = [['username', 'price', 'pettype']] + ft_price_lst
    with open('generate_mock/full_time_price.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(ft_price_lst)

ft_price_list()

def caretakersalary():
    year_month = [[2018, 5], [2018, 6], [2018, 7], [2018, 8], [2018, 9],
     [2018, 10], [2018, 11], [2018, 12], [2019, 1], [2019, 2],
      [2019, 3], [2019, 4], [2019, 5], [2019, 6], [2019, 7], [2019, 8], [2019, 9], [2019, 10], [2019, 11]]
    with open('generate_mock/ct_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ct_lst = list(csv_reader)
    ct_lst = ct_lst[1:]
    salary_lst = []
    for ct in ct_lst:
        salary_lst += list(map(lambda x: x + [ct[0], 0, 0, 0], year_month))
    salary_lst = [['year', 'month', 'username', 'petdays', 'earnings', 'final_salary']] + salary_lst
    with open('generate_mock/salary.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(salary_lst)

caretakersalary()



def bids_generate():
    with open('generate_mock/availability.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        availability_lst = list(csv_reader)
    new_availability = [availability_lst[0]]
    availability_lst = availability_lst[1:]
    with open('generate_mock/full_time_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ft_lst = list(csv_reader)
    ft_lst = ft_lst[1:]
    with open('generate_mock/part_time_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        pt_lst = list(csv_reader)
    pt_lst = pt_lst[1:]
    with open('generate_mock/full_time_price.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ft_price_lst = list(csv_reader)
    ft_price_lst = ft_price_lst[1:]
    with open('generate_mock/part_time_price.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        pt_price_lst = list(csv_reader)
    pt_price_lst = pt_price_lst[1:]
    with open('generate_mock/pet_owned.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        pet_owned = list(csv_reader)
    pet_owned = pet_owned[1:]
    with open('generate_mock/salary.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        salary = list(csv_reader)
    with open('generate_mock/preferred_transport_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        preferred_transport = list(csv_reader)
    preferred_transport = preferred_transport[1:]
    with open('generate_mock/preferred_payment_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        preferred_payment = list(csv_reader)
        preferred_payment = preferred_payment[1:]
    pet_care = {}
    bids_lst = []
    for day in availability_lst:
        if day[2] == 'True':
            continue
        username = day[3]
        is_full_time = len(list(filter(lambda x: x[0] == username, ft_lst)))
        transport_mode = list(filter(lambda x: x[0] == username, preferred_transport))[0][1]
        payment_mode = list(filter(lambda x: x[0] == username, preferred_payment))[0][1]
        if is_full_time == 1:
            category_care = list(filter(lambda x: x[0] == username, ft_price_lst))
            if len(category_care) == 0:
                new_availability.append(day)
                continue
            category_care = list(map(lambda x: x[2], category_care))
            pet_owned_same_category = list(filter(lambda x: x[2] in category_care, pet_owned))
            pet_day = random.sample(range(0, 5), 1)[0]
            if pet_day > len(pet_owned_same_category):
                new_availability.append(day)
                continue
            care = random.sample(pet_owned_same_category, pet_day)
            price = 0
            review_lst = ["Very good", "Can improve", "Very caring", "Still okay", "Will approach caretaker to take care of my pet again"]
            if pet_care.get(day[0]) == None:
                pet_care[day[0]] = set(list(map(lambda x: tuple(x), care)))
                for pet in care:
                    p_per_day = int(list(filter(lambda x: x[0] == username and x[2] == pet[2], ft_price_lst))[0][1])
                    price += p_per_day
                    completed = random.sample([True, False], 1)[0]
                    if completed:
                        bids_lst.append([len(bids_lst) + 1, username, pet[0], pet[1], random.sample(review_lst, 1)[0], random.sample(range(0, 5), 1)[0],
                         transport_mode, payment_mode, 'credit card', 'TRUE', day[0], day[0], p_per_day])
                    else:
                        bids_lst.append([len(bids_lst) + 1, username, pet[0], pet[1], 'NULL', random.sample(range(0, 5), 1)[0],
                         transport_mode, payment_mode, 'credit card', 'FALSE', day[0], day[0], p_per_day])
                new_availability.append([day[0], pet_day, False, username, pet_day != 5])
                year = datetime.datetime.strptime(day[0], "%m/%d/%Y").strftime("%Y")
                month = str(int(datetime.datetime.strptime(day[0], "%m/%d/%Y").strftime("%m")))
                curr = list(filter(lambda x: x[0] == year and x[1] == month and x[2] == username, salary))
                curr[0][3] = str(int(curr[0][3]) + pet_day)
                curr[0][4] = str(int(curr[0][4]) + price)
                curr[0][5] = str(int(curr[0][5]) + price)
            else:
                taken_care = pet_care[day[0]]
                not_taken_care = set(list(map(lambda x: tuple(x), care))) - taken_care
                pet_care[day[0]] = pet_care[day[0]].union(not_taken_care)
                for pet in not_taken_care:
                    p_per_day = int(list(filter(lambda x: x[0] == username and x[2] == pet[2], ft_price_lst))[0][1])
                    price += p_per_day
                    completed = random.sample([True, False], 1)[0]
                    if completed:
                        bids_lst.append([len(bids_lst) + 1, username, pet[0], pet[1], random.sample(review_lst, 1)[0], random.sample(range(0, 5), 1)[0],
                         transport_mode, payment_mode, 'credit card', 'TRUE', day[0], day[0], p_per_day])
                    else:
                        bids_lst.append([len(bids_lst) + 1, username, pet[0], pet[1], 'NULL', random.sample(range(0, 5), 1)[0],
                         transport_mode, payment_mode, 'credit card', 'FALSE', day[0], day[0], p_per_day])
                new_availability.append([day[0], len(not_taken_care), False, username, len(not_taken_care) != 5])
                year = datetime.datetime.strptime(day[0], "%m/%d/%Y").strftime("%Y")
                month = str(int(datetime.datetime.strptime(day[0], "%m/%d/%Y").strftime("%m")))
                curr = list(filter(lambda x: x[0] == year and x[1] == month and x[2] == username, salary))
                curr[0][3] = str(int(curr[0][3]) + len(not_taken_care))
                curr[0][4] = str(int(curr[0][4]) + price)
                curr[0][5] = str(int(curr[0][5]) + price)
        else:
            category_care = list(filter(lambda x: x[1] == username, pt_price_lst))
            if len(category_care) == 0:
                new_availability.append(day)
                continue
            category_care = list(map(lambda x: x[0], category_care))
            pet_owned_same_category = list(filter(lambda x: x[2] in category_care, pet_owned))
            pet_day = random.sample(range(0, 5), 1)[0]
            if pet_day > len(pet_owned_same_category):
                new_availability.append(day)
                continue
            care = random.sample(pet_owned_same_category, pet_day)
            price = 0
            review_lst = ["Very good", "Can improve", "Very caring", "Still okay", "Will approach caretaker to take care of my pet again"]
            if pet_care.get(day[0]) == None:
                pet_care[day[0]] = set(list(map(lambda x: tuple(x), care)))
                for pet in care:
                    p_per_day = int(list(filter(lambda x: x[1] == username and x[0] == pet[2], pt_price_lst))[0][2])
                    price += p_per_day
                    completed = random.sample([True, False], 1)[0]
                    if completed:
                        bids_lst.append([len(bids_lst) + 1, username, pet[0], pet[1], random.sample(review_lst, 1)[0], random.sample(range(0, 5), 1)[0],
                         'transport', 'payment', 'credit card', 'TRUE', day[0], day[0], p_per_day])
                    else:
                        bids_lst.append([len(bids_lst) + 1, username, pet[0], pet[1], 'NULL', random.sample(range(0, 5), 1)[0],
                         'transport', 'payment', 'credit card', 'FALSE', day[0], day[0], p_per_day])
                new_availability.append([day[0], pet_day, False, username, pet_day != 5])
                year = datetime.datetime.strptime(day[0], "%m/%d/%Y").strftime("%Y")
                month = str(int(datetime.datetime.strptime(day[0], "%m/%d/%Y").strftime("%m")))
                curr = list(filter(lambda x: x[0] == year and x[1] == month and x[2] == username, salary))
                curr[0][3] = str(int(curr[0][3]) + pet_day)
                curr[0][4] = str(int(curr[0][4]) + price)
                curr[0][5] = str(int(curr[0][5]) + price)
            else:
                taken_care = pet_care[day[0]]
                not_taken_care = set(list(map(lambda x: tuple(x), care))) - taken_care
                pet_care[day[0]] = pet_care[day[0]].union(not_taken_care)
                for pet in not_taken_care:
                    p_per_day = int(list(filter(lambda x: x[1] == username and x[0] == pet[2], pt_price_lst))[0][2])
                    price += p_per_day
                    completed = random.sample([True, False], 1)[0]
                    if completed:
                        bids_lst.append([len(bids_lst) + 1, username, pet[0], pet[1], random.sample(review_lst, 1)[0], random.sample(range(0, 5), 1)[0],
                         'transport', 'payment', 'credit card', 'TRUE', day[0], day[0], p_per_day])
                    else:
                        bids_lst.append([len(bids_lst) + 1, username, pet[0], pet[1], 'NULL', random.sample(range(0, 5), 1)[0],
                         'transport', 'payment', 'credit card', 'FALSE', day[0], day[0], p_per_day])
                new_availability.append([day[0], len(not_taken_care), False, username, len(not_taken_care) != 5])
                year = datetime.datetime.strptime(day[0], "%m/%d/%Y").strftime("%Y")
                month = str(int(datetime.datetime.strptime(day[0], "%m/%d/%Y").strftime("%m")))
                curr = list(filter(lambda x: x[0] == year and x[1] == month and x[2] == username, salary))
                curr[0][3] = str(int(curr[0][3]) + len(not_taken_care))
                curr[0][4] = str(int(curr[0][4]) + price)
                curr[0][5] = str(int(curr[0][5]) + price)
    bids_lst = [['bid_id', 'CTusername', 'owner', 'pet_name', 'review',
     'rating', 'mode_of_transport', 'mode_of_payment', 'credit_card',
      'completed', 'start_date', 'end_date', 'price_per_day']] + bids_lst
    with open('generate_mock/bids.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(bids_lst)
    with open('generate_mock/availability.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(new_availability)
    with open('generate_mock/salary.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(salary)

bids_generate()

def generate_ct_po_new():
    with open('generate_mock/caretaker.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        caretaker_lst = list(csv_reader)
    caretaker_lst = caretaker_lst[1:]
    with open('generate_mock/petowner.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        petowner_lst = list(csv_reader)
    petowner_lst = petowner_lst[1:]
    with open('generate_mock/users_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        users_lst = list(csv_reader)
    with open('generate_mock/ct_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        ct_lst = list(csv_reader)
    with open('generate_mock/po_mock.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        po_lst = list(csv_reader)
    users = list(map(lambda x: list(x), list(set(map(lambda x: tuple(x), caretaker_lst)).union(set(map(lambda x: tuple(x), petowner_lst))))))
    users_lst += users
    ct_lst += list(map(lambda x: [x[0], random.sample(range(0, 6), 1)[0]], caretaker_lst))
    po_lst += list(map(lambda x: [x[0]], petowner_lst))
    with open('generate_mock/combine_users.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(users_lst)
    with open('generate_mock/combine_ct.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(ct_lst)
    with open('generate_mock/combine_po.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(po_lst)

generate_ct_po_new()


def job_summary():
    year_month = [[2018, 5], [2018, 6], [2018, 7], [2018, 8], [2018, 9],
     [2018, 10], [2018, 11], [2018, 12], [2019, 1], [2019, 2],
      [2019, 3], [2019, 4], [2019, 5], [2019, 6], [2019, 7], [2019, 8], [2019, 9], [2019, 10], [2019, 11]]
    with open('generate_mock/salary.csv', newline = '') as obj:
        csv_reader = csv.reader(obj)
        salary = list(csv_reader)
    salary = salary[1:]
    job_summary_count = []
    for val in year_month:
        num = 0
        v = list(filter(lambda x: int(x[0]) == val[0] and int(x[1]) == val[1], salary))
        for summary in v:
            num += int(summary[3])
        job_summary_count.append([val[0], val[1], num])
    job_summary_count = [['year', 'month', 'job_count']] + job_summary_count
    with open('generate_mock/job_summary.csv', 'w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerows(job_summary_count)

job_summary()
        




# The following prints the number of entries
"""
num = 0
for curr in os.listdir('generate_mock'):
    with open('generate_mock/' + curr, newline = '') as obj:
        csv_reader = csv.reader(obj)
        lst = list(csv_reader)
    num += len(lst)

print(num)
"""





    
    


    


    






    






