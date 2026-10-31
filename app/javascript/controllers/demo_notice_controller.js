import { Controller } from "@hotwired/stimulus"

// "About this demo" modal on a native <dialog> (focus trap, Escape and inert background come from showModal()).
// Auto-opens once when data-demo-notice-auto-value is true and no dismissal is stored; the footer button reopens it.
const KEY = "bsp-demo-notice-dismissed"

export default class extends Controller {
  static targets = ["dialog", "confirm"]
  static values = { auto: Boolean }

  connect() {
    // Close before Turbo snapshots the page so a cached preview never shows an open dialog.
    this.onBeforeCache = () => { if (this.dialogTarget.open) this.dialogTarget.close() }
    document.addEventListener("turbo:before-cache", this.onBeforeCache)
    if (this.autoValue && !this.dismissed) this.open(null)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
    if (this.dialogTarget.open) this.dialogTarget.close()
  }

  get dismissed() {
    try { return localStorage.getItem(KEY) === "1" } catch { return false }
  }

  open(event) {
    if (this.dialogTarget.open) return
    // Return focus to the opener when closed; for auto-open there is none, so focus goes back to <body>.
    this.opener = event ? event.currentTarget : null
    this.dialogTarget.showModal()
    this.confirmTarget.focus()
  }

  dismiss() { this.dialogTarget.close() }

  // Clicks on the ::backdrop target the <dialog> itself; clicks inside land on children.
  backdrop(event) { if (event.target === this.dialogTarget) this.dialogTarget.close() }

  closed() {
    try { localStorage.setItem(KEY, "1") } catch { /* storage unavailable: fine, it will just show again */ }
    if (this.opener && this.opener.isConnected) this.opener.focus()
  }
}
