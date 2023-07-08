import { Controller } from "@hotwired/stimulus"
import JSZip from 'jszip';
import * as Chartjs from "chart.js";

const monthList = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER']

export default class extends Controller {
  static targets = ['file','chart']

  connect() {
    console.log('file uploader')
    const fruits = new Map([
      ["apples", "hello"],
      ["bananas", 300],
      ["oranges", 200]
    ]);
    const testMap2 = new Map()
    testMap2.set('hello','world')
    console.log(fruits)
    console.log(testMap2)
  }

  fileLoaded(event) {
    event.preventDefault()
    console.log('file loaded')
    const zipfile = this.fileTarget.files[0]
    getZippedData(zipfile).then(data => {
      console.log(data)
      let yearlyActivityDistance = groupAndSumByProperties(data, ["activity", "year"], "distance")
      console.log(yearlyActivityDistance)
      yearlyActivityDistance = cleanData(yearlyActivityDistance)
      console.log(yearlyActivityDistance)
      console.log('minMax',minMax(yearlyActivityDistance))
      const groupedByActivityData = groupByActivity(yearlyActivityDistance)
      console.log(groupedByActivityData)
      console.log(Object.keys(groupedByActivityData))
      console.log(generateChartData(groupedByActivityData))
    });
  }
}

function getZippedData(zipfile) {
  return new Promise((resolve, reject) => {
    let activityData = [];
    JSZip.loadAsync(zipfile).then((unzipped) => {
      const regex = /Semantic Location History\/\d{4}\/(\d{4})_([A-Z]+)\.json/;
      const promises = [];
      unzipped.forEach((filepath, zipentry) => {
        if (regex.test(filepath)) {
          var matches = filepath.match(regex)
          var year = parseInt(matches[1])
          var month = matches[2]
          promises.push(zipentry.async('string').then((filedata) => {
            filedata = JSON.parse(filedata)
            const data = filedata.timelineObjects.reduce((acc, history_item) => {
              if ('activitySegment' in history_item) {
                acc.push({
                    year: year,
                    month: month,
                    confidence: history_item.activitySegment.confidence,
                    activity: history_item.activitySegment.activityType,
                    distance: history_item.activitySegment.distance,
                    duration: history_item.activitySegment.duration,
                    startLocation: { latitudeE7: history_item.activitySegment.startLocation.latitudeE7, longitudeE7: history_item.activitySegment.startLocation.longitudeE7 },
                    endLocation: { latitudeE7: history_item.activitySegment.endLocation.latitudeE7, longitudeE7: history_item.activitySegment.endLocation.longitudeE7 },
                });
              }
              return acc;
            }, []);
            return data;
          }));
        }
      });

      Promise.all(promises)
        .then(results => {
          results.forEach(data => {
            activityData = activityData.concat(data);
          });
          resolve(activityData);
        })
        .catch(reject);
    });
  });
}


// function groupBy(data, key){
//   return data.reduce((acc, cur) => {
//     acc[cur[key]] = acc[cur[key]] || []; // if the key is new, initiate its value to an array, otherwise keep its own array value
//     acc[cur[key]].push(cur);
//     return acc;
//   }, {})
// }

function groupByActivity(data){
  return data.reduce((acc, cur) => {
    acc[cur['activity']] = acc[cur['activity']] || []; // if the key is new, initiate its value to an array, otherwise keep its own array value
    acc[cur['activity']].push({[cur['year']]: cur['distance']});
    return acc;
  }, {})
}

function minMax(data){
  const firstElement = data[0]
  let maxYear = firstElement['year']
  let minYear = firstElement['year']
  data.forEach(element => {
    if (element['year'] > maxYear) {maxYear = element['year']}
    if (element['year'] < minYear) {minYear = element['year']}
  })
  return {min: minYear, max: maxYear}
}

function arrayRange(start, stop) {
  Array.from({ length: (stop - start)}, (value, index) => start + index);
}

function YearlyArray(transportData, minYear, maxYear) {
  const YearlyDataArray = []
  for (let year = minYear; year < (maxYear + 1); year++) {
    if (transportData.hasOwnProperty(year)) {
      YearlyDataArray.push(transportData[year])
    } else {
      YearlyDataArray.push(0)
    }
  }
  return YearlyDataArray
}



// function groupPopertiesandSum(data, property1, property2, propertyToSum){
//   return data.reduce((acc, cur) => {
//     acc[cur[property1]] = acc[cur[property1]] || {}; // if the key is new, initiate its value, other wise keep the value
//     acc[cur[property1]][cur[property2]] = (acc[cur[property1]][cur[property2]] + cur[propertyToSum]) || cur[propertyToSum]; // if the key is new, initiate its value to the property to sum, otherwise keep its own value
//     return acc;
//   }, {})
// }

// function totalDistancesByTransportationAndMonth(data){
//   // This function returns a two layer map
//   // First, lets create an initial Month Map with all its values at 0
//   const initialMap = new Map()
//   monthList.forEach((month)=> initialMap.set(month, 0))
//   return data.reduce((acc, cur) => {
//       acc.set(cur['activity'], acc.get(cur['activity']) || initialMap); // if the key is new, initiate its value, other wise keep the value
//       acc.get(cur['activity']).set(cur['month'],((acc.get(cur['activity']).get(cur['month']) + cur['distance']) || cur['distance'])) ; // if the key is new, initiate its value to the property to sum, otherwise keep its own value
//       return acc;
//     }, new Map())
//   }

  // function totalDistancesByTransportationAndYear(data){
  // This function returns a two layer map
  // First, lets create an initial Month Map with all its values at 0
  // const initialMap = new Map()
  // return data.reduce((acc, cur) => {
  //     acc.set(cur['activity'], acc.get(cur['activity']) || initialMap); // if the key is new, initiate its value, other wise keep the value
  //     acc.get(cur['activity']).set(cur['year'],((acc.get(cur['activity']).get(cur['year']) + cur['distance']) || cur['distance'])) ; // if the key is new, initiate its value to the property to sum, otherwise keep its own value
  //     return acc;
  //   }, new Map())
  // }


function groupAndSumByProperties(data, groupByProperties, sumProperty) {
  const groupedSum = data.reduce((acc, obj) => {
    const key = groupByProperties.map(prop => obj[prop]).join('-');

    if (!acc[key]) {
      acc[key] = {
        ...groupByProperties.reduce((result, prop) => {
          result[prop] = obj[prop];
          return result;
        }, {}),
        [sumProperty]: obj[sumProperty]
      };
    } else {
      acc[key][sumProperty] += obj[sumProperty];
    }

    return acc;
  }, {});

  const result = Object.values(groupedSum);
  return result;
}

function sortByProperties(data, sortByProperties) {
  return data.sort((a, b) => {
    for (let prop of sortByProperties) {
      if (a[prop] < b[prop]) return -1;
      if (a[prop] > b[prop]) return 1;
    }
    return 0;
  });
}

function cleanData(data){
  const cleanedData = []
  data.forEach((elem) => {
    if (!Number.isNaN(elem.distance) && elem.activity !== undefined ) {
      cleanedData.push(elem)
    }
  })
  return cleanedData;
}


function create_bar_chart(data) {

  new Chart(this.chartTarget, {
    type: 'bar',
    data: {
      labels: 'a modifier',
      datasets: [{
        label: '# of Votes',
        data: [12, 19, 3, 5, 2, 3],
        borderWidth: 1
      }]
    },
    options: {
      scales: {
        y: {
          beginAtZero: true
        }
      }
    }
  });
}


function generateChartData(data) {
  const datasets = []
  const [minYear, maxYear] = minMax(data)
  Object.keys(data).sort().forEach((key)=> {
    // Object keys returns an array of the object's key, that is to say all the activities, which we then sort alphabetically and iterate through
    datasets.push({
      label: key,
      data: YearlyArray(data[key], minYear, maxYear),
      borderWidth: 1,
    })
  })
  return {labels: arrayRange(minYear, maxYear), datasets: datasets};
}
