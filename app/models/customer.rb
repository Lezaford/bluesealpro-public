# app/models/customer.rb
require "csv"

class Customer < ApplicationRecord
  belongs_to :company
  has_many :jobs, dependent: :restrict_with_error  # no :optional here

  # Validations
  validates :first_name, :last_name, presence: true, unless: -> { display_name.present? }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_validation :fill_display_name

  # Case-insensitive search across the real (CSV-backed) name, email and phone columns.
  # The legacy columns (name, phone, address, address1/2, city, state, zip) are no longer read by the app.
  SEARCH_COLUMNS = %w[first_name last_name display_name company_name email
                      mobile_number home_number work_number].freeze

  scope :search, lambda { |term|
    next all if term.blank?
    pattern = "%#{sanitize_sql_like(term.to_s.strip.downcase)}%"
    where(SEARCH_COLUMNS.map { |c| "LOWER(customers.#{c}) LIKE :q" }.join(" OR "), q: pattern)
  }

  # Convenience name
  def full_name
    display_name.presence ||
      [ first_name, last_name ].compact_blank.join(" ").presence ||
      company_name.presence ||
      name
  end

  def primary_phone
    mobile_number.presence || home_number.presence || work_number.presence
  end

  CSV_HEADERS = [
    "First Name", "Last Name", "Display Name",
    "Mobile Number", "Home Number",
    "Email", "Additional Emails",
    "Company", "Role", "Work Number",
    "Bills to", "Accepts bills from",
    "Tags", "Notes", "ID",
    "Customer Type", "Customer notifications enabled",
    "Customer is Contractor", "Lead Source",
    "Customer created at", "Last service date",
    "Lifetime value",
    "Address_1 Street Line 1", "Address_1 Street Line 2",
    "Address_1 City", "Address_1 State", "Address_1 Postal Code",
    "Address_1 Billing?", "Address_1 Notes",
    "Address_2 Street Line 1", "Address_2 Street Line 2",
    "Address_2 City", "Address_2 State", "Address_2 Postal Code",
    "Address_2 Billing?", "Address_2 Notes",
    "Address_3 Street Line 1", "Address_3 Street Line 2",
    "Address_3 City", "Address_3 State", "Address_3 Postal Code",
    "Address_3 Billing?", "Address_3 Notes",
    "Address_4 Street Line 1", "Address_4 Street Line 2",
    "Address_4 City", "Address_4 State", "Address_4 Postal Code",
    "Address_4 Billing?", "Address_4 Notes"
  ].freeze

  # --- CSV IMPORT (DB is still the source of truth) ------------------------
  def self.import(file, company:)
    count = 0
    CSV.foreach(file.path, headers: true) do |row|
      next if row.to_h.values.all?(&:blank?)  # Skip blank rows

      attrs = {
        company: company,
        first_name:          row["First Name"],
        last_name:           row["Last Name"],
        display_name:        row["Display Name"],
        mobile_number:       row["Mobile Number"],
        home_number:         row["Home Number"],
        email:               row["Email"],
        additional_emails:   row["Additional Emails"],
        company_name:        row["Company"],
        role:                row["Role"],
        work_number:         row["Work Number"],
        bills_to:            row["Bills to"],
        accepts_bills_from:  row["Accepts bills from"],
        tags:                row["Tags"],
        notes:               row["Notes"], # existing notes column
        external_id:         row["ID"],
        customer_type:       row["Customer Type"],
        customer_notifications_enabled: truthy?(row["Customer notifications enabled"]),
        customer_is_contractor:        truthy?(row["Customer is Contractor"]),
        lead_source:         row["Lead Source"],
        customer_created_at: row["Customer created at"],
        last_service_date:   row["Last service date"],
        lifetime_value:      row["Lifetime value"],

        address_1_street_line_1: row["Address_1 Street Line 1"],
        address_1_street_line_2: row["Address_1 Street Line 2"],
        address_1_city:          row["Address_1 City"],
        address_1_state:         row["Address_1 State"],
        address_1_postal_code:   row["Address_1 Postal Code"],
        address_1_billing:       truthy?(row["Address_1 Billing?"]),
        address_1_notes:         row["Address_1 Notes"],

        address_2_street_line_1: row["Address_2 Street Line 1"],
        address_2_street_line_2: row["Address_2 Street Line 2"],
        address_2_city:          row["Address_2 City"],
        address_2_state:         row["Address_2 State"],
        address_2_postal_code:   row["Address_2 Postal Code"],
        address_2_billing:       truthy?(row["Address_2 Billing?"]),
        address_2_notes:         row["Address_2 Notes"],

        address_3_street_line_1: row["Address_3 Street Line 1"],
        address_3_street_line_2: row["Address_3 Street Line 2"],
        address_3_city:          row["Address_3 City"],
        address_3_state:         row["Address_3 State"],
        address_3_postal_code:   row["Address_3 Postal Code"],
        address_3_billing:       truthy?(row["Address_3 Billing?"]),
        address_3_notes:         row["Address_3 Notes"],

        address_4_street_line_1: row["Address_4 Street Line 1"],
        address_4_street_line_2: row["Address_4 Street Line 2"],
        address_4_city:          row["Address_4 City"],
        address_4_state:         row["Address_4 State"],
        address_4_postal_code:   row["Address_4 Postal Code"],
        address_4_billing:       truthy?(row["Address_4 Billing?"]),
        address_4_notes:         row["Address_4 Notes"]
      }

      lookup_key = attrs[:external_id].presence || attrs[:email]
      next if lookup_key.blank?  # Skip if no identifier

      customer = company.customers.find_or_initialize_by(external_id: lookup_key) if attrs[:external_id].present?
      customer ||= company.customers.find_or_initialize_by(email: attrs[:email]) if attrs[:email].present?
      customer ||= company.customers.new

      customer.assign_attributes(attrs)
      if customer.save
        count += 1
      end
    end
    count
  end

  # --- CSV EXPORT ----------------------------------------------------------
  def self.to_csv(scope = all)
    CSV.generate(headers: true) do |csv|
      csv << CSV_HEADERS

      scope.find_each do |c|
        csv << [
          c.first_name,
          c.last_name,
          c.display_name,
          c.mobile_number,
          c.home_number,
          c.email,
          c.additional_emails,
          c.company_name,
          c.role,
          c.work_number,
          c.bills_to,
          c.accepts_bills_from,
          c.tags,
          c.notes,
          c.external_id,
          c.customer_type,
          c.customer_notifications_enabled,
          c.customer_is_contractor,
          c.lead_source,
          c.customer_created_at,
          c.last_service_date,
          c.lifetime_value,
          c.address_1_street_line_1,
          c.address_1_street_line_2,
          c.address_1_city,
          c.address_1_state,
          c.address_1_postal_code,
          c.address_1_billing,
          c.address_1_notes,
          c.address_2_street_line_1,
          c.address_2_street_line_2,
          c.address_2_city,
          c.address_2_state,
          c.address_2_postal_code,
          c.address_2_billing,
          c.address_2_notes,
          c.address_3_street_line_1,
          c.address_3_street_line_2,
          c.address_3_city,
          c.address_3_state,
          c.address_3_postal_code,
          c.address_3_billing,
          c.address_3_notes,
          c.address_4_street_line_1,
          c.address_4_street_line_2,
          c.address_4_city,
          c.address_4_state,
          c.address_4_postal_code,
          c.address_4_billing,
          c.address_4_notes
        ]
      end
    end
  end

  def self.truthy?(value)
    value.to_s.strip.downcase.in?(%w[true t yes y 1])
  end

  private

  # display_name is what lists/search/JSON show; derive it when the user left it blank.
  def fill_display_name
    return if display_name.present?
    self.display_name = [ first_name, last_name ].compact_blank.join(" ").presence || company_name.presence
  end
end
