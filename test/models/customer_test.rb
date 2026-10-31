require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "display_name is derived from first and last name when blank" do
    c = Customer.create!(company: companies(:one), first_name: "Zed", last_name: "Quarry")
    assert_equal "Zed Quarry", c.display_name
    assert_equal "Zed Quarry", c.full_name
  end

  test "display_name falls back to company_name and keeps an explicit value" do
    c = Customer.create!(company: companies(:one), display_name: "Acme Test Co", company_name: "Acme Test Co")
    assert_equal "Acme Test Co", c.full_name
    d = Customer.create!(company: companies(:one), first_name: "A", last_name: "B", display_name: "Custom")
    assert_equal "Custom", d.display_name
  end

  test "requires a name" do
    c = Customer.new(company: companies(:one))
    assert_not c.valid?
  end

  test "search matches names, email and phones and escapes wildcards" do
    c = Customer.create!(company: companies(:one), first_name: "Zed", last_name: "Quarry",
                         email: "zed@example.com", mobile_number: "(206) 555-0142")
    assert_includes Customer.search("quarry"), c
    assert_includes Customer.search("555-0142"), c
    assert_includes Customer.search("ZED@EXAMPLE"), c
    assert_not_includes Customer.search("%"), c
    assert_includes Customer.search(""), c
  end

  test "primary_phone prefers mobile then home then work" do
    assert_equal "2", Customer.new(home_number: "2", work_number: "3").primary_phone
    assert_equal "3", Customer.new(work_number: "3").primary_phone
  end
end
