Company.create!(id: 1, name: 'BlueSealPro Test Co', address: '123 Test Ave')
User.where(email: 'admin@example.com').first_or_create!(
  name: 'Admin',
  role: 'admin',
  company_id: 1,
  password: 'Password123!',
  password_confirmation: 'Password123!'
)
