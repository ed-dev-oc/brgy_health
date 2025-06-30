import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="issue-report"
export default class extends Controller {
  connect() {
    this.issueTypeCardActiveState()
  }

  issueTypeSelected(event) {
    const parentElement = event.target.closest(".card")
    const selectedType = parentElement.dataset['type']
    const radioButton = this.element.querySelector(`#${selectedType}`)

    radioButton.checked = true
    this.issueTypeCardActiveState()
  }

  issueTypeCardActiveState() {
    this.element.querySelectorAll('.issue-type-card').forEach(card => {
      card.classList.remove("border-primary", "border-2")
    })

    this.element.querySelectorAll("input[type='radio']").forEach(radio => {
      if (radio.checked) {
        radio.nextElementSibling.classList.add("border-primary", "border-2")
      }
    })
  }
}
