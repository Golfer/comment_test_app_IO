import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form" ]
  static values = { delay: { type: Number, default: 400 } }

  connect() {
    this.timer = null
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  queueSearch() {
    if (!this.hasFormTarget) return

    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.formTarget.requestSubmit(), this.delayValue)
  }

  submitNow(event) {
    event.preventDefault()
    if (!this.hasFormTarget) return

    clearTimeout(this.timer)
    this.formTarget.requestSubmit()
  }
}
