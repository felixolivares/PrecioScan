//
//  ClientManager.swift
//  PrecioScan
//
//  Created by Félix Olivares on 11/23/18.
//  Copyright © 2018 Felix Olivares. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ClientManager: NSObject {
    
    static let shared = ClientManager()
    let url = "https://super.walmart.com.mx/api/rest/model/atg/commerce/catalog/ProductCatalogActor/getSkuSummaryDetails?skuId=$skuId&storeId=0000009999&upc=00075677402211&fbclid=IwAR1j2i38X30mQphDt7LD75JkkRFx61IojSwVOL2HVoQHSKLkE9LEPouILFY"
    let imageUrl = "https://super.walmart.com.mx/images/product-images/img_large/"
    var counterSuccess:Int = 0
    let imageCache = AutoPurgingImageCache(
        memoryCapacity: 100_000_000,
        preferredMemoryUsageAfterPurge: 80_000_000
    )
    
    private override init(){
        super.init()
        configure()
    }
    
    private func configure(){
        
    }
    
    public func getPath(sku: String, params: Parameters? = nil, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        let formedUrl = url.replacingOccurrences(of: "$skuId", with: sku)
        self.performRequest(url: formedUrl, headers: nil, params: params, method: HTTPMethod.get, completionHandler: completionHandler)
    }
    
    public func getImage(sku: String, completionHandler: @escaping (UIImage?, NSError?) -> ()){
        let imageName = "\(sku)L.jpg"
        let url = "\(imageUrl)\(imageName)"
        if let cachedImage = imageCache.image(withIdentifier: imageName) {
            print("[Image Download] - Image cached locally")
            completionHandler(cachedImage, nil)
        } else {
            Alamofire.request(url).responseImage { response in
                if let image = response.result.value {
                    print("[Image Download] - Image downloaded remotely")
                    self.imageCache.add(image, withIdentifier: imageName)
                    completionHandler(image, nil)
                }
            }
        }
    }
    
    public func performRequest(url: String, headers: HTTPHeaders? = nil, params: Parameters? = nil, method: HTTPMethod, completionHandler: @escaping (NSDictionary?, NSError?) -> ()) {
        Alamofire.request(url, method: method, parameters: params, headers: headers).validate().responseJSON{ [weak self] response in
            switch response.result {
            case .success:
                print("[ClientManager] - SUCCESS URL \((response.response?.url?.absoluteString)!)")
                guard let JSON = response.result.value as? NSDictionary else {
                    
                    guard let JSONArray = response.result.value as? NSArray else {
                        
                        self?.counterSuccess += 1
                        print("[ClientManager] - Success calls: \(String(describing: self?.counterSuccess))")
                        let emptyJSON = ["success":"Empty sucess"]
                        completionHandler(emptyJSON as NSDictionary?, nil)
                        return
                    }
                    self?.counterSuccess += 1
                    print("[ClientManager] - Success calls: \(String(describing: self?.counterSuccess))")
                    let JSON = ["success": JSONArray]
                    completionHandler(JSON as NSDictionary?, nil)
                    return
                }
                self?.counterSuccess += 1
                print("[ClientManager] - Success calls: \(String(describing: self?.counterSuccess))")
                completionHandler(JSON, nil)
                
            case .failure(let error):
                print("[ClientManager] - Error: \(error.localizedDescription)\n Error Code: \(String(describing: response.response?.statusCode))")
            }
        }
    }
}
