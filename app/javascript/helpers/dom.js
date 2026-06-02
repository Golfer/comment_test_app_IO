export function commentElement(id) {
  return document.getElementById(`comment_${id}`)
}

export function isNearBottom(element, threshold = 150) {
  return element.scrollHeight - element.scrollTop - element.clientHeight < threshold
}

export function scrollToBottom(element) {
  requestAnimationFrame(() => {
    element.scrollTop = element.scrollHeight
  })
}

export function highlightElement(element, { duration = 3000 } = {}) {
  element.scrollIntoView({ behavior: "smooth", block: "center" })
  element.classList.add("ring-2", "ring-indigo-400", "bg-indigo-50")

  window.setTimeout(() => {
    element.classList.remove("ring-2", "ring-indigo-400", "bg-indigo-50")
  }, duration)
}

export function formatBadgeCount(count) {
  return count > 99 ? "99+" : String(count)
}

export function threadFrameForReplyForm(form) {
  const nestedFrame = form.closest('turbo-frame[id$="_replies"]')
  if (nestedFrame) return nestedFrame

  const rootThread = form.closest('[data-controller~="thread"]')
  return rootThread?.querySelector('[data-thread-target="frame"]') ?? null
}

export function refreshThreadFrame(frame) {
  if (!frame) return

  const threadRoot = frame.closest('[data-controller~="thread"]')
  const url = threadRoot?.dataset.threadUrlValue

  if (!frame.src && url) {
    frame.src = url
    return
  }

  if (frame.src) frame.reload()
}
