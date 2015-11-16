//
//  ViewController.swift
//  赖床福利
//
//  Created by ChenXiaoShun on 15/10/29.
//  Copyright © 2015年 ChenXiaoShun. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!

    var baseUrla:NSURL?
    var baseRequest:NSURLRequest?
    var imgPreView:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        webView.delegate = self
        self.baseUrla = NSURL(string: "http://192.168.1.151")!
        self.baseRequest = NSURLRequest(URL: self.baseUrla!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval:10)

        //加载网页
        self.webView.loadRequest(baseRequest!)
        //拖动手势
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture")
        self.webView.addGestureRecognizer(swipeGesture)
    }
    
    //拖动手势-返回首页
    func handleSwipeGesture(){
        webView.stringByEvaluatingJavaScriptFromString("mainView.router.back()")
    }
    
    /*
       初始化几个必要参数
    */
    func share(parameter:String,value:String){
        let valueArray = decodeBase64String(value)
        //标题
        let title = valueArray[0] as! String
        //描述
        let description = valueArray[1] as! String
        //链接
        let url = NSURL(string: valueArray[2] as! String)
        //预览图
        let previewURL = NSURL(string: valueArray[3] as! String)

        switch(parameter){
            case "qq":
                //验证注册appId
                _ = TencentOAuth(appId: "1104950206", andDelegate: nil)
                let txtObj:QQApiNewsObject = QQApiNewsObject.objectWithURL(url, title: title, description: description, previewImageURL: previewURL , targetContentType: QQApiURLTargetTypeNews) as! QQApiNewsObject
                let req:SendMessageToQQReq = SendMessageToQQReq(content: txtObj)
                //将内容分享到qq
                QQApiInterface.sendReq(req)
                break
            
            case "weixin":
                //验证注册appId
                WXApi.registerApp("wxc5349997bbf681fa")
                //指定发送类型
                let message = WXMediaMessage()
                //标题
                message.title = title
                //描述
                message.description = description
                //设置预览图
                message.setThumbImage(self.imgPreView)
                //设置链接
                let ext = WXWebpageObject()
                ext.webpageUrl = valueArray[2] as! String
                message.mediaObject = ext;
                //
                let req = SendMessageToWXReq()
                req.message = message;
                let result = WXApi.sendReq(req)
                print(result)
                break
            
            default:
                return
        }
    }
    
    func decodeBase64String(value:String)->NSArray{
        //base64 decode
        let base64DecodeData = NSData(base64EncodedString: value, options: NSDataBase64DecodingOptions(rawValue: 0))
        // to utf8
        let decodeString = NSString(data: base64DecodeData!, encoding: NSUTF8StringEncoding)
        let ValueArray = decodeString!.componentsSeparatedByString(",")
        return ValueArray
    }

    //加载开始前
    func webViewDidStartLoad(webView: UIWebView){
    }
    //加载完成后
    func webViewDidFinishLoad(webView: UIWebView){
        // print("load ok")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.webView.loadHTMLString("Loading Fail", baseURL: nil)
    }
    
    //连接改变时
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        let rurl =  request.URL?.absoluteString
        if (rurl!.hasPrefix("ios://")){
            //解析字符串并执行响应的方法
            parsingUrlString(rurl!)
            return false
        }
        return true
    }
    
    //解析iOS://后面的参数
    func parsingUrlString(rurl:String){
        let urlString =  rurl.componentsSeparatedByString("ios://")[1]
        let methodAndParameter = urlString.componentsSeparatedByString("?")
        //获取要执行的方法
        let method = methodAndParameter[0]
        let parameterString = methodAndParameter[1].componentsSeparatedByString("&")
        //获取参数
        let parameter = parameterString[0]

        //获取参数
        switch(method){
            case "share":
                let value = parameterString[1]
                share(parameter,value: value)
                break
            case "preload":
                preloadItemImage(parameter)
            default:
                return
        }
    }

    func preloadItemImage(imageUrl:String){
        NSThread.detachNewThreadSelector("downloadImage:", toTarget: self, withObject: imageUrl)
    }
    
    func downloadImage(imageUrl:String){
        let image = NSData(contentsOfURL: NSURL(string: imageUrl)!)
        self.imgPreView = UIImage(data: image!)!
//        print(self.imgPreView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

