# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all
Entry.destroy_all
Category.destroy_all

rent = Category.create(name: "Rent", income: false, gift: false)
groceries = Category.create(name: "Groceries", income: false, gift: false)
salary = Category.create(name: "Salary", income: true, gift: false)
gift = Category.create(name: "Gift", income: false, gift: true)

travis = User.create(username: "travis", password: "1234", email: "travisdock@gmail.com")
justin = User.create(username: "justin", password: "1234", email: "justing@gmail.com")

travis.categories.concat [rent, groceries, salary, gift]
justin.categories.concat [rent, groceries, salary, gift]

Entry.create(user_id: travis.id, category_id: rent.id, date: DateTime.new(2018, 7, 1), amount: 900, notes: "July rent paid")
Entry.create(user_id: travis.id, category_id: rent.id, date: DateTime.new(2018, 6, 1), amount: 900, notes: "June rent paid")
Entry.create(user_id: travis.id, category_id: rent.id, date: DateTime.new(2018, 5, 1), amount: 900, notes: "May rent paid")

Entry.create(user_id: justin, category_id: rent.id, date: DateTime.new(2018, 7, 1), amount: 900, notes: "July rent paid")
Entry.create(user_id: justin, category_id: rent.id, date: DateTime.new(2018, 6, 1), amount: 900, notes: "June rent paid")
Entry.create(user_id: justin, category_id: rent.id, date: DateTime.new(2018, 5, 1), amount: 900, notes: "May rent paid")

Entry.create(user_id: travis.id, category_id: salary.id, date: DateTime.new(2018, 7, 1), amount: 1000, notes: "Bi-weekly paycheck from work")
Entry.create(user_id: travis.id, category_id: salary.id, date: DateTime.new(2018, 6, 15), amount: 1000, notes: "Bi-weekly paycheck from work")

Entry.create(user_id: travis.id, category_id: groceries.id, date: DateTime.new(2018, 7, 5), amount: 35, notes: "Groceries for the week")
Entry.create(user_id: travis.id, category_id: groceries.id, date: DateTime.new(2018, 7, 1), amount: 35, notes: "Groceries for the week")
Entry.create(user_id: travis.id, category_id: groceries.id, date: DateTime.new(2018, 7, 14), amount: 35, notes: "Groceries for the week")
