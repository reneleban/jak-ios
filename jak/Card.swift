import Foundation

class Card {
    
    var title: String?
    var desc: String?
    var card_id: String?
    var owner: String?
    var list_id: String?
    
    init(title: String, desc: String, card_id: String, owner: String, list_id: String) {
        self.title = title
        self.desc = desc
        self.card_id = card_id
        self.owner = owner
        self.list_id = list_id
    }
}
