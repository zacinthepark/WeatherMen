import UIKit
import CoreLocation

struct CurrentWeather: Codable {
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

enum ApiError: Error {
    case unknown
    case invalidURL(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}

func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping (Result<ParsingType, Error>) -> ()) {
    guard let url = URL(string: urlStr) else {
        completion(.failure(ApiError.invalidURL(urlStr)))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(ApiError.invalidResponse))
            return
        }
        
        guard httpResponse.statusCode == 200 else {
            completion(.failure(ApiError.failed(httpResponse.statusCode)))
            return
        }
        
        guard let data = data else {
            completion(.failure(ApiError.emptyData))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(ParsingType.self, from: data)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    
    }
    
    task.resume()
}

func fetchAccuWeatherLocationKey(location: CLLocation, completion: @escaping(Result<LocationKey, Error>) -> ()) {
    let urlStr = "http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(accuWeatherApiKey)&q=\(location.coordinate.latitude)%2C%20\(location.coordinate.longitude)&language=ko-kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

func fetchAccuWeatherCurrentWeather(locationKey: String, completion: @escaping(Result<[CurrentWeather], Error>) -> ()) {
    let urlStr = "http://dataservice.accuweather.com/currentconditions/v1/\(Int(locationKey)!)?apikey=\(accuWeatherApiKey)&language=ko-kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

let location = CLLocation(latitude: 37.350018, longitude: 127.108908)

fetchAccuWeatherCurrentWeather(locationKey: "2331758") { (result) in
    switch result {
    case .success(let data):
        dump(data)
    case .failure(let error):
        print(error)
    }
}
