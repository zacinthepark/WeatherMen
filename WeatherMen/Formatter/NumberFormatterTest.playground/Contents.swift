import UIKit

fileprivate let numberFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    f.locale = Locale(identifier: "ko_kr")
    return f
}()

extension Int {
    var percentString: String {
        let pop = NSNumber(value: self)
        return numberFormatter.string(from: pop) ?? ""
    }
}

let pop1 = 0
let pop2 = 30
let pop3 = 27
let pop4 = 28
let pop5 = 78
print(pop1.percentString)
print(pop2.percentString)
print(pop3.percentString)
print(pop4.percentString)
print(pop5.percentString)

let int = 56
let doubleInt = Double(int)
let final = doubleInt / 100
print(final)
