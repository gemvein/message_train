import { Controller } from "@hotwired/stimulus"

// Keeps a <details> element's real `open` attribute in sync with a
// breakpoint, so it's a genuinely-open element on wide viewports (not a
// closed one with CSS fighting to reveal its content - a closed <details>'s
// width computation doesn't reliably respond to display overrides on its
// children, even with an explicit `width: max-content`).
export default class extends Controller {
  static values = { breakpoint: { type: String, default: "48rem" } }

  connect() {
    this.mediaQuery = window.matchMedia(`(min-width: ${this.breakpointValue})`)
    this.sync = this.sync.bind(this)
    this.mediaQuery.addEventListener("change", this.sync)
    this.sync()
  }

  disconnect() {
    this.mediaQuery.removeEventListener("change", this.sync)
  }

  sync() {
    this.element.open = this.mediaQuery.matches
  }
}
