# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Organization.create!([
  { name: "Josh Software", domain: ["joshsoftware.com"] },
  { name: "Google", domain: ["gmail.com"] },
  { name: "Accenture", domain: ["accenture.com"]},
  # { name: "Admin", domain: ["admin.com"]} #this will work for allowing admin.com domain
])

p "Created 3 organizations"

Role.create!([
  { name: "employee" },
  { name: "admin" },
  { name: "super_admin" },
  { name: "department_head" }
])

p "Created 4 Roles: employee, admin, super_admin, department_head "

Department.create!([
  { name: "TAC", organization_id: 1 },
  { name: "HR", organization_id: 1 },
  { name: "Finance", organization_id: 1 },
  { name: "Marketing", organization_id: 2 },
  { name: "Human Resource", organization_id: 2 },
  { name: "Finance", organization_id: 2 },
  { name: "Marketing", organization_id: 3 },
  { name: "Research", organization_id: 3 },
  { name: "Sales", organization_id: 3 }
])

p "Created departments for all organizations"

Category.create!([
  { name: "Recruitment", priority: 1, department_id: 1},
  { name: "Referral Program", priority: 0, department_id: 1},
  { name: "Onboarding", priority: 0, department_id: 2 },
  { name: "Compensation and Benefits", priority: 1, department_id: 2 },
  { name: "Loan", priority: 2, department_id: 3 },
  { name: "Branding and Strategy", priority: 0, department_id: 3 },
  { name: "Branding and Strategy", priority: 0, department_id: 4 },
  { name: "Content Management", priority: 0, department_id: 4 },
  { name: "Onbarding", priority: 0, department_id: 5 },
  { name: "Compensation and Benefits", priority: 0, department_id: 5 },
  { name: "Branding and Strategy", priority: 0, department_id: 6 },
  { name: "Loan", priority: 1, department_id: 6 },
  { name: "Content Marketing", priority: 0, department_id: 7 },
  { name: "Social Media", priority: 1, department_id: 7 },
  { name: "Applied Research", priority: 2, department_id: 8 },
  { name: "Casual Research", priority: 0, department_id: 8 }
])

p "Created categories for various departments"

User.create!([
  { name: "Nandini Jhanwar", email: "nandinijhanwar67@admin.com", role_id: 3},
  { name: "Sethupathi Asokan", email: "sethu@joshsoftware.com", role_id: 2 },
  { name: "Akansha Kumari", email: "akansha.kumari@joshsoftware.com", role_id: 2},
  { name: "Finance Head", email: "finance.head@joshsoftware.com", role_id: 4, department_id: 3},
  { name: "HR Head", email: "hr.head@joshsoftware.com", role_id: 4, department_id: 2},
  { name: "Srenidhi Bendre", email: "srenidhi.bendre@joshsoftware.com", role_id: 1},
  {name: "Mayur Hole", email: "mayur.hole@joshsoftware.com", role_id: 1, department_id: 3}, 
  {name: "Raghunandan Jhanwar", email: "raghunandan@joshsoftware.com", department_id: 2},
  { name: "Pratham Goel", email: "pratham.goel16@gmail.com", role_id: 2},
  { name: "Marketing Head", email: "marketing.head@gmail.com", role_id: 4, department_id: 4},
  {name: "Arpan Rathi", email: "arpan.rathi@gmail.com", role_id: 1, department_id: 5}, 
  {name: "Sonal Sachdev", email: "sonalsachdev@gmail.com", department_id: 4}, 
  {name: "Sanchi Singh", email: "sanchisingh@gmail.com", role_id: 1, department_id: 6},
  { name: "Rutuja Nirmal", email: "rutujanirmal@gmail.com", role_id: 1},
  { name: "Shefali Geel", email: "shefaligeel@accenture.com", role_id: 2},
  { name: "Reserach Head", email: "research.head@accenture.com", role_id: 4, department_id: 8},
  { name: "Sales Head", email: "sales.head@accenture.com", role_id: 4, department_id: 9},
  { name: "Nutan Hiwale", email: "nutan.hiwale@accenture", role_id: 1},
  {name: "Unnati Dodiya", email: "unnati.dodiya@accenture.com", role_id: 1, department_id: 7}, 
  {name: "Nidhi Dhanwariya", email: "nidhi546@accenture.com", role_id: 1, department_id: 8}, 
  {name: "Saurabh Singh", email: "singhsaurabh@accenture.com", role_id: 1, department_id: 9}
])

p "Created users with different roles for various organizations"