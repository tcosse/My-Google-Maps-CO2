import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-upload"
export default class extends Controller {
  connect() {
    console.log("file uploader")
  }

  // fileLoaded() {
  //   // console.log('file loaded')
  //   // console.log(this.element.file)

  //   // fetch(url)
  // }

}
