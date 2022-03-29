//
//  SummaryTableViewCell.swift
//  WeatherMen
//
//  Created by zac on 2022/01/14.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {
    
    static let identifier = "SummaryTableViewCell"
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
