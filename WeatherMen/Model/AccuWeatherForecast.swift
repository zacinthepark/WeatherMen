//
//  AccuWeatherForecast.swift
//  WeatherMen
//
//  Created by zac on 2022/03/04.
//

import Foundation

struct LocationKey: Codable {
    let Key: String
    
    struct GeoPosition: Codable {
        let Latitude: Double
        let Longitude: Double
    }
    
    let GeoPosition: GeoPosition
}

struct AccuWeatherForecast: Codable {
    let EpochDateTime: Int
    let WeatherIcon: Int
    let IconPhrase: String
    
    struct Temperature: Codable {
        let Value: Double
    }
    
    let Temperature: Temperature
    
    let PrecipitationProbability: Int
}

struct AccuWeatherForecastData {
    let date: Date
    let icon: Int
    let weather: String
    let temperature: Double
    let precipitationProbability: Int
}
