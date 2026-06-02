import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { targetId: String }

  toggle() {
    const el = document.getElementById(this.targetIdValue)
    if (el) el.classList.toggle("hidden")
  }
}
