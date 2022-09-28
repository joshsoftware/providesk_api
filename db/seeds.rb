# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Organization.create!([
  {
    name: "Josh Software",
    domain: ["joshsoftware.com"]
  }
])

p "Created Joshsoftware Organization"

Role.create!([
  {
    name: "employee"
  },
  {
    name: "admin"
  },
  {
    name: "super_admin"
  }
])

p "Created 3 Roles: employee, admin,super_admin "

Department.create!([
  {
    name: "TAC",
    organization_id: 1
  },
  {
    name: "HR",
    organization_id: 1
  },
  {
    name: "Finance",
    organization_id: 1
  }
])

p "Created 3 Roles: TAC, HR, Finance"

Category.create!([
  {
    name: "Loan",
    priority: 2,
    department_id: 3
  },
  {
    name: "Salary",
    priority: 1,
    department_id: 3
  },
  {
    name: "Onboarding",
    priority: 0,
    department_id: 2
  }
])

p "Created 3 Categories: Loan, Salary, Onboarding"