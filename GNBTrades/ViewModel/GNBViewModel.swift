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
    
    // MARK: Private Vars
    
    private var rates: [GNBRateModel] = []
    private var products: [GNBProductModel] = [] {
        didSet {
            self.productsList = Array(Set(products.map({ $0.sku })))
        }
    }
    
    // MARK: Vars
    
    weak var delegateProducts: GNBViewModelProductsDelegate?
    weak var delegateRates: GNBViewModelRatesDelegate?
    
    var productsList: [String] = []
    var transactionsList: [GNBProductModel] = []
    var selectedProductName: String? {
        didSet {
            self.transactionsList = products.filter({$0.sku == selectedProductName})
        }
    }
    
    // MARK: Methods
        
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
        guard rates.count > 0 else {
            print(GNBViewModelConstants.missingConversionRateError)
            return " "
        }
        
        let total = transactionsList.reduce(0.0) {(result, transaction) -> Double in
            var amount = Double(transaction.amount) ?? 0.0
            // if currency is EUR, the amount is correct, otherwise it needs to be calculated
            if transaction.currency != GNBViewModelConstants.eur {
                let results = rates.filter { $0.from == transaction.currency && $0.to == GNBViewModelConstants.eur }
                if results.count > 0 {
                    // Finds the rate needed to convert the amount in EUR
                    //
                    // Example: if CAD is the currency
                    //
                    // it finds the corresponding rate for CAD -> EUR
                    //
                    let resRate = results[0]
                    if let eurRate = Double(resRate.rate) {
                        amount = amount * eurRate
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
    
    // MARK: Private Methods
    
    private func calculateMissingRates() {
        //print("received rates: \(rates) \n****\n ")
        
        guard rates.count > 0 else {
            return
        }
        
        // creates an array with the existing currencies
        // since all relations have the reverse one, it is enough to use from
        var currencyArray = Array(Set(rates.map({ $0.from })))
        //print("currencyArray: \(currencyArray) \n")
        
        var remainingCurrencyArray = currencyArray
        
        // checks all currencies to see the missing relations
        while currencyArray.count > 0 {
            let currency = currencyArray[0]
            remainingCurrencyArray = remainingCurrencyArray.filter { $0 != currency }
            var remainingCurrencies = remainingCurrencyArray
            
            // checks the first currency in the list, if it has available the conversion rates with all the other currencies in the list
            while remainingCurrencies.count > 0 {
                let remainingCurrency = remainingCurrencies[0]
                remainingCurrencies.removeFirst()
                
                // search if the rate exists
                let results = rates.filter { $0.from == currency && $0.to == remainingCurrency }
                if results.count == 0 {
                    // if the rate doesn't exist, it needs to be calculated
                    let calculatedRate = calculateMissingRate(from: currency, to: remainingCurrency)
                    if calculatedRate != GNBRateModelConstants.missingRate {
                        let rate = GNBRateModel(from: currency, to: remainingCurrency, rate: calculatedRate)
                        let reverseRate = GNBRateModel(from: remainingCurrency, to: currency, rate: rate.reverse())
                        // the rate and reverse rate are calculated and added to the existing rates array
                        rates.append(contentsOf: [rate, reverseRate])
                    } else {
                        // if the rate can't be calculated at this moment, the remainingCurrency is put back in the array at the end so that it can be calculated later, when all the other rates are available and there if more information to search
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
                //  rates are found with the searched from property and with the needed currencies in the to property
                //
                //  Example: AUD -> CAD
                //
                //  resFrom:    from “USD”,”to":"AUD"   0.73
                //  resTo:      from "USD","to":"CAD"   0.51
                //
                //  from “AUD”,”to":"CAD" =  0.51/0.73 = 0.70
                //
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
