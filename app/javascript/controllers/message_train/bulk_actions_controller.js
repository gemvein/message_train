import { Controller } from "@hotwired/stimulus"

// Replaces message_train.js's jQuery-driven checkbox/mark-all wiring for
// the box listing's bulk actions (select rows, then mark them all at once).
export default class extends Controller {
  static targets = ["checkbox", "checkAll", "markToSet"]

  toggleAll(event) {
    this.checkboxTargets.forEach((box) => { box.checked = event.target.checked })
  }

  selectMatching(event) {
    event.preventDefault()
    event.stopPropagation()
    const selector = event.currentTarget.dataset.selector
    this.checkboxTargets.forEach((box) => {
      box.checked = selector ? box.closest(".message_train_conversation")?.matches(selector) : false
    })
    if (this.hasCheckAllTarget) {
      this.checkAllTarget.checked = selector === ".message_train_conversation"
    }
  }

  markAll(event) {
    event.preventDefault()
    event.stopPropagation()
    const mark = event.currentTarget.dataset.mark
    const form = document.getElementById("box")
    const methodField = form.querySelector('input[name="_method"]')
    if (methodField) {
      methodField.value = ["ignore", "unignore"].includes(mark) ? "delete" : "put"
    }
    this.markToSetTarget.value = mark
    form.requestSubmit()
  }
}
