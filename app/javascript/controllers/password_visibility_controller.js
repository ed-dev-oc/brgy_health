import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="password-visibility"
export default class extends Controller {
  static targets = ["passwordInput", "icon"];

  connect() {
  }

  togglePasswordVisibility() {
    const input = this.passwordInputTarget
    const icon = this.iconTarget

    if (input.getAttribute('type') == 'password') {
      input.setAttribute('type', 'text');
      icon.classList.remove("bi-eye")
      icon.classList.add("bi-eye-slash")
    } else {
      input.setAttribute('type', 'password');
      icon.classList.remove("bi-eye-slash")
      icon.classList.add("bi-eye")
    }
  }
}
