# Quick Reference: Server-Driven Customer Search

## What Changed

### Before
```erb
<!-- Form had embedded JavaScript with all @customers -->
<script>
  const customers = <%= @customers.map {...}.to_json %>;
  // Hundreds of lines of custom search logic
</script>
```

### After
```erb
<!-- Clean, reusable Stimulus markup -->
<div data-controller="customer-search">
  <input data-customer-search-target="input" ... />
  <div data-customer-search-target="dropdown"></div>
  <%= f.hidden_field :customer_id, data: { "customer-search-target" => "customerId" } %>
</div>
```

---

## Key Files

| File | Change | Impact |
|------|--------|--------|
| `config/routes.rb` | Added `GET /customers/search` | New API endpoint |
| `app/controllers/customers_controller.rb` | Added `search` action + JSON `show` | Server handles queries |
| `app/controllers/jobs_controller.rb` | Removed `@customers` variable | Leaner controller |
| `app/javascript/controllers/customer_search_controller.js` | Created new Stimulus controller | Client-side logic moved here |
| `app/views/jobs/_form.html.erb` | Removed embedded JS, added Stimulus markup | Clean, maintainable form |
| `db/migrate/...add_customer_search_indexes.rb` | New migration | Performance optimization |

---

## How to Test

### 1. Create New Job
```
1. Visit /jobs/new
2. Click "Customer" field
3. Type a name (e.g., "john")
4. Verify dropdown shows matching customers
5. Click a customer → blue chip appears
6. Save form → should work
```

### 2. Edit Existing Job
```
1. Visit /jobs/:id/edit
2. Verify customer chip pre-populated
3. Type to search for different customer
4. Change to new customer → chip updates
5. Save form → should work
```

### 3. Network Monitoring
```
1. Open DevTools (F12)
2. Go to Network tab
3. Type in customer field
4. Look for GET /customers/search?q=... requests
5. Verify response is JSON array with { id, name, email }
6. Verify requests are debounced (only a few, not one per keystroke)
```

---

## API Endpoints

### Search Customers
```
GET /customers/search?q=john
Accept: application/json

Response:
[
  { "id": 1, "name": "John Smith", "email": "john@example.com" },
  { "id": 2, "name": "John Doe", "email": "john.doe@example.com" }
]
```

### Get Single Customer (for edit form)
```
GET /customers/:id.json
Accept: application/json

Response:
{ "id": 1, "name": "John Smith", "email": "john@example.com" }
```

---

## Stimulus Controller Details

**Location**: `app/javascript/controllers/customer_search_controller.js`

**Main Methods**:
- `connect()` - Initialize on page load
- `handleInput(event)` - Trigger search on input (debounced)
- `searchCustomers(query)` - Fetch from server
- `selectCustomer(event)` - Handle selection
- `clearSelection(event)` - Clear selected customer
- `handleFocus(event)` - Show dropdown on focus
- `handleKeydown(event)` - Handle Escape key

**Targets**:
- `input` - Search text field
- `dropdown` - Results container
- `customerId` - Hidden field storing selected ID

---

## Performance Notes

- **Debounce**: 200ms (adjustable via `debounceDelayValue`)
- **Result Limit**: 8 customers per query
- **Indexes**: Database indexes on first_name, last_name, email, phone
- **Scoping**: All queries filtered by company_id (multi-tenant)
- **Searches**: first_name, last_name, display_name, email, phone, mobile_number

---

## Deployment Checklist

- [ ] Review code changes
- [ ] Run `rails db:migrate` to add indexes
- [ ] Test on staging
- [ ] Monitor `/customers/search` response times
- [ ] Deploy to production
- [ ] Verify customer search works for all users
- [ ] Check slow query logs

---

## Troubleshooting

### Search not working?
- Check DevTools Network tab for `/customers/search?q=...` requests
- Verify response is valid JSON
- Check Rails logs for errors
- Ensure migration ran: `rails db:migrate`

### Dropdown not showing?
- Check if Stimulus controller is loading: `console.log(document.querySelector('[data-controller="customer-search"]'))`
- Verify JavaScript file exists: `app/javascript/controllers/customer_search_controller.js`

### Pre-population not working on edit?
- Check if hidden field has a `customer_id` value
- Verify `/customers/:id.json` endpoint works
- Check browser console for fetch errors

### Slow searches?
- Run `rails db:migrate` to ensure indexes exist
- Check Rails logs for slow query times
- Monitor database index usage: `ANALYZE customers;`

---

## Future Improvements

1. Add customer phone/location to results
2. Sort by relevance (matching first_name > last_name > email)
3. Cache recent searches
4. Add customer avatars/photos
5. Full-text search for PostgreSQL
6. Trigram index for fuzzy matching

---

**Version**: 1.0
**Date**: 2026-01-12
**Status**: Production Ready 
