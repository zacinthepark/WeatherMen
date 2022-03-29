//
//  Double+Formatter.swift
//  WeatherMen
//
//  Created by zac on 2022/03/01.
//

import Foundation

//파일 내부에서 사용할 공용 포매터 추가 / 외부에서 접근할 수 없도록 fileprivate
fileprivate let temperatureFormatter: MeasurementFormatter = {
   let f = MeasurementFormatter()
    f.locale = Locale(identifier: "ko_kr")
    f.numberFormatter.maximumFractionDigits = 1
    f.unitOptions = .temperatureWithoutUnit
    return f
}()

fileprivate let numberFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    f.locale = Locale(identifier: "ko_kr")
    return f
}()

extension Double {
    var temperatureString: String {
        let temp = Measurement<UnitTemperature>(value: self, unit: .celsius)
        return temperatureFormatter.string(from: temp)
    }
    
    var percentString: String {
        let pop = NSNumber(value: self)
        return numberFormatter.string(from: pop) ?? ""
    }
}
