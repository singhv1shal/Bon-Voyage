// Utility that returns the weather of a location


const request = require('request')                    // Importing request Module

const forecast = (latitude, longitude, callback) => {    // function to call weather API
    const url = 'http://api.weatherstack.com/current?access_key=9ea8d7fed70f0962128973387bcc0f51&query='+latitude+','+longitude

    request({url: url, json: true}, (error, response) => {
        if(error){
            callback('Unable to connect', undefined)     // If there is a problem in conection
        } else if (response.body.error) {
            callback('Unable to find location',undefined) //If given location is not found
        } else {
            callback(undefined,response.body)             // Return weather in JSON format
        }   
    })
}
 
module.exports = forecast