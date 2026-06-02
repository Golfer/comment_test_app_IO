import CableController from "./cable_controller"

const PING_INTERVAL_MS = 60_000

export default class extends CableController {
  static channelName = "PresenceChannel"

  afterConnect() {
    this.pingTimer = window.setInterval(() => {
      this.subscription?.perform("ping")
    }, PING_INTERVAL_MS)
  }

  disconnect() {
    window.clearInterval(this.pingTimer)
    super.disconnect()
  }

  onReceived(data) {
    if (data.type !== "presence") return
    if (typeof data.user_id !== "number" && typeof data.user_id !== "string") return

    this.updateUserRow(String(data.user_id), Boolean(data.online))
  }

  updateUserRow(userId, online) {
    const row = document.getElementById(`user_${userId}`)
    if (!row) return

    this.togglePresenceSelectors(row, "[data-presence-dot]", online)
    this.togglePresenceSelectors(row, "[data-presence-label]", online)
  }

  togglePresenceSelectors(row, selector, online) {
    row.querySelectorAll(selector).forEach((element) => {
      element.classList.toggle("hidden", !online)
    })
  }
}
