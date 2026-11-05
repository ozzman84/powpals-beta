import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    this.opener = event.currentTarget
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  backdropClose(event) {
    if (event.target !== this.dialogTarget) return
    const rect = this.dialogTarget.getBoundingClientRect()
    if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) this.close()
  }

  restoreFocus() {
    this.opener?.focus()
  }

  disconnect() {
    if (this.hasDialogTarget && this.dialogTarget.open) this.dialogTarget.close()
  }
}
