//
//  GNBListViewController.swift
//  GNBTrades
//
//  Created by Criss on 2/16/20.
//  Copyright © 2020 Criss. All rights reserved.
//

import UIKit

struct GNBListViewControllerConstants {
    static let title = "Products"
    static let productIdentifier = "productIdentifier"
    static let mainStoryboard = "Main"
}

class GNBListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let viewModel = GNBViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = GNBListViewControllerConstants.title
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = view.center
        
        viewModel.delegateProducts = self
        viewModel.performModelUpdate()
    }

}

extension GNBListViewController: GNBViewModelProductsDelegate {
    
    func modelUpdateDidFinish() {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
        }
    }
}

extension GNBListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.productsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GNBListViewControllerConstants.productIdentifier, for: indexPath)
        if viewModel.productsList.count > indexPath.row {
            let productName = viewModel.productsList[indexPath.row]
            cell.textLabel?.text = productName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailsViewController = UIStoryboard(name: GNBListViewControllerConstants.mainStoryboard,
                                                       bundle: nil).instantiateViewController(withIdentifier: String(describing: GNBDetailViewController.self))
                                        as? GNBDetailViewController else {
            return
        }
        
        if viewModel.productsList.count > indexPath.row {
            let productName = viewModel.productsList[indexPath.row]
            viewModel.selectedProductName = productName
        }
        
        detailsViewController.viewModel = viewModel
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

