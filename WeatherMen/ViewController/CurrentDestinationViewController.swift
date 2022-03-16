//
//  CurrentDestinationViewController.swift
//  WeatherMen
//
//  Created by zac on 2022/01/14.
//

import UIKit
import CoreLocation

class CurrentDestinationViewController: UIViewController {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var reloadLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationLabel.alpha = 0.0
        reloadLocationButton.alpha = 0.0
        listTableView.alpha = 0.0
        loader.alpha = 1.0
        
        /*
        let location = CLLocation(latitude: 37.350018, longitude: 127.108908)
        WeatherDataSource.shared.fetch(location: location) {
            self.listTableView.reloadData()
        }*/
        
        LocationManager.shared.updateLocation()
        
        NotificationCenter.default.addObserver(forName: WeatherDataSource.weatherInfoDidUpdate, object: nil, queue: .main) { (notification) in
            self.listTableView.reloadData()
            self.locationLabel.text = LocationManager.shared.currentLocationTitle
            
            UIView.animate(withDuration: 0.3) {
                self.locationLabel.alpha = 1.0
                self.listTableView.alpha = 1.0
                self.reloadLocationButton.alpha = 1.0
                self.loader.alpha = 0.0
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CurrentDestinationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return WeatherDataSource.shared.accuWeatherForecastList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as! SummaryTableViewCell
            
            if let weather = WeatherDataSource.shared.summary?.weather.first, let main = WeatherDataSource.shared.summary?.main {
                cell.weatherImageView.image = UIImage(named: weather.icon)
                cell.statusLabel.text = weather.description
                cell.maxLabel.text = "최고 \(main.temp_max.temperatureString)"
                cell.minLabel.text = "최소 \(main.temp_min.temperatureString)"
                cell.currentTemperatureLabel.text = "\(main.temp.temperatureString)"
            }
            
            return cell
        }
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as! ForecastTableViewCell
        
        cell.sourceButton1.imageView?.image = UIImage(named: "openweathermapicon")
        cell.sourceButton2.imageView?.image = UIImage(named: "accuweathericon")
        
        let target1 = WeatherDataSource.shared.openWeatherMapForecastList[indexPath.row]
        cell.dateLabel.text = target1.date.dateString
        cell.timeLabel.text = target1.date.timeString
        cell.weatherImageView1.image = UIImage(named: target1.icon)
        cell.temperatureLabel1.text = target1.temperature.temperatureString
        if isRainyOpenWeatherMap(pop: target1.precipitationProbability) {
            cell.precipitationPercentLabel1.isHidden = false
            cell.precipitationPercentLabel1.text = target1.precipitationProbability.percentString
        } else {
            cell.precipitationPercentLabel1.isHidden = true
        }
        //cell.sourceImageView1.image = UIImage(named: "openweathermapicon")
        //cell.statusLabel1.text = target1.weather
        
        let target2 = WeatherDataSource.shared.accuWeatherForecastList[indexPath.row]
        cell.weatherImageView2.image = UIImage(named: convertAccuWeatherIconToOpenWeatherMap(weatherIcon: target2.icon))
        cell.temperatureLabel2.text = target2.temperature.temperatureString
        if isRainyAccuWeather(pop: target2.precipitationProbability) {
            cell.precipitationPercentLabel2.isHidden = false
            let precipitationProbabilityDoubleType = Double(target2.precipitationProbability)
            let pop = precipitationProbabilityDoubleType / 100
            cell.precipitationPercentLabel2.text = pop.percentString
        } else {
            cell.precipitationPercentLabel2.isHidden = true
        }
        //cell.sourceImageView2.image = UIImage(named: "accuweathericon")
        //cell.statusLabel2.text = target2.weather
            
        return cell
    }
}

extension CurrentDestinationViewController {
    private func convertAccuWeatherIconToOpenWeatherMap(weatherIcon: Int) -> String {
        switch weatherIcon {
        case 1,2,30,31,32:
            return "01d"
        case 33,34:
            return "01n"
        case 3,4,5:
            return "02d"
        case 35,36,37:
            return "02n"
        case 6,7:
            return "03d"
        case 38:
            return "03n"
        case 8:
            return "04d"
        case 12,13,14,26,29:
            return "09d"
        case 39,40:
            return "09n"
        case 18:
            return "10d"
        case 15,16,17:
            return "11d"
        case 41,42:
            return "11n"
        case 19,20,21,22,23,24,25:
            return "13d"
        case 43,44:
            return "13n"
        case 11:
            return "50d"
        default:
            return ""
        }
    }
    
    /* Check by weather status
    private func isRainyOpenWeatherMap(icon: String) -> Bool {
        let rainyIcons = ["09d", "09n", "10d", "10n", "11d", "11n"]
        if rainyIcons.contains(icon) {
            return true
        } else {
            return false
        }
    } */
    private func isRainyOpenWeatherMap(pop: Double) -> Bool {
        if pop == 0 {
            return false
        } else {
            return true
        }
    }
    
    /*Check by weather status
    private func isRainyAccuWeather(icon: Int) -> Bool {
        let stringIcon = convertAccuWeatherIconToOpenWeatherMap(weatherIcon: icon)
        let rainyIcons = ["09d", "09n", "10d", "10n", "11d", "11n"]
        if rainyIcons.contains(stringIcon) {
            return true
        } else {
            return false
        }
    } */
    private func isRainyAccuWeather(pop: Int) -> Bool {
        if pop == 0 {
            return false
        } else {
            return true
        }
    }
}

extension CurrentDestinationViewController {
    @IBAction func reloadLocation(_ sender: UIButton) {
        LocationManager.shared.updateLocation()
    }
    
    @IBAction func pressOpenWeatherMapIcon(_ sender: UIButton) {
        let alert = UIAlertController(title: "출처", message: "openweathermap.org", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pressAccuWeatherIcon(_ sender: UIButton) {
        let alert = UIAlertController(title: "출처", message: "accuweather.com", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
