//
//  Date+Ext.swift
//  GHFollowers
//
//  Created by Sylvain Druaux on 20/01/2024.
//

import Foundation

extension Date {
    func convertToMonthYearFormat() -> String {
        formatted(.dateTime.month().year())
    }
}
