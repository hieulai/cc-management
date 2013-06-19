# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Category.destroy_all
Category.create ([{name: "Planning & Design"}, {name: "Permits & Inspections"}, {name: "Job Site Facilities"}, {name: "Demolition"},
                  {name:"Site Work"}, {name:"Foundation"}, {name:"Framing"}, {name:"Doors & Windows"}, {name:"Roofing"},
                  {name:"Exterior Veneers"}, {name:"Plumbing"}, {name:"HVAC"}, {name:"Electrical"}, {name:"Insulation"},
                  {name:"Drywall & Paint"}, {name:"Cabinetry & Counters"}, {name:"Finish Carpentry"}, {name:"Flooring & Tile"},
                  {name:"Appliances"}, {name:"Hardware"}, {name:"Specialty"}, {name:"Landscaping"}, {name:"Cleaning & Hauling"}])

Item.destroy_all
Item.create ([{name: "Custom Shower Pan", description: "Labor & Materials: Build custom shower pan.", unit: "each", cost: 450, margin: 75},
              {name: "Frisae Carpet", description: "Labor & Materials: Install frisae style carpet.", unit: "sf", cost: 1.85, margin: 0.50},
              {name: "Vanity Sink", description: "Allowance: Brushed nickel vanity sink.", unit: "each", cost: 70, margin: 0},
              {name: "Under-mount Sink", description: "Allowance: Stainless steel under-mount kitchen sink.", unit: "each", cost: 275, margin: 0},
              {name: "2x4x9 Stud", description: "Materials: 9ft-2x4 studs", unit: "each", cost: 2.53, margin: 0.20},
              {name: "1/2 OSB Subflooring", description: "Materials: 4x8 sheets of 1/2in T&G OSB Subflooring", unit: "each", cost: 13.78, margin: 0.50},
              {name: "Ceiling Fan", description: "Allowance: Builder grade ceiling fan.", unit: "each", cost: 150, margin: 0},
              {name: "Labor", description: "Labor: Build new service panel.", unit: "each", cost: 1850, margin: 400},
              {name: "Labor", description: "Labor: Install all wiring and electrical fixtures.", unit: "sf", cost: 4.15, margin: 2}])