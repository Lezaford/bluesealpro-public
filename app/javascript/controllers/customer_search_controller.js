import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "customerId"]
  static values = { debounceDelay: 200 }

  connect() {
    this.debounceTimer = null
    this.selectedCustomerId = this.customerIdTarget.value

    // Add outside click listener
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)

    // If editing with a selected customer, fetch and display it
    if (this.selectedCustomerId) {
      this.fetchAndDisplayCustomer(this.selectedCustomerId)
    }
  }

  disconnect() {
    // Clean up outside click listener
    document.removeEventListener("click", this.handleClickOutside)
    clearTimeout(this.debounceTimer)
  }

  handleInput(event) {
    const query = event.target.value.trim()

    // Clear any existing debounce timer
    clearTimeout(this.debounceTimer)

    // If query is cleared, show a fresh search state
    if (query.length === 0) {
      this.debounceTimer = setTimeout(() => {
        this.searchCustomers("")
      }, this.debounceDelayValue)
      return
    }

    // Debounce search
    this.debounceTimer = setTimeout(() => {
      this.searchCustomers(query)
    }, this.debounceDelayValue)
  }

  searchCustomers(query) {
    const url = new URL("/customers/search", window.location.origin)
    url.searchParams.set("q", query)

    fetch(url.toString(), {
      method: "GET",
      headers: {
        "Accept": "application/json"
      }
    })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then(customers => {
        this.renderDropdown(customers, query)
      })
      .catch(error => {
        console.error("Customer search failed:", error)
        this.dropdownTarget.innerHTML = `<div class="px-3 py-2 text-slate-400 text-sm">Error loading customers</div>`
        this.dropdownTarget.classList.remove("hidden")
      })
  }

  renderDropdown(customers, query) {
    if (customers.length === 0) {
      this.dropdownTarget.innerHTML = `
        <div class="px-3 py-2 text-slate-400 text-sm">No customers found</div>
      `
      this.dropdownTarget.classList.remove("hidden")
      return
    }

    const html = customers.map(customer => `
      <button type="button" class="w-full text-left px-3 py-2 hover:bg-slate-700 transition customer-option" 
        data-action="click->customer-search#selectCustomer"
        data-customer-id="${this.escapeHtml(customer.id)}"
        data-customer-name="${this.escapeHtml(customer.name)}"
        data-customer-email="${this.escapeHtml(customer.email)}">
        <div class="font-medium text-slate-100">${this.highlightMatches(customer.name, query)}</div>
        <div class="text-xs text-slate-400">${this.highlightMatches(customer.email, query)}</div>
      </button>
    `).join("")

    this.dropdownTarget.innerHTML = html
    this.dropdownTarget.classList.remove("hidden")
  }

  selectCustomer(event) {
    event.preventDefault()

    const button = event.currentTarget
    const customerId = button.dataset.customerId
    const customerName = button.dataset.customerName
    const customerEmail = button.dataset.customerEmail

    this.selectedCustomerId = customerId
    this.customerIdTarget.value = customerId

    // Update input display
    this.inputTarget.value = ""
    this.displaySelectedCustomer(customerName, customerEmail)

    // Close dropdown
    this.dropdownTarget.classList.add("hidden")
  }

  displaySelectedCustomer(name, email) {
    // Remove any existing chip
    const existingChip = this.element.querySelector(".customer-chip")
    if (existingChip) {
      existingChip.remove()
    }

    // Create chip
    const chip = document.createElement("div")
    chip.className = "customer-chip bg-blue-600/30 border border-blue-500 text-blue-200 px-3 py-1 rounded flex items-center gap-2 text-sm"
    chip.innerHTML = `
      <span>${this.escapeHtml(name)}</span>
      <button type="button" class="remove-customer text-blue-300 hover:text-blue-100 font-bold"
        data-action="click->customer-search#clearSelection">×</button>
    `

    // Insert before input
    this.inputTarget.parentElement.insertBefore(chip, this.inputTarget)
  }

  clearSelection(event) {
    event.preventDefault()

    this.selectedCustomerId = null
    this.customerIdTarget.value = ""

    // Remove chip
    const chip = this.element.querySelector(".customer-chip")
    if (chip) {
      chip.remove()
    }

    // Clear input
    this.inputTarget.value = ""
    this.inputTarget.focus()

    // Close dropdown
    this.dropdownTarget.classList.add("hidden")
  }

  handleFocus(event) {
    // Show dropdown on focus if input is empty or no customer selected
    if (!this.selectedCustomerId && this.inputTarget.value.trim().length === 0) {
      this.searchCustomers("")
    } else if (this.dropdownTarget.classList.contains("hidden")) {
      this.dropdownTarget.classList.remove("hidden")
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.dropdownTarget.classList.add("hidden")
    }
  }

  handleClickOutside(event) {
    // Check if click was outside the entire component
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.add("hidden")
    }
  }

  // Utility: fetch and display a customer by ID
  fetchAndDisplayCustomer(customerId) {
    fetch(`/customers/${customerId}.json`, {
      method: "GET",
      headers: {
        "Accept": "application/json"
      }
    })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then(customer => {
        this.displaySelectedCustomer(customer.name, customer.email)
      })
      .catch(error => {
        console.error("Failed to fetch customer:", error)
      })
  }

  // Highlight matched characters in search results
  highlightMatches(str, query) {
    if (!query) return this.escapeHtml(str)

    const search = query.toLowerCase()
    let result = ""
    let searchIdx = 0

    for (let i = 0; i < str.length; i++) {
      if (searchIdx < search.length && search[searchIdx] === str[i].toLowerCase()) {
        result += `<span class="bg-blue-500 text-white font-semibold">${this.escapeHtml(str[i])}</span>`
        searchIdx++
      } else {
        result += this.escapeHtml(str[i])
      }
    }

    return result
  }

  // Escape HTML to prevent XSS
  escapeHtml(text) {
    const map = {
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#039;"
    }
    return text.replace(/[&<>"']/g, m => map[m])
  }
}
