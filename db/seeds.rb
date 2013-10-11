# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# BEAUTY
beauty = Theme.create({
  name: "Beauty",
  pristine: true,
  default_document_id: 1
})

beauty.documents.create({
  name: "Style",
  extension: "css",
  body: IO.read(File.expand_path("app/views/templates/beauty/style.css"))
})

beauty_default = beauty.documents.create({
  name: "Main With Sidebar",
  extension: "html",
  body: IO.read(File.expand_path("app/views/templates/beauty/main_with_sidebar.html"))
})

beauty.update default_document_id: beauty_default.id


# ESSENCE
essence = Theme.create({
  name: "Essence",
  pristine: true,
  default_document_id: 1
})

essence.documents.create({
  name: "Style",
  extension: "css",
  body: IO.read(File.expand_path("../app/views/templates/essence/style.css"))
})

essence_default = essence.documents.create({
  name: "Homepage",
  extension: "html",
  body: IO.read(File.expand_path("../app/views/templates/essence/homepage.html"))
})

essence.update default_document_id: essence_default.id

# ADDONS
addons = Addon.create([
  {
    name: "Email Address",
    permalink: "email",
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
    name: "Lite Streaming",
    permalink: "email",
    price: 3000,
    quantifiable: false,
    available: false
  }
])