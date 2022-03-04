import UIKit
import CoreLocation

struct Forecast: Codable {
    
    let DailyForecasts: [DailyForecast]
    
    struct DailyForecast: Codable {
        let EpochDate: Int
        
    }
    
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

func fetchForecast(location: CLLocation, completion: @escaping (Result<Forecast, Error>) -> ()) {
    
    let urlStr = "http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=bHksqumX7phbLMJ6RL2i2TRv384fK5Uq&q=\(location.coordinate.latitude)%2C%20\(location.coordinate.longitude)"
    
    
}
