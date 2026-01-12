# Customer Search Refactoring: Server-Driven with Stimulus

## Overview

The job form customer search has been refactored from a client-side, embedded-array approach to a server-driven, Stimulus-powered implementation. This supports large customer lists (10k+) efficiently and provides better UX with real-time server queries.

## Changes Made

### 1. Routes (`config/routes.rb`)

Added a new collection route:
```ruby
get :search # GET /customers/search?q=...
```

This endpoint accepts a query string and returns JSON results.

### 2. CustomersController (`app/controllers/customers_controller.rb`)

#### New `search` Action
- **Endpoint**: `GET /customers/search?q=<query>`
- **Input**: `params[:q]` (search string)
- **Output**: JSON array of up to 8 customers with `{ id, name, email }`
- **Behavior**:
  - If `q` is blank: returns most recent/alphabetical customers
  - If `q` is present: filters by `full_name`, `email`, and `phone` using LIKE queries
  - Scoped to current user's company (multi-tenant safe)
  - Returns max 8 results for performance

#### Updated `show` Action
- Now responds to both HTML and JSON formats
- JSON response: `{ id, name, email }`
- Used when editing a job to pre-populate the selected customer display

### 3. JobsController (`app/controllers/jobs_controller.rb`)

**Removed**: `@customers` variable from `new`, `edit`, `create`, and `update` actions.

The form now queries the server dynamically instead of loading all customers upfront.

### 4. Stimulus Controller (`app/javascript/controllers/customer_search_controller.js`)

New controller manages the customer search typeahead:

**Targets**:
- `input`: The text input field for searching
- `dropdown`: The results dropdown container
- `customerId`: The hidden field that stores `job.customer_id`

**Values**:
- `debounceDelay`: Debounce delay in milliseconds (default: 200ms)

**Key Methods**:
- `handleInput()`: Triggers debounced search as user types
- `searchCustomers(query)`: Fetches results from `/customers/search?q=<query>`
- `selectCustomer()`: Handles selection, sets hidden field, displays chip
- `clearSelection()`: Clears selected customer and resets form
- `handleFocus()`: Shows dropdown on input focus
- `fetchAndDisplayCustomer()`: Pre-populates display when editing (calls `GET /customers/:id.json`)

**Features**:
- Debounces requests (200ms by default)
- Highlights matching characters in results
- HTML escaping to prevent XSS
- Escape key closes dropdown
- Click-outside closes dropdown
- Displays selected customer as a styled chip with remove button

### 5. Job Form (`app/views/jobs/_form.html.erb`)

**Before**: Embedded `@customers` JSON, custom JavaScript in ERB

**After**: 
- Clean Stimulus-powered markup with data attributes
- No embedded arrays
- No custom JavaScript in the view
- Uses `data-controller="customer-search"` and target/action declarations

### 6. Database Indexes (`db/migrate/20260112160700_add_customer_search_indexes.rb`)

Added indexes for performance:
- `customers.full_name` - for LIKE searches
- `customers.email` - for LIKE searches
- `customers.company_id + customers.full_name` - for multi-tenant scoped searches
- `customers.company_id + customers.email` - for multi-tenant scoped searches
- `customers.phone` (optional, if column exists) - for phone searches

## Benefits

 **Scalability**: Works with 10k+ customers without loading them into the page
 **Performance**: Server-side filtering with indexed queries + debounced requests
 **Security**: Multi-tenant scoped, HTML escaping, no embedded secrets
 **Maintainability**: Stimulus controller in dedicated file, clean separation of concerns
 **UX**: Real-time results, highlighting, chip-based selection, keyboard navigation
 **Mobile-friendly**: Native datetime input for scheduling

## Usage

### For Users

1. **Creating a Job**: Click in the "Customer" field and start typing a name or email
2. **Results**: Server returns matching customers with highlighting
3. **Selection**: Click a customer to select them; a blue chip appears
4. **Clear**: Click the × on the chip to clear and search again
5. **Editing a Job**: The selected customer auto-populates on page load

### For Developers

**To customize**:
- Edit `app/javascript/controllers/customer_search_controller.js` to change debounce timing, result limit, etc.
- Edit the `search` action in `CustomersController` to adjust filtering logic
- Modify the form markup in `app/views/jobs/_form.html.erb` to customize UI

**To test**:
1. Run migrations: `rails db:migrate`
2. Open a job form (new or edit)
3. Start typing in the customer field
4. Check browser Network tab to verify `GET /customers/search?q=<query>` requests

## Migration Notes

**Before deployment**:
1. Run `rails db:migrate` to add indexes
2. Monitor query performance; indexes should make searches instant
3. Test with your actual customer list size
4. Verify multi-tenant scoping works correctly

**Optional future enhancements**:
- Add PostgreSQL trigram index (`CREATE INDEX ... USING gin ...`) for even better fuzzy matching
- Add sorting by relevance or recency
- Add customer avatars or tags to results
- Implement full-text search if using PostgreSQL
