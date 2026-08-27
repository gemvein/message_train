import { Controller } from "@hotwired/stimulus"

// Replaces the old Bloodhound/typeahead.js recipient picker with a plain
// <input> + <datalist>, backed by the same participants JSON endpoint.
export default class extends Controller {
  static targets = ["input", "list"]
  static values = { url: String }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()
    if (query.length < 1) return

    this.timeout = setTimeout(() => this.fetchSuggestions(query), 150)
  }

  async fetchSuggestions(query) {
    const url = `${this.urlValue}?query=${encodeURIComponent(query)}`
    const response = await fetch(url, { headers: { Accept: "application/json" } })
    if (!response.ok) return

    const data = await response.json()
    this.listTarget.innerHTML = (data.participants || [])
      .map((participant) => `<option value="${participant.slug}"></option>`)
      .join("")
  }
}
