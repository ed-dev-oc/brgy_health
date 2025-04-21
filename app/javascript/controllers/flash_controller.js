import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    this.element.style.animation = "fade-in-and-out 4s"
    setTimeout(() => {
      this.element.remove()
    }, 6000);
  }

  close_message() {
    this.element.remove()
  }
}
