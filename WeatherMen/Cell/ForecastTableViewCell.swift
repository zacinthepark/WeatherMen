//
//  ForecastTableViewCell.swift
//  WeatherMen
//
//  Created by zac on 2022/01/14.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    static let identifier = "ForecastTableViewCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var sourceImageView1: UIImageView!
    @IBOutlet weak var weatherImageView1: UIImageView!
    @IBOutlet weak var temperatureLabel1: UILabel!
    @IBOutlet weak var statusLabel1: UILabel!
    
    @IBOutlet weak var sourceImageView2: UIImageView!
    @IBOutlet weak var weatherImageView2: UIImageView!
    @IBOutlet weak var temperatureLabel2: UILabel!
    @IBOutlet weak var statusLabel2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
