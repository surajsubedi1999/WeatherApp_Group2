import UIKit

class CityListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var cityList: [ViewController.WeatherResponse] = []
    var tempUnitIndex: Int = 0

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do NOT register a cell here if you use a prototype cell in storyboard
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        let city = cityList[indexPath.row]

        let temp = tempUnitIndex == 0 ? city.current.temp_c : city.current.temp_f
        cell.textLabel?.text = city.location.name
        cell.detailTextLabel?.text = "\(temp)°\(tempUnitIndex == 0 ? "C" : "F"), \(city.current.condition.text)"

        let symbolName = mapCodeToSymbol(code: city.current.condition.code)
        cell.imageView?.image = UIImage(systemName: symbolName)

        return cell
    }

    // Helper method for icon mapping
    func mapCodeToSymbol(code: Int) -> String {
        switch code {
        case 1000:
            return "sun.max.fill"
        case 1003...1009, 1030:
            return "cloud.sun.fill"
        case 1063...1072:
            return "cloud.bolt.rain.fill"
        case 1114...1117, 1210...1219:
            return "cloud.snow.fill"
        case 1135...1147:
            return "cloud.fog.fill"
        case 1150...1171, 1180...1198:
            return "cloud.heavyrain"
        case 1201...1219, 1240...1264:
            return "cloud.sleet"
        case 1273...1282:
            return "cloud.bolt.fill"
        default:
            return "questionmark.circle"
        }
    }
}
