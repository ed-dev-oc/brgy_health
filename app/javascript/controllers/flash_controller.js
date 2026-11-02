import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    this.autoCloseTimeout = setTimeout(() => {
      this.close_message()
    }, 6000)
  }

  disconnect() {
    if (this.autoCloseTimeout) {
      clearTimeout(this.autoCloseTimeout)
    }
    if (this.removeTimeout) {
      clearTimeout(this.removeTimeout)
    }
  }

  close_message(event) {
    if (event) {
      event.stopPropagation()
    }
    if (this.autoCloseTimeout) {
      clearTimeout(this.autoCloseTimeout)
    }
    this.element.classList.add("flash-closing")
    this.removeTimeout = setTimeout(() => {
      this.element.remove()
    }, 220)
  }
}
