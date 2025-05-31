import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nested-attributes-visibility"
export default class extends Controller {
  static targets = ["nestedFormContainer", "selectInputContainer"];

  nestedFormPlaceholder = null;
  selectInputPlaceholder = null;

  connect() {
    if (this.selectInputContainerTarget) {
      this.selectInputPlaceholder = this.selectInputContainerTarget.innerHTML;
    }

    if (this.nestedFormContainerTarget) {
      this.nestedFormPlaceholder = this.nestedFormContainerTarget.innerHTML;
      this.nestedFormContainerTarget.innerHTML = ""
    }
  }

  openForm(event) {
    event.preventDefault();

    if (this.nestedFormContainerTarget) {
      this.nestedFormContainerTarget.classList.remove("d-none")
      this.nestedFormContainerTarget.innerHTML = this.nestedFormPlaceholder
    }

    if (this.selectInputContainerTarget) {
      this.selectInputContainerTarget.classList.add("d-none")

      this.selectInputContainerTarget.innerHTML = ""
    }
  }

  closeForm(event) {
    event.preventDefault();

    if (this.nestedFormContainerTarget) {
      this.nestedFormContainerTarget.classList.add("d-none");

      this.nestedFormContainerTarget.innerHTML = ""
    }

    if (this.selectInputContainerTarget) {
      this.selectInputContainerTarget.classList.remove("d-none")

      this.selectInputContainerTarget.innerHTML = this.selectInputPlaceholder
    }
  }
}
