require "test_helper"

# End-to-end smoke test: the public pages render, auth is enforced, and a signed-in admin can load key pages.
class AppSmokeTest < ActionDispatch::IntegrationTest
  test "landing and login pages are public" do
    get root_url
    assert_response :success
    get new_user_session_url
    assert_response :success
  end

  test "health check" do
    get rails_health_check_url
    assert_response :success
  end

  test "dashboard requires login" do
    get dashboard_url
    assert_response :redirect
  end

  test "login with valid and invalid password" do
    post user_session_url, params: { user: { email: "admin@fixture.test", password: "wrong" } }
    assert_response :unprocessable_entity
    post user_session_url, params: { user: { email: "admin@fixture.test", password: "password" } }
    assert_response :redirect
  end

  test "signed-in admin can load key pages" do
    post user_session_url, params: { user: { email: "admin@fixture.test", password: "password" } }
    [ dashboard_url, customers_url, new_customer_url, jobs_url, new_job_url, invoices_url, schedule_url,
      technicians_url, admin_dashboard_url, edit_admin_company_url, admin_users_url,
      admin_price_book_items_url, new_admin_price_book_item_url ].each do |url|
      get url
      assert_response :success, "#{url} returned #{response.status}"
    end
  end

  test "users cannot see another company's customers" do
    post user_session_url, params: { user: { email: "admin@fixture.test", password: "password" } }
    get customer_url(customers(:two))
    assert_response :not_found
  end

  test "customers index paginates and searches; delete with jobs is refused" do
    post user_session_url, params: { user: { email: "admin@fixture.test", password: "password" } }
    company = users(:admin).company
    30.times { |n| Customer.create!(company: company, first_name: "Bulk", last_name: "Cust#{format('%02d', n)}") }
    get customers_url
    assert_response :success
    assert_select "tbody tr", CustomersController::PER_PAGE
    get customers_url(page: 2)
    assert_response :success
    get customers_url(q: "cust07")
    assert_select "tbody tr", 1
    get search_customers_url(q: "cust07", format: :json)
    assert_equal 1, JSON.parse(response.body).size

    victim = Customer.find_by!(last_name: "Cust01")
    assert_difference("Customer.count", -1) { delete customer_url(victim) }
    assert_redirected_to customers_url
  end
end
