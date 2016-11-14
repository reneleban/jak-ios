import Foundation

class UrlBuilder {
    
    let host: String
    var parts:[String] = []
    
    init(host: String) {
        self.host = host
    }
    
    init(_ service: Services) {
        self.host = service.rawValue
    }
    
    func a(_ part: String) -> UrlBuilder {
        parts.append(part)
        return self
    }
    
    func p(_ placeholder: String) -> UrlBuilder {
        parts.append("#" + placeholder)
        return self
    }
    
    func r(_ placeholder: String, value: String) -> UrlBuilder {
        for (index, element) in parts.enumerated() {
            if element == "#" + placeholder {
                parts[index] = value
            }
        }
        return self
    }
    
    func create() -> String {
        var partsString = ""
        
        for part in parts {
            if partsString.characters.count > 0 {
                partsString += "/"
            }
            
            partsString += part
        }
     
        return host + partsString
    }
    
    func debug(_ host: Bool) -> String {
        var debugParts = ""
        
        for part in parts {
            if !host || debugParts.characters.count > 0 {
                debugParts += "/"
            }
            
            if part.characters.count <= 36 {
                debugParts += part
            } else {
                debugParts += "..."
            }
        }
        
        if host {
            debugParts = self.host + debugParts
        }
        
        return debugParts
    }
}
