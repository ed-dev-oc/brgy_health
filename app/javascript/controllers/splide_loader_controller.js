import { Controller } from "@hotwired/stimulus"
import Splide from '@splidejs/splide'

// Connects to data-controller="splide-loader"
export default class extends Controller {
  static targets = ["multipleSlides", "mainSlides", "thumbnailSlides", "smallSlides"]

  connect() {
  }

  multipleSlidesTargetConnected(element) {
    var splide = new Splide(element, {
      type: 'slide',
      drag: 'free',
      perPage: 3,
      perMove: 1,
      padding: '1rem',
      gap: '1rem',
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

  mainSlidesTargetConnected(element) {
    this.main = new Splide(element, {
      type: 'fade',
      heightRatio: 0.3,
      pagination: false,
      arrows: false,
      cover: true,
      padding: 0,
    });

    this.main.mount();
  }

  thumbnailSlidesTargetConnected(element) {
    var thumbnails = new Splide(element, {
      rewind: true,
      fixedWidth: 104,
      fixedHeight: 58,
      isNavigation: true,
      gap: 10,
      focus: 'left',
      padding: '1em',
      pagination: false,
      cover: true,
      dragMinThreshold: {
        mouse: 4,
        touch: 10,
      },
      breakpoints: {
        640: {
          fixedWidth: 66,
          fixedHeight: 38,
        },
      },
    });

    thumbnails.mount();

    if (this.hasMainSlidesTarget && this.main) {
      this.main.sync(thumbnails);
    }
  }

  smallSlidesTargetConnected(element) {
    var splide = new Splide(element, {
      type: 'slide',
      drag: 'free',
      fixedWidth: 150,
      fixedHeight: 100,
      perPage: 3,
      perMove: 1,
      padding: '1rem',
      breakpoints: {
        1024: {
          perPage: 4,
        },
        768: {
          perPage: 3,
        },
      },
    });

    splide.mount();
  }
}
