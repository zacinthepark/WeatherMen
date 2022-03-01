//
//  CurrentDestinationViewController.swift
//  WeatherMen
//
//  Created by zac on 2022/01/14.
//

import UIKit
import CoreLocation

class CurrentDestinationViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let location = CLLocation(latitude: 37.350018, longitude: 127.108908)
        WeatherDataSource.shared.fetch(location: location) {
            self.listTableView.reloadData()
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
            return 0
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
                cell.minMaxLabel.text = "최고\(main.temp_max.temperatureString) 최소\(main.temp_min.temperatureString)"
                cell.currentTemperatureLabel.text = "\(main.temp.temperatureString)"
            }
            
            return cell
        }
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell", for: indexPath) as! ForecastTableViewCell
            
        return cell
    
    }
    
}
