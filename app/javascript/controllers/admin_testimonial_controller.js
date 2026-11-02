import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

// Connects to data-controller="admin-testimonial"
export default class extends Controller {
  connect() {
    if (localStorage.getItem("brgy_health_testimonial_dismissed") === "true") {
      return
    }

    this.handleDismiss = () => {
      localStorage.setItem("brgy_health_testimonial_dismissed", "true")
    }
    this.element.addEventListener("hidden.bs.modal", this.handleDismiss)

    this.timeoutId = setTimeout(() => {
      const modal = new bootstrap.Modal(this.element)
      modal.show()
    }, 6000)
  }

  disconnect() {
    clearTimeout(this.timeoutId)
    if (this.handleDismiss) {
      this.element.removeEventListener("hidden.bs.modal", this.handleDismiss)
    }
  }
}
