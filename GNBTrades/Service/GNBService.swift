//
//  GNBService.swift
//  GNBTrades
//
//  Created by Criss on 2/16/20.
//  Copyright © 2020 Criss. All rights reserved.
//

import Foundation

struct GNBServiceConstants {
    static let invalidURLErrorMessage = "invalid URL"
    static let invalidURLErrorCode = 10001
    static let invalidDataErrorMessage = "invalid Data"
    static let invalidDataErrorCode = 10002
}

class GNBService {
    
    func performRequest(urlString: String,
                        errorHandler: @escaping (_ error: Error) -> Void,
                        successHandler: @escaping (_ data: Data) -> Void) {
        
        guard let url = URL(string: urlString) else {
            errorHandler(NSError(domain: GNBServiceConstants.invalidURLErrorMessage, code: GNBServiceConstants.invalidURLErrorCode, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                errorHandler(err)
                return
            }
            
            guard let jsonData = data else {
                errorHandler(NSError(domain: GNBServiceConstants.invalidDataErrorMessage, code: GNBServiceConstants.invalidDataErrorCode, userInfo: nil))
                return
            }
            
            successHandler(jsonData)
            
            }.resume()
    }
}


