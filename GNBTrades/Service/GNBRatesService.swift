//
//  GNBRatesService.swift
//  GNBTrades
//
//  Created by Criss on 2/16/20.
//  Copyright © 2020 Criss. All rights reserved.
//

import Foundation

struct GNBRatesServiceConstants {
    static let ratesURL = "http://gnb.dev.airtouchmedia.com/rates.json"
}

class GNBRatesService: GNBService {
    
    public func fetchRates(completionHandler: @escaping ([GNBRateModel]) -> Void) {
        
        performRequest(urlString: GNBRatesServiceConstants.ratesURL, errorHandler: { error in
            print(error.localizedDescription)
            completionHandler([])
        }, successHandler: { data in
            do {
                let rates = try JSONDecoder().decode(Array<GNBRateModel>.self, from: data)
                completionHandler(rates)
            } catch let jsonError {
                print(jsonError.localizedDescription)
                completionHandler([])
            }
        })
    }
}
