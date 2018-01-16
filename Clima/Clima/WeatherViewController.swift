//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation // For location, next need to confirm location manager delegate. CoreLocation is not open source
import Alamofire// sometimes it will be showing a Xcode error even though we can see the file is just there, use command + B to build the project, the error will be gone
// in order to use Alamofire, this website gives us explanation https://github.com/Alamofire/Alamofire
// for http methods: https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#http-methods
import SwiftyJSON
import SVProgressHUD


class WeatherViewController: UIViewController,CLLocationManagerDelegate,ChangeCityDelegate {
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "ff6ecfb96e9117d645fdb0dfe3826675"
    //e72ca729af228beabd5d20e3b7749713
    let weatherDataModel = WeatherDataModel()
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //TODO:Set up the location manager here.
        locationManager.delegate = self // means this controller is regarded as the delegate of the location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // the more accurate, the longer time it will take
        locationManager.requestWhenInUseAuthorization() // give the authorization of the request, will pop up to ask the permission
        //next step: navigate to info plist add two privacy ones. location when in use, location usage description
    
        // apple only allows the API that has https protocol for transfering data, but this weather wesite we are using does not provide free ssl(https), and we can't use https address. The code angela provided in git basically allows us to load data from http url
//        <key>NSAppTransportSecurity</key>
//        <dict>
//        <key>NSExceptionDomains</key>
//        <dict>
//        <key>openweathermap.org</key>
//        <dict>
//        <key>NSIncludesSubdomains</key>
//        <true/>
//        <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
//        <true/>
//        </dict>
//        </dict>
//        </dict>
        
        locationManager.startUpdatingLocation() // Asynchronous method, update the location in the background try to tract the GPS location, if runs it in foreground, it will freeze up the entire app. but it could send a message to the view controller to let us know that the location is updated. SO we can see didUpdateLocations
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here: // http request
    ///////////////######### http request #########///////////////
    func getWeatherData(url : String, parameters : [String:String]){
        // methods below mean http methods: get post delete put head....

        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in//function inside a function
            if response.result.isSuccess{ // make the request in the background
                print("Success! Got the weather data")
               // let weatherJSON : JSON = response.result.value as! JSON  //javascript object notation
                let weatherJSON : JSON = JSON(response.result.value!) // comes from SWIFTYJSON
                print(weatherJSON)
                // difference: JSON(response.result.value!) uses SwiftyJSON to format our weatherJSON result.
                self.updateWeatherData(json: weatherJSON)
            }
            else{
                print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    ///////////////##################///////////////
    //MARK: - JSON Parsing
    /***************************************************************/
   
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
        
        //if the appid is not right, it will return a fatal error : found nil while unwrapping an optional value, in order to make this safe.change the code!!
//        let tempResult = json["main"]["temp"].double // like a dictionary
//        weatherDataModel.temperature = Int(tempResult! - 273.12)
//        weatherDataModel.city = json["name"].stringValue
//        weatherDataModel.condition = json["weather"][0]["id"].intValue // a city may have two different conditions
//        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        if let tempResult = json["main"]["temp"].double {// like a dictionary. and if the tempResult does have a value, then do the following stuffs
            weatherDataModel.temperature = Int(tempResult - 273.12) // and in the case of using  "if", we do not need to use force unwrap
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue // a city may have two different conditions, use the first one
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here: tell the delegate that the new location is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //when the location is updated, the location value will be added into the CLLocation array, the last value of this array is the most precise one
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{ // <0 is invalid value
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil // when writing this line, during the process of stop updating location, this line of code can stop the class receiving messages from the location manager
            print("longitude \(location.coordinate.longitude)")
            print("latitude \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]// dictionary
            //based on the url or documentation(which is not updated), the service requires three parameters, longitude, latitude and app_id
            getWeatherData(url: WEATHER_URL, parameters: params)
            
        }
    }
    
    // Pass the value: there are two ways
    // 1. use the object, or variable of other class, this cannot be used for CoreLocation
    // 2. use delegate to pass value, This can be used for CoreLocation
    
    
    // API APPLICATION program interfaces
    // API will tell us what parameters we need, how we can call the API, and what the data structure of the response is like the picture showed in the video.
    
    
    
    
    //Write the didFailWithError method here: tell the view controller that the location manager was not able to retrieve the location value
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID] // check the url keys
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let DVC = segue.destination as! ChangeCityViewController
            DVC.delegate = self // set the delegate as WeatherViewController
        }
    }
    
    
    
    
}


