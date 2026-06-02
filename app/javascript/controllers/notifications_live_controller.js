import CableController from "./cable_controller"
import { formatBadgeCount } from "../helpers/dom"

export default class extends CableController {
  static channelName = "NotificationsChannel"
  static targets = [ "badge" ]
  static values = { unread: { type: Number, default: 0 } }

  afterConnect() {
    this.renderBadge(this.unreadValue)
  }

  onReceived(data) {
    if (data.type !== "notification") return
    const unreadCount = Number(data.unread_count)
    if (!Number.isFinite(unreadCount)) return

    this.unreadValue = unreadCount
    this.renderBadge(unreadCount)
  }

  renderBadge(count) {
    if (!this.hasBadgeTarget) return

    if (count <= 0) {
      this.badgeTarget.classList.add("hidden")
      this.badgeTarget.textContent = ""
      return
    }

    this.badgeTarget.textContent = formatBadgeCount(count)
    this.badgeTarget.classList.remove("hidden")
  }
}
