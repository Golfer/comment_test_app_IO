import CableController from "./cable_controller"
import {
  commentElement,
  highlightElement,
  isNearBottom,
  scrollToBottom,
} from "../helpers/dom"

export default class extends CableController {
  static channelName = "CommentsChannel"
  static targets = [ "status", "commentsScroll" ]
  static values = { thread: Number, highlight: Number }

  afterConnect() {
    this.showLiveStatus()
    this.scheduleDeepLinkScroll()
  }

  onReceived(data) {
    if (data.type !== "comment" || !this.hasCommentsScrollTarget) return
    if (isNearBottom(this.commentsScrollTarget)) scrollToBottom(this.commentsScrollTarget)
  }

  showLiveStatus() {
    if (!this.hasStatusTarget) return

    this.statusTarget.classList.remove("hidden")
    this.statusTarget.classList.add("inline-flex")
  }

  scheduleDeepLinkScroll() {
    if (!this.threadValue) return

    const rootEl = commentElement(this.threadValue)
    if (!rootEl) return

    const frame = rootEl.querySelector("turbo-frame")
    if (frame) {
      if (frame.complete) {
        this.scrollToHighlight()
      } else {
        frame.addEventListener("turbo:frame-load", () => this.scrollToHighlight(), { once: true })
      }
    } else if (this.highlightValue) {
      requestAnimationFrame(() => this.scrollToHighlight())
    }
  }

  scrollToHighlight() {
    if (!this.highlightValue) return

    const target = commentElement(this.highlightValue)
    if (target) highlightElement(target)
  }
}
