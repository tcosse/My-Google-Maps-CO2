import "@popperjs/core"
import "bootstrap"
import { Application } from "@hotwired/stimulus"
// import "chartkick"
// import "Chart.bundle"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
