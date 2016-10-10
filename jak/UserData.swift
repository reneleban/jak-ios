import Foundation
import CoreData

class UserData {
    
    fileprivate static var token:String? = nil
    //fileprivate static var selectedBoard:NSManagedObject? = nil
    fileprivate static var selectedBoardId:String? = nil
    
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
    
    static func getSelectedBoardId() -> String? {
        return selectedBoardId
    }
    
    static func setSelectedBoardId(board_id: String) {
        selectedBoardId = board_id
    }
}
