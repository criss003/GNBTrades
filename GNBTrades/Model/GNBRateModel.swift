//
//  GNBRate.swift
//  GNBTrades
//
//  Created by Criss on 2/16/20.
//  Copyright © 2020 Criss. All rights reserved.
//

import Foundation

struct GNBRateModelConstants {
    static let missingRate = "MissingRate"
    static let formatRate = "%.2f"
}

struct GNBRateModel: Codable {
    let from: String
    let to: String
    var rate: String
    
    func reverse() -> String {
        if let rateValue = Double(rate) {
            let reverseRate = 1 / rateValue
            
            return String(format: GNBRateModelConstants.formatRate, reverseRate)
        }
        return GNBRateModelConstants.missingRate
    }
}

