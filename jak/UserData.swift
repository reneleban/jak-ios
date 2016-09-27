import Foundation
import CoreData

class UserData {
    
    fileprivate static var token:String? = nil
    fileprivate static var selectedBoard:NSManagedObject? = nil
    
    // TODO: Switch to NSManagedObject
    static var selectedCard:Card? = nil
    
    static func setToken(_ token: String) {
        if self.token == nil {
            self.token = token
        }
    }
    
    static func getToken() -> String? {
        return token
    }
    
    static func getSelectedBoardName() -> String? {
        if selectedBoard != nil {
            return selectedBoard!.value(forKey: "name") as? String
        }
        
        return nil
    }
    
    static func getSelectedBoardId() -> String? {
        if selectedBoard != nil {
            return selectedBoard!.value(forKey: "board_id") as? String
        }
        
        return nil
    }
    
    
}
