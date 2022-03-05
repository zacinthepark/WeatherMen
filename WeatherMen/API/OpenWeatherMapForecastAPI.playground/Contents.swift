import UIKit
import CoreLocation

var openWeatherMapForecastList12Hours = [OpenWeatherMapForecastData]()

//Date+Formatter
fileprivate let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_kr")
    return f
}()

extension Date {
    var dateString: String {
        dateFormatter.dateFormat = "M월 d일"
        return dateFormatter.string(from: self)
    }
    
    var timeString: String {
        dateFormatter.dateFormat = "HH:00"
        return dateFormatter.string(from: self)
    }
}

//Double+Formatter
fileprivate let temperatureFormatter: MeasurementFormatter = {
   let f = MeasurementFormatter()
    f.locale = Locale(identifier: "ko_kr")
    f.numberFormatter.maximumFractionDigits = 1
    f.unitOptions = .temperatureWithoutUnit
    return f
}()

extension Double {
    var temperatureString: String {
        let temp = Measurement<UnitTemperature>(value: self, unit: .celsius)
        return temperatureFormatter.string(from: temp)
    }
}

struct OpenWeatherMapForecast: Codable {
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

struct OpenWeatherMapForecastData {
    let date: Date
    let icon: String
    let weather: String
    let temperature: Double
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

func fetchOpenWeatherMapForecast(location: CLLocation, completion: @escaping (Result<OpenWeatherMapForecast, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/onecall?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&exclude=current,minutely,daily,alerts&appid=\(openWeatherMapApiKey)&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

let location = CLLocation(latitude: 37.350018, longitude: 127.108908)

fetchOpenWeatherMapForecast(location: location) { (result) in
    switch result {
    case .success(let data):
        openWeatherMapForecastList12Hours = data.hourly.map {
            let dt = Date(timeIntervalSince1970: TimeInterval($0.dt))
            let icon = $0.weather.first?.icon ?? ""
            let weather = $0.weather.first?.description ?? "알 수 없음"
            let temperature = $0.temp
            
            return OpenWeatherMapForecastData(date: dt, icon: icon, weather: weather, temperature: temperature)
        }
        openWeatherMapForecastList12Hours.removeLast(36)
    default:
        openWeatherMapForecastList12Hours = []
    }
}

fetchOpenWeatherMapForecast(location: location) { (result) in
    print(openWeatherMapForecastList12Hours)
}



