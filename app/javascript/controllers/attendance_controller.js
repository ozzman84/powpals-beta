import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selection"]

  identify(event) {
    this.element.classList.toggle("attendance-expanded")
    this.selectionTarget.textContent = event.currentTarget.getAttribute("aria-label")
  }
}
