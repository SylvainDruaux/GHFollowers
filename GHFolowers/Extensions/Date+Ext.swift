//
//  Date+Ext.swift
//  GHFolowers
//
//  Created by Sylvain Druaux on 20/01/2024.
//

import Foundation

extension Date {
    func convertToMonthYearFormat() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MMM yyyy"
        return dateFormater.string(from: self)
    }
}
