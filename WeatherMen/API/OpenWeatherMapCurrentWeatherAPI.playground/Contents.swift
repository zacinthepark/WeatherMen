import UIKit
import CoreLocation

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

func fetchOpenWeatherMapCurrentWeather(cityName: String, completion: @escaping (Result<OpenWeatherMapCurrentWeather, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=9bb607c5051f148d38ced029dd8953fd&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

func fetchOpenWeatherMapCurrentWeather(cityID: Int, completion: @escaping (Result<OpenWeatherMapCurrentWeather, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?id=\(cityID)&appid=9bb607c5051f148d38ced029dd8953fd&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

func fetchOpenWeatherMapCurrentWeather(location: CLLocation, completion: @escaping (Result<OpenWeatherMapCurrentWeather, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=9bb607c5051f148d38ced029dd8953fd&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

//fetchOpenWeatherMapCurrentWeather(cityName: "seoul") { _ in }

/*fetchOpenWeatherMapCurrentWeather(cityID: 1835847) { (result) in
    switch result {
    case .success(let weather):
        dump(weather)
    case .failure(let error):
        print(error)
    }
}*/

let location = CLLocation(latitude: 37.350018, longitude: 127.108908)
fetchOpenWeatherMapCurrentWeather(location: location) { (result) in
    switch result {
    case .success(let weather):
        dump(weather)
    case .failure(let error):
        print(error)
    }
}


