import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]

  add() {
    if (this.listTarget.children.length >= 10) return
    this.listTarget.append(this.templateTarget.content.cloneNode(true))
    this.listTarget.lastElementChild.querySelector("input").focus()
  }
}
