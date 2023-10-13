// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "controllers"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

window.initMap = function() {
    // const event = new Event("MapLoaded")
    // event.initEvent("map-loaded", true, true);
    // window.dispatchEvent(event)
    console.log("Map initialized");
}

// let map;

// async function initMap() {
//     console.log("Map initialized");
//     // const { Map } = await google.maps.importLibrary("maps");

//     // map = new Map(document.getElementById("map"), {
//     //     center: { lat: -34.397, lng: 150.644 },
//     //     zoom: 8,
//     // });
// }



