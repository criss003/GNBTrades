//
//  GNBViewModel.swift
//  GNBTrades
//
//  Created by Criss on 2/17/20.
//  Copyright © 2020 Criss. All rights reserved.
//

import Foundation

struct GNBViewModelConstants {
    static let eur = "EUR"
    static let total = "TOTAL: "
    static let missingConversionRateError = "Missing Conversion Rate"
}

protocol GNBViewModelProductsDelegate: class {
    func modelUpdateDidFinish()
}

protocol GNBViewModelRatesDelegate: class {
    func modelUpdateDidFinish()
}

class GNBViewModel {
    private var rates: [GNBRateModel] = []
    private var products: [GNBProductModel] = [] {
        didSet {
            self.productsList = Array(Set(products.map({ $0.sku })))
        }
    }
    
    weak var delegateProducts: GNBViewModelProductsDelegate?
    weak var delegateRates: GNBViewModelRatesDelegate?
    
    var productsList: [String] = []
    var transactionsList: [GNBProductModel] = []
    var selectedProductName: String? {
        didSet {
            self.transactionsList = products.filter({$0.sku == selectedProductName})
        }
    }
        
    func performModelUpdate() {
        GNBProductsService().fetchProducts(completionHandler: { dataProducts in
            self.products = dataProducts
            self.delegateProducts?.modelUpdateDidFinish()
        })

        GNBRatesService().fetchRates(completionHandler: { dataRates in
            self.rates = dataRates
            self.calculateMissingRates()
            self.delegateRates?.modelUpdateDidFinish()
        })
    }
    
    func totalAmount() -> String {
        let total = transactionsList.reduce(0.0) {(result, transaction) -> Double in
            var amount = Double(transaction.amount) ?? 0.0
            if transaction.currency != GNBViewModelConstants.eur {
                let results = rates.filter { $0.from == transaction.currency && $0.to == GNBViewModelConstants.eur }
                if results.count > 0 {
                    let resRate = results[0]
                    if let eurRate = Double(resRate.rate) {
                        amount = amount / eurRate
                    }
                } else {
                    print(GNBViewModelConstants.missingConversionRateError)
                    return -1
                }
            }
            return result + amount
        }
        //print("total: \(total) \n")
        
        return total < 0 ? " " : GNBViewModelConstants.total + String(format: GNBRateModelConstants.formatRate, total) + " " + GNBViewModelConstants.eur
    }
    
    private func calculateMissingRates() {
        //print("received rates: \(rates) \n****\n ")
        
        var currencyArray = Array(Set(rates.map({ $0.from })))
        //print("currencyArray: \(currencyArray) \n")
        
        var remainingCurrencyArray = currencyArray
        
        while currencyArray.count > 0 {
            let currency = currencyArray[0]
            remainingCurrencyArray = remainingCurrencyArray.filter { $0 != currency }
            var remainingCurrencies = remainingCurrencyArray
            
            while remainingCurrencies.count > 0 {
                let remainingCurrency = remainingCurrencies[0]
                remainingCurrencies.removeFirst()

                let results = rates.filter { $0.from == currency && $0.to == remainingCurrency }
                if results.count == 0 {
                    let calculatedRate = calculateMissingRate(from: currency, to: remainingCurrency)
                    if calculatedRate != GNBRateModelConstants.missingRate {
                        let rate = GNBRateModel(from: currency, to: remainingCurrency, rate: calculatedRate)
                        let reverseRate = GNBRateModel(from: remainingCurrency, to: currency, rate: rate.reverse())
                        rates.append(contentsOf: [rate, reverseRate])
                    } else {
                        remainingCurrencies.append(remainingCurrency)
                    }
                }
            }

            currencyArray.removeFirst()
        }
        
        //print("all rates: \(rates) \n****\n ")
    }
    
    private func calculateMissingRate(from: String, to: String) -> String {
        //print("Convert \(from) -> \(to)")
        let resultsFrom = rates.filter { $0.to == from }
        let resultsTo = rates.filter { $0.to == to }
        
        for resFrom in resultsFrom {
            let res = resultsTo.filter { $0.from == resFrom.from }
            if res.count > 0 {
                let resTo = res[0]
                if let fromRate = Double(resFrom.rate),
                    let toRate = Double(resTo.rate) {
                    let rate = toRate/fromRate
                    
                    return String(format: GNBRateModelConstants.formatRate, rate)
                }
            }
        }
        return GNBRateModelConstants.missingRate
    }
}
