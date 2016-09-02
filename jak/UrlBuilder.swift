import Foundation

class UrlBuilder {
    
    let host: String
    var parts:[String] = []
    
    init(host: String) {
        self.host = host
    }
    
    init(service: Services) {
        self.host = service.rawValue
    }
    
    func a(part: String) -> UrlBuilder {
        parts.append(part)
        return self
    }
    
    func p(placeholder: String) -> UrlBuilder {
        parts.append("#" + placeholder)
        return self
    }
    
    func r(placeholder: String, value: String) -> UrlBuilder {
        for (index, element) in parts.enumerate() {
            if element == "#" + placeholder {
                parts[index] = value
            }
        }
        return self
    }
    
    func create() -> String {
        var partsString:String = ""
        
        for part in parts {
            if partsString.characters.count > 0 {
                partsString += "/"
            }
            
            partsString += part
        }
     
        let combined = host + partsString
        
        print("Created url {\(combined)}")
        return combined;
    }
}