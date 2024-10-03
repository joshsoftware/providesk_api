# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Organization.create!([
  { name: "Josh Software", domain: ["joshsoftware.com"] },
])

p "Created 3 organizations"

Role.create!([
  { name: "super_admin" },
  { name: "admin" },
  { name: "department_head" },
  { name: "employee" }
])

p "Created 4 Roles: employee, admin, super_admin, department_head"

Department.create!([
  { name: "HR", organization_id: 1 },
  { name: "Admin, Procuremnet and IT Support", organization_id: 1},
  { name: "Payroll", organization_id: 1 },
])

p "Created departments for all organizations"

Category.create!([
  { name: "HR OPs", priority: 0, department_id: 1, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "Employee Relation/HRBP", priority: 0, department_id: 1, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "TAG", priority: 0, department_id: 1, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "L&D", priority: 0, department_id: 1, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},

  { name: "Reimbursement", priority: 0, department_id: 2, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "Service Request (ID Card and Office Goodies)", priority: 0, department_id: 2, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "Travel Request", priority: 0, department_id: 2, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "Suggestion", priority: 0, department_id: 2, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "Complaint", priority: 0, department_id: 2, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "Laptop Repair/Service Request", priority: 0, department_id: 2, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "Laptop Procurement", priority: 0, department_id: 2, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  
  { name: "Taxation", priority: 0, department_id: 3, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1},
  { name: "Form 16", priority: 0, department_id: 3, sla_unit: 1, sla_duration_type: 'hours',duration_in_hours: 1},
  { name: "TDS", priority: 0, department_id: 3, sla_unit: 1, sla_duration_type: 'hours', duration_in_hours: 1}
  
])

p "Created categories for various departments"

User.create!([
  { "name": "Vijayalaxmi Belekar", "email": "vijayalaxmi.belekar@joshsoftware.com", "role_id": 3, "department_id": 1 },
  { "name": "Pallavi Sajjanshetty", "email": "pallavi.sajjanshetty@joshsoftware.com", "role_id": 3, "department_id": 1 },
  { "name": "Rakshith KN", "email": "rakshith.kn@joshsoftware.com", "role_id": 3, "department_id": 2 },
  { "name": "Shweta Parmar", "email": "shweta.parmar@joshsoftware.com", "role_id": 3, "department_id": 2 },
  { "name": "Shradha Chaudhari", "email": "shradha.chaudhari@joshsoftware.com", "role_id": 3, "department_id": 3 },
  { "name": "Mohini Mane", "email": "mohini.mane@joshsoftware.com", "role_id": 3, "department_id": 3 },
  { "name": "Saurabh Gaji", "email": "saurabh.gaji@joshsoftware.com", "role_id": 3, "department_id": 1 },
  { "name": "SriGayathriKavya Ruttala", "email": "srigayathri.ruttala@joshsoftware.com", "role_id": 3, "department_id": 1 },
  { "name": "Harshal Ingale", "email": "harshal.ingale@joshsoftware.com", "role_id": 3, "department_id": 1 },
  { "name": "Sneha Mantri", "email": "sneha.mantri@joshsoftware.com", "role_id": 3, "department_id": 1 },
  { "name": "Sindhu R", "email": "sindhu.r@joshsoftware.com", "role_id": 3, "department_id": 1 },

  { "name": "Sethupathi Asokan", "email": "sethu@joshsoftware.com", "role_id": 2},
  { "name": "Shailesh Kalekar", "email": "shailesh.kalekar@joshsoftware.com", "role_id": 2},
  { "name": "Sameer Tilak", "email": "sameer@joshsoftware.com", "role_id": 2},
  { "name": "Shambhavi Sharma", "email": "shambhavi.sharma@joshsoftware.com", "role_id": 2},
  { "name": "Sumit Patil", "email": "sumit.patil@joshsoftware.com", "role_id": 2}
])

p "Created users with different roles for various organizations"

