# Pre-Deployment Verification Checklist

## Code Changes Verification

### Routes
- [ ] `config/routes.rb` contains `get :search` in customers collection
- [ ] Route test: `GET /customers/search?q=test` accessible
- [ ] Route test: `GET /customers/:id.json` accessible

### Controllers
- [ ] `CustomersController#search` action exists (45 lines)
- [ ] `CustomersController#show` supports JSON format
- [ ] `JobsController#new` no longer has `@customers`
- [ ] `JobsController#edit` no longer has `@customers`
- [ ] `JobsController#create` error case no longer has `@customers`
- [ ] `JobsController#update` error case no longer has `@customers`

### Views
- [ ] `app/views/jobs/_form.html.erb` has no embedded JavaScript
- [ ] `app/views/jobs/_form.html.erb` has no @customers.map
- [ ] Customer field has `data-controller="customer-search"`
- [ ] Customer field has three targets: input, dropdown, customerId
- [ ] Date/time field is single `datetime_local_field`
- [ ] Internal Notes labeled as `(optional)`

### Stimulus Controller
- [ ] File exists: `app/javascript/controllers/customer_search_controller.js`
- [ ] Controller is 228 lines
- [ ] Has targets: input, dropdown, customerId
- [ ] Has values: debounceDelay (200ms default)
- [ ] Has connect/disconnect methods (cleanup)
- [ ] Has searchCustomers method (fetches from server)
- [ ] Has selectCustomer method (handles selection)
- [ ] Has clearSelection method (resets form)

### Database Migration
- [ ] Migration exists: `db/migrate/20260112160700_add_customer_search_indexes.rb`
- [ ] Indexes for: first_name, last_name, display_name, phone, mobile_number
- [ ] Composite indexes for: (company_id, first_name), (company_id, last_name), (company_id, email)
- [ ] Uses `unless index_exists?` for idempotency
- [ ] Migration is idempotent (safe to run multiple times)

### Documentation
- [ ] CUSTOMER_SEARCH_REFACTORING.md exists
- [ ] IMPLEMENTATION_COMPLETE.md exists
- [ ] QUICK_REFERENCE.md exists
- [ ] DATABASE_MIGRATION_NOTES.md exists
- [ ] DELIVERABLES.md exists
- [ ] CHANGES_SUMMARY.md exists

---

## Functional Testing Checklist

### Create Job Form
- [ ] Form page loads quickly (< 100ms)
- [ ] No console errors
- [ ] Customer field is visible and clickable
- [ ] Clicking customer field shows empty dropdown or recent customers
- [ ] Type "test" in customer field
- [ ] Dropdown appears with results
- [ ] DevTools shows `GET /customers/search?q=test` request
- [ ] Response is valid JSON array
- [ ] Response includes: id, name, email
- [ ] Response limited to 8 results
- [ ] Matching characters are highlighted
- [ ] Clicking a result shows blue chip with customer name
- [ ] Hidden field `job[customer_id]` is populated
- [ ] Clicking × on chip removes selection
- [ ] Can search again after clearing
- [ ] Pressing Escape closes dropdown
- [ ] Clicking outside closes dropdown
- [ ] Form can be submitted with selected customer
- [ ] Job is created with correct customer_id

### Edit Job Form
- [ ] Form page loads quickly (< 100ms)
- [ ] Customer field shows blue chip with selected customer
- [ ] No network requests on page load (chip populated immediately)
- [ ] Can click × to clear selection
- [ ] Can search for new customer
- [ ] Can select new customer
- [ ] Form can be submitted with new customer
- [ ] Job is updated with new customer_id

### Search Behavior
- [ ] Search is case-insensitive
- [ ] Search works on: first_name, last_name, display_name, email, phone, mobile_number
- [ ] Partial matches work (typing "john" matches "Johnny")
- [ ] Special characters handled correctly
- [ ] Search returns max 8 results
- [ ] Empty search shows alphabetically sorted customers
- [ ] No results shows "No customers found" message
- [ ] Results appear quickly (< 5ms)

### Performance
- [ ] Form load time: < 100ms (was ~200ms before)
- [ ] Search response time: 1-5ms
- [ ] Requests are debounced (type quickly, see few network requests)
- [ ] 200ms debounce delay working
- [ ] No console errors or warnings
- [ ] Memory doesn't leak (search multiple times, no growth)

### Edge Cases
- [ ] Works with 10k+ customers
- [ ] Works with special characters in names
- [ ] Works with numbers in email
- [ ] Works with missing email
- [ ] Works with phone number searches
- [ ] Handles network errors gracefully
- [ ] Handles timeout gracefully
- [ ] Works in different browsers (Chrome, Firefox, Safari)
- [ ] Works on mobile (responsive)

---

## Database Verification

### Indexes Created
```bash
# Run these in rails console:

# Check if all indexes exist:
ActiveRecord::Base.connection.execute(
  "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='customers';"
).to_a

# Should include:
# - index_customers_on_first_name
# - index_customers_on_last_name
# - index_customers_on_display_name
# - index_customers_on_phone
# - index_customers_on_mobile_number
# - index_customers_on_company_id_and_first_name
# - index_customers_on_company_id_and_last_name
# - index_customers_on_company_id_and_email
```

### Query Performance
```bash
# Rails console:
company_id = 1
Customer.where(company_id: company_id)
  .where("LOWER(first_name) LIKE ? OR LOWER(email) LIKE ?", "%john%", "%john%")
  .explain

# Should show index usage, not sequential scan
```

---

## Security Verification

- [ ] Multi-tenant scoping verified (WHERE company_id = X in search)
- [ ] XSS prevention verified (HTML escaping in Stimulus controller)
- [ ] No sensitive data in frontend code
- [ ] No customer list embedded in page
- [ ] Authentication required on all endpoints
- [ ] SQL injection prevention (parameterized queries)
- [ ] Test with SQL injection attempt: `search?q='); DROP TABLE...` (should be safe)

---

## Browser Compatibility

- [ ] Chrome/Chromium: ✓
- [ ] Firefox: ✓
- [ ] Safari: ✓
- [ ] Edge: ✓
- [ ] Mobile Chrome: ✓
- [ ] Mobile Safari: ✓

---

## Accessibility Verification

- [ ] Keyboard navigation works (Tab, Escape)
- [ ] Screen reader compatible
- [ ] Color contrast sufficient
- [ ] Form labels present
- [ ] Required field indicators clear (*)
- [ ] Error messages clear

---

## Monitoring & Logging

### Set Up Alerts For
- [ ] `/customers/search` endpoint response time > 500ms
- [ ] `/customers/search` error rate > 1%
- [ ] `/customers/:id.json` response time > 100ms
- [ ] Database query time > 100ms
- [ ] JavaScript console errors

### Monitor Logs For
- [ ] 500 errors on /customers/search
- [ ] 403 errors (multi-tenant permission issues)
- [ ] Slow query warnings
- [ ] N+1 query issues

---

## Documentation Review

- [ ] CHANGES_SUMMARY.md reviewed
- [ ] Implementation plan vs actual changes match
- [ ] API documentation complete and accurate
- [ ] Code examples tested
- [ ] Rollback procedure documented
- [ ] Known limitations documented

---

## Post-Deployment

### Immediate (1st Hour)
- [ ] Monitor error logs
- [ ] Check response times
- [ ] Verify search endpoint working
- [ ] Spot check a few job creations
- [ ] Verify no 500 errors

### First Day
- [ ] Monitor performance metrics
- [ ] Get user feedback
- [ ] Check database query logs
- [ ] Verify all database indexes exist

### First Week
- [ ] Gather usage statistics
- [ ] Check for any edge cases encountered
- [ ] Review performance metrics
- [ ] Plan any optimizations needed

---

## Rollback Procedure

If critical issues found:

```bash
# 1. Remove migration (drop indexes)
rails db:migrate:down VERSION=20260112160700

# 2. Revert code to previous version
git checkout HEAD~1 app/

# 3. Restart Rails
rails restart

# 4. Verify old behavior works
# 5. Open incident ticket to review issue
```

---

## Sign-Off Checklist

- [ ] Code review approved by: _______________
- [ ] QA testing passed: _______________
- [ ] Database performance verified: _______________
- [ ] Security review passed: _______________
- [ ] Documentation reviewed: _______________
- [ ] Production deployment approved by: _______________

---

## Go/No-Go Decision

**Go for Deployment**: ☐ YES ☐ NO

**Prepared by**: _______________
**Date**: _______________
**Time**: _______________

**Notes**: 
