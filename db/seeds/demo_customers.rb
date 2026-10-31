# Demo customers (+ a few technicians and jobs). Everything here is fictitious.
# Idempotent and deterministic: a fixed Random seed drives every value, rows are keyed on
# external_id ("DEMO-0001".."DEMO-0100"), so re-running updates in place and never duplicates.
# Emails use example.com/example.org; phones use the NANP fictional range 555-0100..0199.
company = Company.find_by!(slug: "demo-co")
rng = Random.new(20_261_030)
ref = Date.new(2026, 10, 30)
pick = ->(list) { list[rng.rand(list.size)] }

FIRST = %w[Alma Bennett Cora Dario Elena Felix Greta Hugo Iris Jonah Kira Leo Mina Nolan Opal Pria Quinn Rafael Sana Theo
           Una Victor Wren Xavier Yara Zane Amara Bruno Celia Dmitri Esme Farid Gwen Hana Ivan Junia Karim Lena Marco].freeze
SUR_A = %w[Wren Ash Brim Cald Dun Elm Fen Garr Hale Ivor Kes Lark Marl Nor Oak Pell Quil Rowan Stan Thorn Vance Wick].freeze
SUR_B = %w[ford ley wick mere hollow stead ton by worth croft field vale ridge brook den man].freeze
STREET_W = %w[Bramblewood Larkspur Foxglove Tumbleweed Copperleaf Marrowby Hazelmoor Quillfeather Sundial Pennywhistle
              Driftwood Mossgrove Thistledown Cinderbrook Lanternfly Wrenfield Gloamwood Honeycomb Saltmarsh Kestrel].freeze
STREET_T = %w[Street Avenue Lane Road Court Way Drive Place Terrace Circle].freeze
CITY_A = %w[Brindle Oakhaven Marrow Fallow Tessling Harrow Quill Windle Ember Stoney Alder Pebble].freeze
CITY_B = %w[mere vale burg ton field port haven wick ford brook].freeze
STATES = %w[OR WA CO MN OH NC TX GA].freeze
AREA = %w[206 303 218 614 704 512 404 541].freeze
BIZ_A = %w[Quillfeather Brindlewick Marrowby Tessling Oakhollow Pennyroyal Gloamwood Copperleaf Larkspur Kestrel Saltmarsh Driftwood].freeze
BIZ_B = [ "Bakery", "Property Group", "Studios", "Dental Care", "Logistics", "Bistro", "Fitness", "Law Offices",
         "Apartments", "Print Shop", "Garden Cafe", "Family Clinic" ].freeze
LEADS = [ "Google search", "Referral", "Facebook", "Yard sign", "Nextdoor", "Repeat customer", "Home show", "Flyer" ].freeze
TAGS = %w[vip warranty senior-discount landlord pets-in-home gate-code call-first prefers-text net-30 recurring].freeze
RES_NOTES = [ "Dog in backyard, call before arriving.", "Prefers morning appointments.", "Gate code shared by phone.",
             "Elderly parent at home, ring doorbell twice.", "Appliances are about 8 years old.",
             "Park on the street, driveway is shared.", "Always asks for an itemized estimate." ].freeze
BIZ_NOTES = [ "Deliveries accepted at rear dock only.", "Service after 6pm to avoid lunch rush.",
             "Invoices go to accounts payable by email.", "Multiple units on site, check unit number.",
             "Requires certificate of insurance on file." ].freeze
ADDR_NOTES = [ "Side entrance.", "Buzzer broken, knock.", "Ask for front desk.", "Use rear parking lot.",
              "Second floor, no elevator.", "Key under planter, confirm first.", "Leave invoice in mailbox." ].freeze
UNITS = ->(r) { "#{[ 'Apt', 'Unit', 'Suite' ][r.rand(3)]} #{r.rand(1..48)}#{[ '', 'A', 'B' ][r.rand(3)]}" }

phone = lambda do
  "(#{pick.(AREA)}) 555-01#{format('%02d', rng.rand(100))}"
end
street = -> { "#{rng.rand(100..9899)} #{pick.(STREET_W)} #{pick.(STREET_T)}" }
addr = lambda do |with_line2|
  { l1: street.call, l2: (with_line2 ? UNITS.(rng) : ""), city: pick.(CITY_A) + pick.(CITY_B),
    state: pick.(STATES), zip: format("%05d", rng.rand(10_000..99_999)), notes: pick.(ADDR_NOTES) }
end

legacy_ada = company.customers.where(external_id: nil, email: [ nil, "" ], first_name: "Ada", last_name: "Lovelace").first

count_before = company.customers.count
101.times do |i|
  # i == 0 enriches the pre-existing sample customer (Ada Lovelace) if present; 1..100 are the demo set.
  business = rng.rand < 0.3
  first = pick.(FIRST)
  last = (pick.(SUR_A) + pick.(SUR_B)).capitalize
  org = business ? "#{pick.(BIZ_A)} #{pick.(BIZ_B)}" : "#{last} Household"
  first, last = "Ada", "Lovelace" if i.zero?
  disp = business && rng.rand < 0.5 ? org : "#{first} #{last}"
  addrs = Array.new(4) { |n| addr.(rng.rand < (n.zero? ? 0.5 : 0.4)) }
  service = ref - rng.rand(3..700)
  created = Time.utc(ref.year, ref.month, ref.day, 9, 0) - (rng.rand(1..1200) + (ref - service).to_i).days - rng.rand(0..80_000).seconds
  mobile, home, work = phone.call, phone.call, phone.call
  slug = "#{first}.#{last}".downcase
  domain = rng.rand < 0.5 ? "example.com" : "example.org"
  other = pick.(%w[example.com example.org])
  tags = TAGS.sample(rng.rand(2..3), random: rng).join(", ")
  external_id = format("DEMO-%04d", i)

  attrs = {
    first_name: first, last_name: last, display_name: disp,
    email: "#{slug}#{i}@#{domain}", additional_emails: "#{first.downcase}.alt#{i}@#{other}, billing#{i}@#{other}",
    mobile_number: mobile, home_number: home, work_number: work,
    company_name: org, role: business ? pick.([ "Owner", "Office Manager", "Property Manager", "Facilities Lead" ]) : pick.([ "Homeowner", "Tenant", "Landlord" ]),
    bills_to: disp, accepts_bills_from: "billing#{i}@#{other}",
    tags: tags, notes: pick.(business ? BIZ_NOTES : RES_NOTES),
    customer_type: business ? "Commercial" : "Residential",
    customer_notifications_enabled: rng.rand < 0.8, customer_is_contractor: business,
    lead_source: pick.(LEADS), customer_created_at: created, last_service_date: service,
    lifetime_value: BigDecimal(rng.rand(0..950_000)) / 100,
    # legacy single-address / phone / name columns, mirrored from the real ones so nothing is blank
    name: disp, phone: mobile, address: "#{addrs[0][:l1]}, #{addrs[0][:city]}, #{addrs[0][:state]} #{addrs[0][:zip]}",
    address1: addrs[0][:l1], address2: addrs[0][:l2].presence || "Main residence", city: addrs[0][:city],
    state: addrs[0][:state], zip: addrs[0][:zip]
  }
  addrs.each_with_index do |a, n|
    k = n + 1
    attrs.merge!(
      "address_#{k}_street_line_1": a[:l1], "address_#{k}_street_line_2": a[:l2],
      "address_#{k}_city": a[:city], "address_#{k}_state": a[:state], "address_#{k}_postal_code": a[:zip],
      "address_#{k}_billing": n.zero?, "address_#{k}_notes": a[:notes]
    )
  end

  record = if i.zero?
    legacy_ada || company.customers.find_by(external_id: external_id)
  else
    company.customers.find_or_initialize_by(external_id: external_id)
  end
  next if record.nil?
  record.assign_attributes(attrs.merge(external_id: external_id))
  record.save!
end
puts "Seeded demo customers: #{company.customers.where("external_id LIKE 'DEMO-%'").count} demo (#{company.customers.count - count_before} new)"

# --- technicians and a modest set of jobs so dashboard/schedule are not empty ---------------
techs = [ [ "Marisol Quillen", "(206) 555-0121" ], [ "Teodor Brindle", "(303) 555-0134" ], [ "Priya Hallowell", "(512) 555-0158" ] ].map do |name, ph|
  t = company.technicians.find_or_initialize_by(name: name)
  t.phone = ph
  t.email = "#{name.split.first.downcase}@example.com"
  t.active = true
  t.save!
  t
end

jobs_rng = Random.new(77)
complaints = {
  "washer" => [ "Won't drain", "Loud banging on spin cycle", "Leaking from the door seal" ],
  "dryer" => [ "Not heating", "Takes two cycles to dry", "Drum squeals" ],
  "refrigerator" => [ "Not cooling", "Ice maker stopped", "Water pooling on the floor" ],
  "range" => [ "Oven won't preheat", "Burner clicks constantly", "Door does not latch" ],
  "dishwasher" => [ "Not draining", "Leaves film on dishes", "Won't start" ],
  "microwave" => [ "Sparks inside", "Turntable stuck" ]
}
brands = %w[Aldwyn Corvane Halbrook Meridell Tarnwick].freeze
today = Time.zone.today
customers = company.customers.where("external_id LIKE 'DEMO-%'").where.not(external_id: "DEMO-0000").order(:external_id).limit(30).to_a
customers.each_with_index do |c, n|
  appliance = complaints.keys[jobs_rng.rand(complaints.size)]
  offset = n - 12                      # spread from 12 days ago to 17 days ahead
  past = offset < 0
  status = past ? (jobs_rng.rand < 0.85 ? "completed" : "cancelled") : (offset.zero? ? "in_progress" : "pending")
  tech = status == "pending" && n.odd? ? nil : techs[n % techs.size]
  job = company.jobs.find_or_initialize_by(notes: "Demo seed job #{format('%02d', n + 1)}")
  next if job.persisted?
  job.assign_attributes(
    customer: c, technician: tech, status: status, appliance_type: appliance, brand: brands[jobs_rng.rand(brands.size)],
    model_number: "MD-#{jobs_rng.rand(1000..9999)}", serial_number: "SN#{jobs_rng.rand(10**7..10**8 - 1)}",
    complaint: complaints[appliance][jobs_rng.rand(complaints[appliance].size)],
    starts_at: Time.zone.local(today.year, today.month, today.day, 8 + jobs_rng.rand(0..8), [ 0, 30 ][jobs_rng.rand(2)]) + offset.days,
    duration_minutes: [ 60, 90, 120 ][jobs_rng.rand(3)]
  )
  if status == "completed"
    job.diagnosis = "Worn component identified and confirmed with a test cycle."
    job.work_performed = "Replaced the failed part, cleaned the area and verified normal operation."
  end
  job.save!
end
puts "Seeded demo technicians: #{techs.size}; demo jobs: #{company.jobs.where("notes LIKE 'Demo seed job%'").count}"
