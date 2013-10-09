# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

addons = Addon.create([
  {
    name: "Extra Email Address",
    permalink: "extra_email",
    price: 200,
    quantifiable: true,
    available: true
  },
  {
    name: "Web Store",
    permalink: "store",
    price: 2000,
    quantifiable: false,
    available: true
  },
  {
    name: "Accept Donations",
    permalink: "donations",
    price: 0,
    quantifiable: false,
    available: true
  },
  {
    name: "Lite Live Streaming",
    permalink: "extra_email",
    price: 3000,
    quantifiable: false,
    available: false
  }
])