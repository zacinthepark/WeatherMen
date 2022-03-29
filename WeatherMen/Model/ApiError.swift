//
//  ApiError.swift
//  WeatherMen
//
//  Created by zac on 2022/03/01.
//

import Foundation

enum ApiError: Error {
    case unknown
    case invalidURL(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}
