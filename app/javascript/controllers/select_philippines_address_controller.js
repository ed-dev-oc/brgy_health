import { Controller } from "@hotwired/stimulus"
import selectPhilippinesAddress from "select-philippines-address"

// Connects to data-controller="select-philippines-address"
export default class extends Controller {
  static targets = ["regionInput", "provinceInput", "cityInput", "barangayInput"]

  static values = {
    regionCode: String,
    provinceCode: String,
    cityCode: String,
    brgyCode: String,
    regionName: String,
    provinceName: String,
    cityName: String,
    brgyName: String
  }

  async regionInputTargetConnected() {
    console.log("Visited")
    await this.setRegionOptions()
    await this.setProvinceOptions()
    await this.setCityOptions()
    await this.setBarangayOptions()
  }

  async regionInputChanged(event) {
    this.regionNameValue = event.target.value
    await this.setRegionOptions()
    await this.setProvinceOptions()
    await this.setCityOptions()
    await this.setBarangayOptions()
  }

  async provinceInputChanged(event) {
    this.provinceNameValue = event.target.value
    await this.setProvinceOptions()
    await this.setCityOptions()
    await this.setBarangayOptions()
  }

  async cityInputChanged(event) {
    this.cityNameValue = event.target.value
    await this.setCityOptions()
    await this.setBarangayOptions()
  }

  async barangayInputChanged(event) {
    this.brgyNameValue = event.target.value
    await this.setBarangayOptions()
  }

  async setRegionOptions() {
    const { regions } = selectPhilippinesAddress;

    this.regionInputTarget.innerHTML = `<option value="">Select Region</option>`

    const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));
    await sleep(200);

    await regions().then((region) =>
      region.forEach((r) => {
        const option = document.createElement("option");
        option.value = r.region_name;
        option.innerHTML = r.region_name;

        if (r.region_name == this.regionNameValue) {
          this.regionCodeValue = r.region_code
          option.selected = true
        };

        this.regionInputTarget.appendChild(option);
      })
    );
  }

  async setProvinceOptions() {
    const { provinces } = selectPhilippinesAddress;

    this.provinceInputTarget.innerHTML = `<option value="">Select Province</option>`
    const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));
    await sleep(200);

    await provinces(`${this.regionCodeValue}`).then((province) => {
      province.forEach((p) => {
        const option = document.createElement("option");
        option.value = p.province_name;
        option.innerHTML = p.province_name;

        if (p.province_name == this.provinceNameValue) {
          this.provinceCodeValue = p.province_code
          option.selected = true
        }

        this.provinceInputTarget.appendChild(option);
      })
    });
  }

  async setCityOptions() {
    const { cities } = selectPhilippinesAddress;

    this.cityInputTarget.innerHTML = `<option value="">Select City</option>`

    const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));
    await sleep(200);

    await cities(`${this.provinceCodeValue}`).then((city) => {
      city.forEach((c) => {
        const option = document.createElement("option");
        option.value = c.city_name;
        option.innerHTML = c.city_name;

        if (c.city_name == this.cityNameValue) {
          this.cityCodeValue = c.city_code
          option.selected = true
        }

        this.cityInputTarget.appendChild(option);
      })
    });
  }

  async setBarangayOptions() {
    const { barangays } = selectPhilippinesAddress;

    this.barangayInputTarget.innerHTML = `<option value="">Select Barangay</option>`

    const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));
    await sleep(200);

    await barangays(`${this.cityCodeValue}`).then((brgy) => {
      brgy.forEach((b) => {
        const option = document.createElement("option");
        option.value = b.brgy_name;
        option.innerHTML = b.brgy_name;

        if (b.brgy_name == this.brgyNameValue) {
          this.brgyCodeValue = b.brgy_code
          option.selected = true
        }

        this.barangayInputTarget.appendChild(option);
      })
    });
  }
}
