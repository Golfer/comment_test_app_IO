import { Controller } from "@hotwired/stimulus"
import { refreshThreadFrame, threadFrameForReplyForm } from "../helpers/dom"

// Enter submits the form; Shift+Enter keeps a newline in textareas.
export default class extends Controller {
  submitOnEnter(event) {
    if (event.key !== "Enter" || event.shiftKey) return

    const field = event.target
    if (!("value" in field) || field.value.trim() === "") return

    const form = this.formElement()
    if (!form) return

    event.preventDefault()
    form.requestSubmit()
  }

  resetOnSuccess(event) {
    if (!event.detail?.success) return

    const form = this.formElement()
    if (!form) return

    form.reset()

    const parentId = form.querySelector('input[name="comment[parent_id]"]')?.value
    if (!parentId) return

    const frame = threadFrameForReplyForm(form)
    requestAnimationFrame(() => refreshThreadFrame(frame))
  }

  formElement() {
    return this.element instanceof HTMLFormElement ? this.element : null
  }
}
