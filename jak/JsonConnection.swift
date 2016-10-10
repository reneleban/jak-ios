import Foundation
import UIKit

class JsonConnection {
    
    // Constant variables
    let APPLICATION_JSON_TYPE = "application/json"
    
    // Constant variables which will be set by constructor
    let url: UrlBuilder
    let httpMethod: String
    
    // Mutable variables which can be set by class which uses JsonConnection
    var parameters : [String : String] = Dictionary()
    fileprivate var basicAuth: Bool = false
    var base64LoginString:String = ""
    
    init(jakUrl: JakUrl) {
        self.url = jakUrl.getUrl()
        self.httpMethod = jakUrl.getMethod()
    }
    
    init(url: UrlBuilder, httpMethod: String) {
        self.url = url
        self.httpMethod = httpMethod
    }
    
    func addParameter(_ key: String, value: String) {
        parameters[key] = value
    }
    
    func basicAuth(_ username: String, password: String) {
        basicAuth = true
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        base64LoginString = loginData.base64EncodedString(options: [])
    }
    
    func disableBasicAuth() {
        basicAuth = false
    }
    
    func send(_ completionHandler: @escaping (_ response: JakResponse) -> ()) {
        if !Reachability.isConnectedToNetwork() {
            print("No connection available - Performing request with empty response anyway ...")
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = URL(string: self.url.create())
        let request = NSMutableURLRequest(url: url!)
        let session = URLSession.shared
        let parameterString = parameters.stringFromHttpParameters()
        
        print("\(self.httpMethod) \(self.url.debug(false)) \(parameterString.characters.count > 0 ? "->" : "") \(parameterString)")
        
        request.httpMethod = httpMethod
        request.httpBody = parameterString.data(using: String.Encoding.utf8)
        
        request.addValue(APPLICATION_JSON_TYPE, forHTTPHeaderField: "Content-Type")
        request.addValue(APPLICATION_JSON_TYPE, forHTTPHeaderField: "Accept")
        if basicAuth { request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization") }
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if data == nil {
                let jakResponse = JakResponse(object: nil, statusCode: -1)
                jakResponse.internetConnectionUnavailable()
                completionHandler(jakResponse)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as AnyObject
                let jakResponse = JakResponse(object: json, statusCode: (response as! HTTPURLResponse).statusCode)
                completionHandler(jakResponse)
            } catch {
                let jakResponse = JakResponse(object: nil, statusCode: (response as! HTTPURLResponse).statusCode)
                
                if jakResponse.statusCode != 200 {
                    let body = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
                    print("\(error)")
                    print("Unparsable JSON: \(response)")
                    print("Data: \(body)")
                }
                
                completionHandler(jakResponse)
            }
        })
        
        task.resume()
    }
}

extension String {
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
