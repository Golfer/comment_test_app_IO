import { Controller } from "@hotwired/stimulus"

const INTERACTIVE_SELECTOR = "button, form, textarea, input, a"

export default class extends Controller {
  static targets = [ "frame", "openButton", "hint" ]
  static values = { url: String, open: { type: Boolean, default: false } }

  connect() {
    this.onFrameLoad = this.onFrameLoad.bind(this)
    if (!this.hasFrameTarget) return

    this.frameTarget.addEventListener("turbo:frame-load", this.onFrameLoad)
    if (this.openValue && !this.frameTarget.src) {
      this.frameTarget.src = this.urlValue
    } else if (this.openValue && this.frameTarget.complete) {
      this.markOpen()
    }
  }

  disconnect() {
    this.frameTarget?.removeEventListener("turbo:frame-load", this.onFrameLoad)
  }

  open(event) {
    const fromOpenButton = event?.target?.closest?.("[data-thread-open]")
    if (!fromOpenButton && event?.target?.closest?.(INTERACTIVE_SELECTOR)) return
    if (!this.hasFrameTarget || this.openValue) return

    this.frameTarget.src = this.urlValue
  }

  onFrameLoad(event) {
    if (event.target !== this.frameTarget) return
    this.markOpen()
  }

  markOpen() {
    this.openValue = true
    this.element.classList.add("ring-2", "ring-indigo-200")
    if (this.hasOpenButtonTarget) this.openButtonTarget.classList.add("hidden")

    if (this.hasHintTarget) {
      this.hintTarget.textContent = "Thread open"
      this.hintTarget.classList.remove("text-gray-500")
      this.hintTarget.classList.add("font-medium", "text-green-700")
    }
  }
}
