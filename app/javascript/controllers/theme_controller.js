import { Controller } from "@hotwired/stimulus"

// Light/dark toggle. The initial class is set by an inline script in <head> to avoid a flash.
export default class extends Controller {
  static targets = ["label", "sun", "moon"]

  connect() { this.render() }

  toggle() {
    const root = document.documentElement
    root.classList.toggle("dark")
    localStorage.setItem("bsp-theme", root.classList.contains("dark") ? "dark" : "light")
    this.render()
  }

  render() {
    const dark = document.documentElement.classList.contains("dark")
    this.element.setAttribute("aria-pressed", String(dark))
    this.element.setAttribute("aria-label", dark ? "Switch to light theme" : "Switch to dark theme")
    if (this.hasSunTarget) this.sunTarget.classList.toggle("hidden", !dark)
    if (this.hasMoonTarget) this.moonTarget.classList.toggle("hidden", dark)
  }
}
