import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modelNumber", "serialNumber"]

  normalizeModelNumber() {
    this.normalizeField(this.modelNumberTarget)
  }

  normalizeSerialNumber() {
    this.serialNumberTarget.value = this.normalizeValue(this.serialNumberTarget.value)
  }

  normalizeField(field) {
    field.value = this.normalizeValue(field.value)
  }

  normalizeValue(value) {
    return value
      .trim()                           // Remove leading/trailing whitespace
      .toUpperCase()                    // Convert to uppercase
      .replace(/\s+/g, " ")            // Collapse multiple spaces to single space
  }
}
