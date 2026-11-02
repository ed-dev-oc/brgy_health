import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

// Fix default marker icon URLs when bundled by esbuild
delete L.Icon.Default.prototype._getIconUrl

L.Icon.Default.mergeOptions({
  iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
  iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
})

// Connects to data-controller="leaflet"
export default class extends Controller {
  static targets = ["map"]

  static values = {
    lat: { type: Number, default: 14.5995 },
    lng: { type: Number, default: 120.9842 },
    zoom: { type: Number, default: 16 },
    title: { type: String, default: "" },
    apiKey: String // Kept for backward compatibility if passed
  }

  connect() {
    const lat = this.hasLatValue && !isNaN(this.latValue) && this.latValue !== 0 ? this.latValue : 14.5995
    const lng = this.hasLngValue && !isNaN(this.lngValue) && this.lngValue !== 0 ? this.lngValue : 120.9842
    const zoom = this.hasZoomValue && this.zoomValue ? this.zoomValue : 16

    const container = this.hasMapTarget ? this.mapTarget : this.element

    this.map = L.map(container).setView([lat, lng], zoom)

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener noreferrer">OpenStreetMap</a> contributors'
    }).addTo(this.map)

    this.marker = L.marker([lat, lng]).addTo(this.map)

    if (this.hasTitleValue && this.titleValue) {
      this.marker.bindPopup(this.titleValue).openPopup()
    }

    // Leaflet needs to recalculate dimensions if rendered in dynamic containers
    setTimeout(() => {
      if (this.map) {
        this.map.invalidateSize()
      }
    }, 200)
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  latValueChanged() {
    this.updatePosition()
  }

  lngValueChanged() {
    this.updatePosition()
  }

  updatePosition() {
    if (!this.map || !this.marker) return
    const lat = this.latValue
    const lng = this.lngValue
    if (!isNaN(lat) && !isNaN(lng)) {
      this.map.setView([lat, lng], this.zoomValue || 16)
      this.marker.setLatLng([lat, lng])
    }
  }
}
