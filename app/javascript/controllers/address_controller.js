import { Controller } from "@hotwired/stimulus";
import initMap from "application"

export default class extends Controller {
    static targets = [
        'input',
        'line1',
        'line2',
        'city',
        'state',
        'postal_code',
        'country'
    ]
    connect() {
        console.log("Address controller is connected");
    }

    initGoogle() {
        console.log('Google maps is initialized and the address controller knows about it')
        console.log(google)
        this.autocomplete = new google.maps.places.Autocomplete(this.inputTarget, {
            fields: ["address_components", "geometry"],
            types: ["address"],
        })
        this.autocomplete.addListener('place_changed', this.placedSelected.bind(this))
    }

    initMap() {
        console.log(google)
    }

    placedSelected() {
        const place = this.autocomplete.getPlace();

        for (const component of place.address_components) {
            const componentType = component.types[0];

            switch (componentType) {

                case "street_number": {
                    this.line1Target.value += `${component.long_name} ${this.line1Target.value}`;
                    break;
                }

                case "route": {
                    this.line1Target.value += component.short_name;
                    break;
                }
            }
        }
    }
    
    initMap
}