//
//  ViewController.swift
//  WeatherApp_Project2
//
//  Created by Suraj Subedi on 2025-07-25.
//



import UIKit
import CoreLocation
class ViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var isDayLabel: UILabel!
    
    
    @IBOutlet weak var weatherForegroundImage: UIImageView!
    public var index = 0
    private var catchSearch = ""
    private let locationManager = CLLocationManager()
    
    private let cityPageSegue = "toCityList"
    var cityList: [WeatherResponse] = []

    //Starts From Here
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        locationManager.delegate = self
    }
    
    private func getURL(query: String) -> URL?{
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "b12ae01ca85646cdb79223446230911"
        guard let url =
                "\(baseURL)\(currentEndPoint)?key=\(apiKey)&q=\(query)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)else{
                return nil
        }
        return URL(string: url)
    }
    
    private func parseJson(data: Data) ->WeatherResponse?{
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        }catch{
            print("Error decoding")
        }
        
        return weather
    }
        
    struct WeatherResponse: Decodable{
        let location: Location
        let current: Weather
        
        var cityID: String {
            return "\(location.name)-\(location.country)"
        }
    }
    
    struct Location: Decodable{
        let name: String
        let country: String
    }
    
    struct Weather: Decodable{
        let temp_c: Float
        let temp_f: Float
        let condition: WeatherCondition
        
        let wind_mph: Decimal
        let wind_dir: String
        let humidity: Int
        let is_day: Int
    }
    
    struct WeatherCondition: Decodable{
        let text: String
        let code: Int
    }
    
    @IBAction func onLocationTabbed(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        catchSearch = ""
    }

    @IBAction func onSearchTabbed(_ sender: UIButton) {
        loadWeather(search: searchTextField.text!, index: index)
        catchSearch = searchTextField.text!
        searchTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        loadWeather(search: textField.text!, index: index)
        catchSearch = textField.text!
        textField.text = ""
        return
    }
    
   
    
    private func loadweatherImage(code: Int){
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemGray5])
        weatherForegroundImage.preferredSymbolConfiguration = config
        
        switch code {
            case 1000:
                // Sunny
                weatherForegroundImage.image = UIImage(systemName: "sun.max.fill")
            case 1003...1009, 1030:
                // Cloudy or Mist
                weatherForegroundImage.image = UIImage(systemName: "cloud.sun.fill")
            case 1063...1072:
                // Patchy rain or thundery outbreaks possible
                weatherForegroundImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
            case 1114...1117, 1210...1219:
                // Snow conditions
                weatherForegroundImage.image = UIImage(systemName: "cloud.snow.fill")
            case 1135...1147:
                // Fog conditions
                weatherForegroundImage.image = UIImage(systemName: "cloud.fog.fill")
            case 1150...1171, 1180...1198:
                // Drizzle or Rain conditions
                weatherForegroundImage.image = UIImage(systemName: "cloud.heavyrain")
            case 1201...1219, 1240...1264:
                // Freezing rain, Sleet, or Snow conditions
                weatherForegroundImage.image = UIImage(systemName: "cloud.sleet")
            case 1273...1282:
                // Thunderstorm conditions
                weatherForegroundImage.image = UIImage(systemName: "cloud.bolt.fill")
            default:
                // Default case, for any other conditions
                weatherForegroundImage.image = UIImage(systemName: "questionmark.circle")
        }

    }
    
    @IBAction func segmentedToggleTabbed(_ sender: UISegmentedControl) {
        index = sender.selectedSegmentIndex
        if catchSearch != "" {
            loadWeather(search: catchSearch, index: index)
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }

    @IBAction func onCitiesTabbed(_ sender: UIButton) {
        navigateToCityList()
    }
    
    private func navigateToCityList()
    {
        performSegue(withIdentifier: cityPageSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == cityPageSegue {
            if let destinationVC = segue.destination as? CityListViewController {
                destinationVC.cityList = cityList
            }
        }
    }

}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            loadWeather(search: "\(latitude),\(longitude)", index: index)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("here on error" ,error)
    }
}

