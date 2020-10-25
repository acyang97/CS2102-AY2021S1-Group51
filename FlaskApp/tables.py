from flask_table import Table, Col, LinkCol

## Not sure how to delete properly.
## Look at the deletepet route too.
class petList(Table):
    classes = ['table', 'table-bordered', 'table-striped']
    pet_name = Col('Pet Name')
    category = Col('Category')
    age = Col('Age')
    delete = LinkCol('Delete Pet', 'view.deletepet', url_kwargs=dict(pet_name='pet_name'))
    view_special_care = LinkCol('Special Care', 'view.view_special_care', url_kwargs=dict(pet_name='pet_name'))

class specialCarePet(Table):
    classes = ['table', 'table-bordered', 'table-striped']
    care = Col('Special Care')

class UserList(Table):
    classes = ['table', 'table-bordered', 'table-striped']
    username = Col('username')
