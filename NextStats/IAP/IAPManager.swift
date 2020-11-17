//
//  IAPManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/12/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import StoreKit

class IAPManager: NSObject {
    enum IAPManagerError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }
    
    static let shared = IAPManager()
    
    var onRecieveProductshandler:((Result<[SKProduct], IAPManagerError>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    fileprivate func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            
            return productIDs
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getProducts(withHandler productsRecieveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished
        onRecieveProductshandler = productsRecieveHandler
        
        // Get the product identifiers.
        guard let productIDs = getProductIDs() else {
            productsRecieveHandler(.failure(.noProductsFound))
            return
        }
        
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        
        // Set self as the delegate.
        request.delegate = self
        
        // Make the request
        request.start()
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        
        return formatter.string(from: product.price)
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products = response.products
        
        // Check if there are any products available.
        if products.count > 0 {
            // Call the following handler passing the received products.
            onRecieveProductshandler?(.success(products))
        } else {
            // No products were found
            onRecieveProductshandler?(.failure(.noProductsFound))
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onRecieveProductshandler?(.failure(.productRequestFailed))
    }
}

extension IAPManager.IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .noProductsFound: return "No In-App Purchases were found."
        case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment"
        case .paymentWasCancelled: return "In-App Purchase process was cancelled."
        }
    }
}
