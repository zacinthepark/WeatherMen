import UIKit
import CoreLocation

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

func fetchOpenWeatherMapForecast(location: CLLocation, completion: @escaping (Result<Forecast, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/onecall?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&exclude=current,minutely,daily,alerts&appid=\(openWeatherMapApiKey)&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

let location = CLLocation(latitude: 37.350018, longitude: 127.108908)
fetchOpenWeatherMapForecast(location: location) { (result) in
    switch result {
    case .success(let weather):
        dump(weather)
    case .failure(let error):
        print(error)
    }
}
