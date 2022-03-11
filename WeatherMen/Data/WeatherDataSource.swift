//
//  WeatherDataSource.swift
//  WeatherMen
//
//  Created by zac on 2022/03/01.
//

import Foundation
import CoreLocation

class WeatherDataSource {
    static let shared = WeatherDataSource()
    private init() {
        
        NotificationCenter.default.addObserver(forName: LocationManager.currentLocationDidUpdate, object: nil, queue: .main) { (notification) in
            
            if let location = notification.userInfo?["location"] as? CLLocation {
                self.fetch(location: location) {
                    NotificationCenter.default.post(name: Self.weatherInfoDidUpdate, object: nil)
                }
            }
        }
        
    }
    
    static let weatherInfoDidUpdate = Notification.Name(rawValue: "weatherInfoDidUpdate")
    
    var summary: OpenWeatherMapCurrentWeather?
    var openWeatherMapForecastList = [OpenWeatherMapForecastData]()
    var accuWeatherCurrentWeather: AccuWeatherCurrentWeather?
    var accuWeatherForecastList = [AccuWeatherForecastData]()
    
    //Api 요청할 때 사용할 DispatchQueue 저장 / .concurrent 옵션 추가하여 최대한 많은 작업 동시에 처리
    let weatherApiQueue = DispatchQueue(label: "WeatherApiQueue", attributes: .concurrent)
    
    //DispatchGroup은 2개의 Api 요청을 하나의 논리적인 그룹으로 묶어줄 때 사용
    let group = DispatchGroup()
    
    //외부에서 호출하는 method
    
    //좌표를 받는 버전
    func fetch(location: CLLocation, completion: @escaping () -> ()) {
        group.enter()
        weatherApiQueue.async {
            self.fetchOpenWeatherMapCurrentWeather(location: location) { (result) in
                switch result {
                case .success(let data):
                    self.summary = data
                default:
                    self.summary = nil
                }
                
                self.group.leave()
            }
        }
        
        group.enter()
        weatherApiQueue.async {
            self.fetchOpenWeatherMapForecast(location: location) { (result) in
                switch result {
                case .success(let data):
                    self.openWeatherMapForecastList = data.hourly.map {
                        let dt = Date(timeIntervalSince1970: TimeInterval($0.dt))
                        let icon = $0.weather.first?.icon ?? ""
                        let weather = $0.weather.first?.description ?? "알 수 없음"
                        let temperature = $0.temp
                        let precipitationProbability = $0.pop
                        
                        return OpenWeatherMapForecastData(date: dt, icon: icon, weather: weather, temperature: temperature, precipitationProbability: precipitationProbability)
                    }
                    self.openWeatherMapForecastList.removeFirst(1)
                    self.openWeatherMapForecastList.removeLast(35)
                default:
                    self.openWeatherMapForecastList = []
                }
                
                self.group.leave()
            }
        }
        
        group.enter()
        weatherApiQueue.async {
            self.fetchAccuWeatherLocationKey(location: location) { (result) in
                switch result {
                case .success(let locationKey):
                    self.fetchAccuWeatherCurrentWeather(locationKey: locationKey.Key) { (result) in
                        switch result {
                        case . success(let data):
                            self.accuWeatherCurrentWeather = data.first
                        default:
                            self.accuWeatherCurrentWeather = nil
                        }
                    }
                default: self.accuWeatherCurrentWeather = nil
                }
                
                self.group.leave()
            }
        }
        
        group.enter()
        weatherApiQueue.async {
            self.fetchAccuWeatherLocationKey(location: location) { (result) in
                switch result {
                case .success(let locationKey):
                    self.fetchAccuWeatherForecast(locationKey: locationKey.Key) { (result) in
                        switch result {
                        case .success(let data):
                            self.accuWeatherForecastList = data.map {
                                let dt = Date(timeIntervalSince1970: TimeInterval($0.EpochDateTime))
                                let icon = $0.WeatherIcon
                                let weather = $0.IconPhrase
                                let temperature = $0.Temperature.Value
                                let precipitationProbability = $0.PrecipitationProbability
                                
                                return AccuWeatherForecastData(date: dt, icon: icon, weather: weather, temperature: temperature, precipitationProbability: precipitationProbability)
                            }
                        default: self.accuWeatherForecastList = []
                        }
                    }
                default: self.accuWeatherForecastList = []
                }
                
                self.group.leave()
                
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}

extension WeatherDataSource {
    private func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping (Result<ParsingType, Error>) -> ()) {
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
}

extension WeatherDataSource {
    private func fetchOpenWeatherMapCurrentWeather(location: CLLocation, completion: @escaping (Result<OpenWeatherMapCurrentWeather, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(openWeatherMapApiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
    
    private func fetchOpenWeatherMapForecast(location: CLLocation, completion: @escaping (Result<OpenWeatherMapForecast, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/onecall?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&exclude=current,minutely,daily,alerts&appid=\(openWeatherMapApiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
}

extension WeatherDataSource {
    private func fetchAccuWeatherLocationKey(location: CLLocation, completion: @escaping(Result<LocationKey, Error>) -> ()) {
        let urlStr = "http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(accuWeatherApiKey)&q=\(location.coordinate.latitude)%2C%20\(location.coordinate.longitude)&language=ko-kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
    
    private func fetchAccuWeatherCurrentWeather(locationKey: String, completion: @escaping(Result<[AccuWeatherCurrentWeather], Error>) -> ()) {
        let urlStr = "http://dataservice.accuweather.com/currentconditions/v1/\(Int(locationKey)!)?apikey=\(accuWeatherApiKey)&language=ko-kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
    
    private func fetchAccuWeatherForecast(locationKey: String, completion: @escaping(Result<[AccuWeatherForecast], Error>) -> ()) {
        let urlStr = "http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(Int(locationKey)!)?apikey=\(accuWeatherApiKey)&language=ko-kr&metric=true"
        
        fetch(urlStr: urlStr, completion: completion)
    }
}
