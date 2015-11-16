//
//  getURLProtocol.swift
//  赖床福利
//
//  Created by ChenXiaoShun on 15/11/13.
//  Copyright © 2015年 ChenXiaoShun. All rights reserved.
//

import UIKit



var requestCount = 0



class MyURLProtocol: NSURLProtocol {
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        print("Request #\(requestCount++): URL = \(request.URL!.absoluteString)")
//        let urlCache = NSURLCache.sharedURLCache()
//        let cache = NSURLCache.getCachedResponseForDataTask(urlCache)
//        cache(NSURLSessionDataTask, completionHandler: { (cache) -> Void in
//            print(cache)
//        })
        return false
    } 
    
}
