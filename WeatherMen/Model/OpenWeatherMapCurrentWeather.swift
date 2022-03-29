//
//  OpenWeatherMapCurrentWeather.swift
//  WeatherMen
//
//  Created by zac on 2022/03/01.
//

import Foundation

struct OpenWeatherMapCurrentWeather: Codable {
    
    let dt: Int
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }
    
    let main: Main
    
}
