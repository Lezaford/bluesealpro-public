# Demo seed data. Idempotent: safe to run repeatedly (db:seed / db:setup / db:reset).
# DEMO ONLY: the credentials below are public and must never be used in production.
if Rails.env.production? && ENV["ALLOW_DEMO_SEED"] != "1"
  puts "Skipping demo seed in production (set ALLOW_DEMO_SEED=1 to override)."
  return
end

company = Company.find_or_create_by!(slug: "demo-co") do |c|
  c.name    = "BlueSealPro Demo Co"
  c.address = "123 Demo Ave"
end

user = User.find_or_initialize_by(email: "admin@test.com")
user.assign_attributes(
  name: "Demo Admin",
  role: "admin",
  company_id: company.id,
  active: true,
  password_change_required: false,
  password: "password",
  password_confirmation: "password"
)
user.save!
puts "Seeded demo login: admin@test.com / password"

load Rails.root.join("db/seeds/demo_customers.rb")
