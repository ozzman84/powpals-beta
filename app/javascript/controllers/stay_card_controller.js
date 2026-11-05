import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "editor", "toggle"]

  toggle() {
    this.menuTarget.hidden = !this.menuTarget.hidden
    this.toggleTarget.setAttribute("aria-expanded", String(!this.menuTarget.hidden))
  }

  close(event) {
    if (event?.type === "click" && this.element.contains(event.target)) return
    if (!this.hasMenuTarget || this.menuTarget.hidden) return
    this.menuTarget.hidden = true
    if (event?.type === "keydown") this.toggleTarget.focus()
    this.toggleTarget.setAttribute("aria-expanded", "false")
  }

  edit() {
    this.close()
    this.editorTarget.hidden = false
    this.editorTarget.querySelector("select").focus()
  }

  cancel() {
    this.editorTarget.querySelector("form").reset()
    this.editorTarget.hidden = true
    this.toggleTarget.focus()
  }
}
