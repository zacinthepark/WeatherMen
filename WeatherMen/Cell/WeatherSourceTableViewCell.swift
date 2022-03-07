//
//  WeatherSourceTableViewCell.swift
//  WeatherMen
//
//  Created by zac on 2022/03/07.
//

import UIKit

class WeatherSourceTableViewCell: UITableViewCell {
    
    static let identifier = "WeatherSourceTableViewCell"
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var weatherSourceImageView1: UIImageView!
    @IBOutlet weak var weatherSourceLabel1: UILabel!
    @IBOutlet weak var weatherSourceImageView2: UIImageView!
    @IBOutlet weak var weatherSourceLabel2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
