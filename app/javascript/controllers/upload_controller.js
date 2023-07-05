import { Controller } from "@hotwired/stimulus"
import JSZip from 'jszip';

export default class extends Controller {
  static targets = ['file']
  connect() {
    console.log('file uploader')
  }

  fileLoaded (event) {
    event.preventDefault()
    const zipfile = this.element.files[0]
    const activity_data = get_zipped_data(zipfile)
    console.log(activity_data)
  }
}

function get_zipped_data(zipfile) {
  let activity_data = []
  JSZip.loadAsync(zipfile).then((unzipped)=> {
      // TODO Your code goes here. This is just an example.
    unzipped.forEach((filepath, zipentry) => {
      // console.log(zipentry)
      const regex = /Semantic Location History\/\d{4}\/(\d{4})_([A-Z]+)\.json/;
      if (regex.test(filepath)) {
        // console.log(filepath)
        var matches = filepath.match(regex)
        var year = matches[1]
        var month = matches[2]
        zipentry.async('string').then( (filedata) => {
          filedata = JSON.parse(filedata)
          filedata.timelineObjects.forEach((history_item) => {
            if ('activitySegment' in history_item) {
              activity_data.push({
                year: year,
                month: month,
                confidence: history_item.activitySegment.confidence,
                activity: history_item.activitySegment.activityType,
                distance: history_item.activitySegment.distance,
                duration: history_item.activitySegment.duration,
                startLocation: {latitudeE7: history_item.activitySegment.startLocation.latitudeE7, longitudeE7: history_item.activitySegment.startLocation.longitudeE7},
                endLocation: {latitudeE7: history_item.activitySegment.endLocation.latitudeE7, longitudeE7: history_item.activitySegment.endLocation.longitudeE7},
              })
            }
          })
        })
      }
    })
  })
  return activity_data
}

  function groupBy(data, key){
    return data.reduce((acc, cur) => {
      acc[cur[key]] = acc[cur[key]] || []; // if the key is new, initiate its value to an array, otherwise keep its own array value
      acc[cur[key]].push(cur);
      return acc;
    }, [])
  }


function create_bar_chart(data) {

}
