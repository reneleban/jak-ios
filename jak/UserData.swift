import Foundation
import CoreData

class UserData {
    
    fileprivate static var token:String? = nil
    fileprivate static var selectedBoardId:String? = nil
    fileprivate static var selectedCardId:String? = nil
    fileprivate static var largeview:Bool = true
    
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
    
    static func setSelectedCardId(card_id: String) {
        selectedCardId = card_id
    }
    
    static func getSelectedCardId() -> String? {
        return selectedCardId
    }
    
    static func setLargeView(largeview: Bool) {
        self.largeview = largeview
        JakKeychainHelper.setLargeView(largeview)
    }
    
    static func isLargeView() -> Bool {
        return largeview
    }
}
