import { Controller } from "@hotwired/stimulus"
import { subscribeToChannel } from "../channels/cable"

// Shared connect/disconnect lifecycle for Action Cable Stimulus controllers.
export default class CableController extends Controller {
  static get channelName() {
    throw new Error(`${this.name} must define static channelName`)
  }

  connect() {
    this.disconnect()
    this.subscription = subscribeToChannel(this.constructor.channelName, (data) => {
      this.onReceived(data)
    })
    this.afterConnect?.()
  }

  disconnect() {
    this.subscription?.unsubscribe()
    this.subscription = null
  }

  onReceived() {}
}
