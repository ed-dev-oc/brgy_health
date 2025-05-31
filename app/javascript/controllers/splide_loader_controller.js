import { Controller } from "@hotwired/stimulus"
import Splide from '@splidejs/splide'

// Connects to data-controller="splide-loader"
export default class extends Controller {
  static targets = ["multipleSlides"]

  connect() {
  }

  multipleSlidesTargetConnected(element) {
    var splide = new Splide(element, {
      type: 'slide',
      drag: 'free',
      perPage: 3,
      perMove: 1,
      breakpoints: {
        1024: {
          perPage: 2,
        },
        768: {
          perPage: 1,
        },
      },
    });

    splide.mount();
  }
}
