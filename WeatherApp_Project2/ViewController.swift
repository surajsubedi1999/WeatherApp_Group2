//
//  ViewController.swift
//  WeatherApp_Project2
//
//  Created by Suraj Subedi on 2025-07-25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(citiesLabelTapped))
        cityLabel.isUserInteractionEnabled = true
        cityLabel.addGestureRecognizer(tapGesture)
    }
    
    // NEW: Request location only after permission is authorized
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    private func getURL(query: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "483225a201a84f0088b171549252707"
        guard let url =
                "\(baseURL)\(currentEndPoint)?key=\(apiKey)&q=\(query)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do {
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error decoding")
        }
        return weather
    }
    
    struct WeatherResponse: Decodable {
        let location: Location
        let current: Weather
        
        var cityID: String {
            return "\(location.name)-\(location.country)"
        }
    }
    
    struct Location: Decodable {
        let name: String
        let region: String
        let country: String
    }
    
    struct Weather: Decodable {
        let temp_c: Float
        let temp_f: Float
        let condition: WeatherCondition
        let wind_mph: Decimal
        let wind_dir: String
        let humidity: Int
        let is_day: Int
    }
    
    struct WeatherCondition: Decodable {
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
    
    private func loadWeather(search: String?, index: Int) {
        guard let search = search else { return }
        guard let url = getURL(query: search) else {
            print("Could not get URL")
            return
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Error received")
                return
            }
            
            guard let data = data else {
                print("No data found!")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data) {
                DispatchQueue.main.async { [self] in
                    self.cityLabel.text = weatherResponse.location.name
                    self.locationLabel.text = "\(weatherResponse.location.region), \(weatherResponse.location.country)"
                    
                    self.windSpeedLabel.text = "\(weatherResponse.current.wind_mph)mph"
                    self.windDirectionLabel.text = "\(weatherResponse.current.wind_dir)"
                    self.humidityLabel.text = "\(weatherResponse.current.humidity) %"
                    self.isDayLabel.text = weatherResponse.current.is_day == 0 ? "Night" : "Day"
                    
                    if index == 0 {
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_c)°C"
                    } else if index == 1 {
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_f)°F"
                    }
                    
                    self.statusLabel.text = weatherResponse.current.condition.text
                    self.loadweatherImage(code: weatherResponse.current.condition.code)
                    
                    if !self.cityList.contains(where: { $0.cityID == weatherResponse.cityID }) {
                        cityList.append(weatherResponse)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    private func loadweatherImage(code: Int) {
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemGray5])
        weatherForegroundImage.preferredSymbolConfiguration = config
        
        switch code {
        case 1000:
            weatherForegroundImage.image = UIImage(systemName: "sun.max.fill")
        case 1003...1009, 1030:
            weatherForegroundImage.image = UIImage(systemName: "cloud.sun.fill")
        case 1063...1072:
            weatherForegroundImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
        case 1114...1117, 1210...1219:
            weatherForegroundImage.image = UIImage(systemName: "cloud.snow.fill")
        case 1135...1147:
            weatherForegroundImage.image = UIImage(systemName: "cloud.fog.fill")
        case 1150...1171, 1180...1198:
            weatherForegroundImage.image = UIImage(systemName: "cloud.heavyrain")
        case 1201...1219, 1240...1264:
            weatherForegroundImage.image = UIImage(systemName: "cloud.sleet")
        case 1273...1282:
            weatherForegroundImage.image = UIImage(systemName: "cloud.bolt.fill")
        default:
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

    @objc func citiesLabelTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CityListViewController") as? CityListViewController {
            vc.cityList = self.cityList
            vc.tempUnitIndex = self.index  // Pass Celsius or Fahrenheit selection
            self.present(vc, animated: true)
        }
    }




    private func navigateToCityList() {
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
        print("Location error:", error)
    }
}
extension ViewController {
    static var searchedCities: [WeatherResponse] = []
}
