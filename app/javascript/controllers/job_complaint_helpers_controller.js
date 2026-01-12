import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["complaintTextarea"]

  connect() {
    // Initialize controller
  }

  addComplaint(event) {
    event.preventDefault()
    const button = event.currentTarget
    const text = button.dataset.complaintText

    const textarea = this.complaintTextareaTarget
    const currentValue = textarea.value.trim()

    // Append text with newline if textarea has existing content
    if (currentValue.length > 0) {
      textarea.value = currentValue + "\n" + text
    } else {
      textarea.value = text
    }

    // Focus textarea and trigger change event
    textarea.focus()
    textarea.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
