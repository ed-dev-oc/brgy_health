import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

// Connects to data-controller="admin-testimonial"
export default class extends Controller {
  connect() {
    setTimeout(() => {
      const modal = new bootstrap.Modal(this.element)
      modal.show()
    }, 6000)
  }
}
