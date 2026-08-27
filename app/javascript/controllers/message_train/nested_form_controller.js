import { Controller } from "@hotwired/stimulus"

// Replaces cocoon's add/remove-nested-fields helpers. Expects a <template>
// target holding one blank fields_for row (child_index: "NEW_RECORD"), and
// wraps each row (new or persisted) in an element carrying the
// "destroyField" target so removal can either drop the DOM node (new,
// unsaved rows) or flag it for destruction on submit (persisted rows).
export default class extends Controller {
  static targets = ["template", "rows"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(
      /NEW_RECORD/g,
      new Date().getTime()
    )
    this.rowsTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    const message = event.currentTarget.dataset.confirm
    if (message && !window.confirm(message)) return

    const row = event.currentTarget.closest("[data-message-train--nested-form-target='row']")
    if (!row) return

    const destroyField = row.querySelector("[data-message-train--nested-form-target='destroyField']")
    if (destroyField) {
      destroyField.value = "1"
      row.hidden = true
    } else {
      row.remove()
    }
  }
}
