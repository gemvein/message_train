import { Controller } from "@hotwired/stimulus"

// Opens a <dialog> and points its image at the src/original carried on the
// clicked link's data attributes, replacing the old Bootstrap modal.
export default class extends Controller {
  static targets = ["image"]

  open(event) {
    event.preventDefault()
    const dialog = document.getElementById(event.currentTarget.dataset.lightboxDialogId)
    if (!dialog) return

    const image = dialog.querySelector("[data-lightbox-target~='image']") || dialog.querySelector("img")
    if (image) {
      image.src = event.currentTarget.dataset.lightboxSrc
      image.alt = event.currentTarget.dataset.lightboxAlt || ""
    }

    dialog.showModal()
  }

  close(event) {
    event.target.closest("dialog")?.close()
  }
}
