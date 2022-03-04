//
//  Forecast.swift
//  WeatherMen
//
//  Created by zac on 2022/03/01.
//

import Foundation

struct Forecast: Codable {
    let lat: Double
    let lon: Double
    
    struct Hourly: Codable {
        let dt: Int
        let temp: Double
        let pop: Double
        
        struct Weather: Codable {
            let description: String
            let icon: String
        }
        
        let weather: [Weather]
    }
    
    let hourly: [Hourly]
}

struct ForecastData {
    let date: Date
    let icon: String
    let weather: String
    let temperature: Double
}
