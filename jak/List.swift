import Foundation

class List {
    
    var list_id: String
    var board_id: String
    var name: String
    var owner: String
    
    init(list_id: String, board_id: String, name: String, owner: String) {
        self.list_id = list_id
        self.board_id = board_id
        self.name = name
        self.owner = owner
    }
}