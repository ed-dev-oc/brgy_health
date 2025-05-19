import { Controller } from "@hotwired/stimulus"
import { Loader } from '@googlemaps/js-api-loader';

// Connects to data-controller="google-map-api"
export default class extends Controller {
  static values = {
    apiKey: String,
    lat: Number,
    lng: Number
  }

  static targets = ["map"]

  connect() {
    const loader = new Loader({
      apiKey: this.apiKeyValue,
      version: 'weekly',
    });

    loader.load().then(() => {
      var myLatLng = new google.maps.LatLng(
        this.latValue,
        this.lngValue
      );

      var mapProp = {
        center: myLatLng,
        zoom: 20,
      };

      var map = new google.maps.Map(
        this.element,
        mapProp
      );

      var marker = new google.maps.Marker({
        position: myLatLng,
      });

      marker.setMap(map);
    });
  }
}
