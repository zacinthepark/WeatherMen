//
//  AccuWeatherCurrentWeather.swift
//  WeatherMen
//
//  Created by zac on 2022/03/05.
//

import Foundation

struct AccuWeatherCurrentWeather: Codable {
    let EpochTime: Int
    let WeatherText: String
    
    struct Temperature: Codable {
        
        struct Metric: Codable {
            let Value: Double
        }
        
        let Metric: Metric
    }
    
    let Temperature: Temperature
}
