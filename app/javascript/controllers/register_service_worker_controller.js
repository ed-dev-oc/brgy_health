import { Controller } from "@hotwired/stimulus"
import { FetchRequest } from '@rails/request.js'

// Connects to data-controller="register-service-worker"
export default class extends Controller {
  static values = {
    publicKey: Array,
    url: String,
    pushSubscriptionsUrl: String
  }

  connect() {
    window.vapidPublicKey = new Uint8Array(this.publicKeyValue)

    if ("Notification" in window) {
      Notification.requestPermission().then((permission) => {
        if (permission === "granted") {
          // If permission is granted, register the service worker
          this.registerServiceWorker();
        } else if (permission === "denied") {
          console.warn("User rejected to allow notifications.");
        } else {
          console.warn("User still didn't give an answer about notifications.");
        }
      });
    } else {
      console.warn("Push notifications not supported.");
    }
  }

  registerServiceWorker() {
    // Check if the browser supports service workers
    if ("serviceWorker" in navigator) {
      // Register the service worker script (service_worker.js)
      navigator.serviceWorker
        .register(this.urlValue)
        .then((serviceWorkerRegistration) => {
          // Check if a subscription to push notifications already exists
          serviceWorkerRegistration.pushManager
            .getSubscription()
            .then((existingSubscription) => {
              if (!existingSubscription) {
                // If no subscription exists, subscribe to push notifications
                serviceWorkerRegistration.pushManager
                  .subscribe({
                    userVisibleOnly: true,
                    applicationServerKey: window.vapidPublicKey
                  })
                  .then((subscription) => {
                    // Save the subscription on the server
                    this.saveSubscription(subscription);
                  });
              }
            });
        })
        .catch((error) => {
          console.error("Error during registration Service Worker:", error);
        });
    }
  }

  async saveSubscription(subscription) {
    // Extract necessary subscription data
    const endpoint = subscription.endpoint;

    const p256dh = btoa(
      String.fromCharCode.apply(
        null,
        new Uint8Array(subscription.getKey("p256dh"))
      )
    );
    const auth = btoa(
      String.fromCharCode.apply(
        null,
        new Uint8Array(subscription.getKey("auth"))
      )
    );

    const request = new FetchRequest("post", this.pushSubscriptionsUrlValue,
      {
        body: JSON.stringify({ push_subscription: { endpoint, p256dh, auth } }),
        contentType: "application/json",
      }
    );

    const response = await request.perform()

    if (response.ok) {
      const body = await response.text
    }
  }
}
