import UIKit
import CoreLocation

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
    let IconPhrase: String
    
    struct Temperature: Codable {
        let Value: Double
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
        //fatalError("URL 생성 실패")
        completion(.failure(ApiError.invalidURL(urlStr)))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            //fatalError(error.localizedDescription)
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            //fatalError("Invalid Response")
            completion(.failure(ApiError.invalidResponse))
            return
        }
        
        guard httpResponse.statusCode == 200 else {
            //fatalError("Failed Code \(httpResponse.statusCode)")
            completion(.failure(ApiError.failed(httpResponse.statusCode)))
            return
        }
        
        guard let data = data else {
            //fatalError("Empty Data")
            completion(.failure(ApiError.emptyData))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(ParsingType.self, from: data)
            completion(.success(data))
            
            
        } catch {
            //fatalError(error.localizedDescription)
            completion(.failure(error))
        }
        
    }
    
    task.resume()
}

func fetchAccuWeatherLocationKey(location: CLLocation, completion: @escaping(Result<LocationKey, Error>) -> ()) {
    let urlStr = "http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(accuWeatherApiKey)&q=\(location.coordinate.latitude)%2C%20\(location.coordinate.longitude)&language=ko-kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

let location = CLLocation(latitude: 37.350018, longitude: 127.108908)

func fetchAccuWeatherForecast(locationKey: String, completion: @escaping(Result<[AccuWeatherForecast], Error>) -> ()) {
    let urlStr = "http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(Int(locationKey)!)?apikey=\(accuWeatherApiKey)&language=ko-kr&metric=true"
    
    fetch(urlStr: urlStr, completion: completion)
}

fetchAccuWeatherLocationKey(location: location) { (result) in
    switch result {
    case .success(let locationKey):
        fetchAccuWeatherForecast(locationKey: locationKey.Key) { (result) in
            switch result {
            case .success(let data):
                dump(data)
            default: break
            }
        }
    default: break
    }
}

