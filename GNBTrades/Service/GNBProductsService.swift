//
//  GNBProductsService.swift
//  GNBTrades
//
//  Created by Criss on 2/16/20.
//  Copyright © 2020 Criss. All rights reserved.
//

import Foundation

struct GNBProductsServiceConstants {
    static let productsURL = "http://gnb.dev.airtouchmedia.com/transactions.json"
}

class GNBProductsService: GNBService {
    
    func fetchProducts(completionHandler: @escaping ([GNBProductModel]) -> Void) {
        
        performRequest(urlString: GNBProductsServiceConstants.productsURL, errorHandler: { error in
            print(error.localizedDescription)
            completionHandler([])
        }, successHandler: { data in
            do {
                let products = try JSONDecoder().decode(Array<GNBProductModel>.self, from: data)
                completionHandler((products))
            } catch let jsonError {
                print(jsonError.localizedDescription)
                completionHandler([])
            }
        })
    }
}
