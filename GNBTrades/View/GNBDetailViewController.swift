//
//  GNBDetailViewController.swift
//  GNBTrades
//
//  Created by Criss on 2/17/20.
//  Copyright © 2020 Criss. All rights reserved.
//

import UIKit

struct GNBDetailViewControllerConstants {
    static let detailIdentifier = "detailIdentifier"
}

class GNBDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sumLabel: UILabel!
    
    var viewModel: GNBViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = viewModel.selectedProductName
        
        viewModel.delegateRates = self
        displaySum()
    }
    
    func displaySum() {
        sumLabel.text = viewModel.totalAmount()
    }
}

extension GNBDetailViewController: GNBViewModelRatesDelegate {
    
    func modelUpdateDidFinish() {
        DispatchQueue.main.async {
            self.displaySum()
        }
    }
}

extension GNBDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GNBDetailViewControllerConstants.detailIdentifier, for: indexPath)
        if viewModel.transactionsList.count > indexPath.row {
            let transaction = viewModel.transactionsList[indexPath.row]
            cell.textLabel?.text = transaction.amount + " " + transaction.currency
        }
        
        return cell
    }
    
}
