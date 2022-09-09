//
//  extDate.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/5/22.
//

import Foundation

//MARK: extension Date
extension Date {
    func adding(_ seconds: Int) -> Date {
        if let dat = Calendar.current.date(byAdding: .minute, value: seconds, to: self) {
            return dat
        } else {
            return Date()
        }
    }
}
