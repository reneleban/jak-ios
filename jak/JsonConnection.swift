import Foundation
import UIKit

class JsonConnection {
    
    // Constant variables
    let APPLICATION_JSON_TYPE = "application/json"
    
    // Constant variables which will be set by constructor
    let url: String
    let httpMethod: String
    
    // Mutable variables which can be set by class which uses JsonConnection
    var parameters : [String : String] = Dictionary()
    private var basicAuth: Bool = false
    var base64LoginString:String = ""
    
    init(jakUrl: JakUrl) {
        self.url = jakUrl.getUrl()
        self.httpMethod = jakUrl.getMethod()
    }
    
    init(url: String, httpMethod: String) {
        self.url = url
        self.httpMethod = httpMethod
    }
    
    func addParameter(key: String, value: String) {
        parameters[key] = value
    }
    
    func basicAuth(username: String, password: String) {
        basicAuth = true
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        base64LoginString = loginData.base64EncodedStringWithOptions([])
    }
    
    func disableBasicAuth() {
        basicAuth = false
    }
    
    func send(completionHandler: (response: JakResponse) -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let url = NSURL(string: self.url)
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let parameterString = parameters.stringFromHttpParameters()
        
        request.HTTPMethod = httpMethod
        request.HTTPBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.addValue(APPLICATION_JSON_TYPE, forHTTPHeaderField: "Content-Type")
        request.addValue(APPLICATION_JSON_TYPE, forHTTPHeaderField: "Accept")
        if basicAuth { request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization") }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                let jakResponse = JakResponse(object: json, statusCode: (response as! NSHTTPURLResponse).statusCode)
                completionHandler(response: jakResponse)
            } catch {
                let jakResponse = JakResponse(object: nil, statusCode: (response as! NSHTTPURLResponse).statusCode)
                
                if jakResponse.statusCode != 200 {
                    let body = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    print("\(error)")
                    print("Unparsable JSON: \(response)")
                    print("Data: \(body)")
                }
                
                completionHandler(response: jakResponse)
            }
        })
        
        task.resume()
    }
}

extension String {
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
}

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joinWithSeparator("&")
    }
    
}