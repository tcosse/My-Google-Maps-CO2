import { Controller } from "@hotwired/stimulus"
import JSZip from 'jszip';

export default class extends Controller {
  static targets = ['file']
  connect() {
    console.log('file uploader')
  }

  fileLoaded(event) {
    event.preventDefault()
    console.log('file loaded')
    console.log(this.fileTarget)
    // console.log(JSZip)
    let zip = new JSZip()
    console.log(zip);
    // console.log(zipFile);
    // // more files !
// new_zip.loadAsync(content)
// .then(function(zip) {
//     // you now have every files contained in the loaded zip
//     zip.file("hello.txt").async("string"); // a promise of "Hello World\n"
// });
    // JSZip.loadAsync(this.element.file).then((zip)=> {
    //     // TODO Your code goes here. This is just an example.
    //     console.log(zip)
    // })
  }
}
