import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu"
export default class extends Controller {
  static targets = [ "mobileMenu", "desktopMenu" ]

  toggleDesktopMenu(event) {
    const hidden = this.desktopMenuTarget.classList.toggle("hidden");
    event.currentTarget.setAttribute("aria-expanded", String(!hidden));
  }

  toggleMobileMenu(event) {
    const hidden = this.mobileMenuTarget.classList.toggle("hidden");
    event.currentTarget.setAttribute("aria-expanded", String(!hidden));
  }
}
