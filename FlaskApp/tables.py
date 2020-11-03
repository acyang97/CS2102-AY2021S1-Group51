from flask_table import Table, Col, LinkCol

## Not sure how to delete properly.
## Look at the deletepet route too.
class petList(Table):
    classes = ['table', 'table-bordered', 'table-striped', "sortable"]
    pet_name = Col('Pet Name')
    category = Col('Category')
    age = Col('Age')
    delete = LinkCol('Delete Pet', 'view.deletepet', url_kwargs=dict(pet_name='pet_name'))
    view_special_care = LinkCol('Special Care', 'view.view_special_care', url_kwargs=dict(pet_name='pet_name'))

class specialCarePet(Table):
    classes = ['table', 'table-bordered', 'table-striped']
    care = Col('Special Care')

class CareTakerAvailability(Table):
    classes = ['table', 'table-bordered', 'table-striped']
    date = Col('Date')
    pet_count = Col('Pet Count')
    leave = Col('Leave')
    available = Col('Availability')

class UserList(Table):
    classes = ['table', 'table-bordered', 'table-striped']
    username = Col('Username')

class FilteredCaretakers(Table):
    classes  = ['table', 'table-bordered', 'table-striped']
    username = Col('Caretaker Name')
    gender = Col('Gender')
    price = Col('Price ($)')
    rating = Col('Rating')
    select = LinkCol('Select', 'view.petowner_bids', url_kwargs=dict(username='username'))

class SelectedCaretaker(Table):
    classes = ['table', 'table-bordered', 'table-striped']
    username = Col('Caretaker Name')
    email = Col('Email')
    area = Col('Area')
    gender = Col('Gender')

class PriceList(Table):
    classes = ['table', 'table-bordered', 'table-striped']
    pettype = Col('Type')
    price = Col('Price')

class SelectPet(Table):
    classes = ['table', 'table-bordered', 'table-striped', "sortable"]
    pet_name = Col('Pet Name')
    category = Col('Category')
    bid = LinkCol('bid', 'view.petowner_bid_selected', url_kwargs=dict(pet_name='pet_name'))

class CareTakerCompletedTransactions(Table):
    classes = ['table', 'table-bordered', 'table-striped', "sortable"]
    bid_id = Col('Bid ID')
    owner = Col('Owner')
    pet_name = Col('Pet name')
    category = Col('Category')
    review = Col('Review')
    rating = Col('Rating')
    start_date = Col('Start Date')
    end_date = Col('End Date')
    price_per_day = Col('Price Per Day')

"""
This one only diff is dosent show review and rating cus dosnet make sense to have it when still incomplete
"""
class CareTakerIncompleteTransactions(Table):
    classes = ['table', 'table-bordered', 'table-striped', "sortable"]
    bid_id = Col('Bid ID')
    owner = Col('Owner')
    pet_name = Col('Pet name')
    category = Col('Category')
    start_date = Col('Start Date')
    end_date = Col('End Date')
    price_per_day = Col('Price Per Day')
    update = LinkCol('Transaction completed!', 'view.caretaker_complete_transaction', url_kwargs=dict(bid_id='bid_id'))
    #select = LinkCol('Select', 'view.petowner_bids', url_kwargs=dict(username='username'))


class PetOwnerIncompleteTransactions(Table):
    classes = ['table', 'table-bordered', 'table-striped', "sortable"]
    bid_id = Col('Bid ID')
    ctusername = Col('CareTaker')
    pet_name = Col('Pet name')
    category = Col('Category')
    start_date = Col('Start Date')
    end_date = Col('End Date')
    price_per_day = Col('Price Per Day')


class PetOwnerCompletedTransactionsWithReview(Table):
    classes = ['table', 'table-bordered', 'table-striped', "sortable"]
    bid_id = Col('Bid ID')
    ctusername = Col('CareTaker')
    pet_name = Col('Pet name')
    category = Col('Category')
    review = Col('Review')
    rating = Col('Rating')
    start_date = Col('Start Date')
    end_date = Col('End Date')
    price_per_day = Col('Price Per Day')

class PetOwnerCompletedTransactionsWithoutReview(Table):
    classes = ['table', 'table-bordered', 'table-striped', "sortable"]
    bid_id = Col('Bid ID')
    ctusername = Col('CareTaker')
    pet_name = Col('Pet name')
    category = Col('Category')
    review = Col('Review')
    rating = Col('Rating')
    start_date = Col('Start Date')
    end_date = Col('End Date')
    price_per_day = Col('Price Per Day')
    update = LinkCol('Give your review!', 'view.petowner_give_review', url_kwargs=dict(bid_id='bid_id'))

class Caretakersalary(Table):
    classes = ['table', 'table-bordered', 'table-striped', 'sortable']
    year = Col('Year')
    month = Col('Month')
    petdays = Col('Pet days')
    final_salary = Col('Salary received')

class SummaryPetCategoryAndPrice(Table):
    classes = ['table', 'table-bordered', 'table-striped', 'sortable']
    pettype = Col('Pet Type')
    avg_price = Col('Average price set by caretakers')

class PetOwnerViewFullTime(Table):
    classes = ['table', 'table-bordered', 'table-striped', 'sortable']
    username = Col('Care Taker Name')
    rating  = Col('Rating')
    history = LinkCol('Look at his reviews!', 'view.caretaker_individual_history', url_kwargs = dict(username='username'))


class CareTakerIndividualHistory(Table):
    classes = ['table', 'table-bordered', 'table-striped', 'sortable']
    CTusername = Col('Care Taker Name')
    pet_name = Col('Pet Name')
    category = Col('Pet Type')
    review = Col('Review')
    rating = Col('Rating')
    start_date = Col('Start Date')
    end_date = Col('End Date')
