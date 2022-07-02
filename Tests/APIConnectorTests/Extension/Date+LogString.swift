//
//  Date+LogString.swift
//  
//
//  Created by Joonghoo Im on 2022/07/02.
//

import Foundation

extension Date {
    func logString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: self)
    }
}
