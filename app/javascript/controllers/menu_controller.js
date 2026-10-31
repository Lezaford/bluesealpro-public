import { Controller } from "@hotwired/stimulus"

// Disclosure / dropdown: data-controller="menu"
//   button -> data-menu-target="button" data-action="menu#toggle"
//   panel  -> data-menu-target="panel" (hidden by default)
// Closes on outside click, Escape (returning focus to the button), and Turbo navigation.
export default class extends Controller {
  static targets = ["button", "panel"]

  connect() {
    this.onDocClick = (e) => { if (!this.element.contains(e.target)) this.close() }
    this.onKey = (e) => { if (e.key === "Escape" && this.isOpen) { this.close(); this.buttonTarget.focus() } }
    this.onOther = (e) => { if (e.detail !== this.element) this.close() }
    document.addEventListener("menu:open", this.onOther)
    document.addEventListener("click", this.onDocClick)
    document.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    document.removeEventListener("menu:open", this.onOther)
    document.removeEventListener("click", this.onDocClick)
    document.removeEventListener("keydown", this.onKey)
  }

  get isOpen() { return !this.panelTarget.classList.contains("hidden") }

  toggle() { this.isOpen ? this.close() : this.open() }

  open() {
    // Only one open menu at a time.
    document.dispatchEvent(new CustomEvent("menu:open", { detail: this.element }))
    this.panelTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }
}
