import Foundation
import CoreData
import UIKit

class ListViewController : UITableViewController {
    
    let token = UserData.getToken()!
    
    var index:Int?
    var list:NSManagedObject?
    var useStoryboard: UIStoryboard?
    
    fileprivate var cards:[NSManagedObject]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(list: NSManagedObject?, index: Int, useStoryboard: UIStoryboard) {
        super.init(style: UITableViewStyle.plain)
        self.index = index
        self.list = list
        self.useStoryboard = useStoryboard
    }
    
    override func viewDidLoad() {
        self.tableView.contentInset = UIEdgeInsetsMake(65,0,0,0)
    }
    
    func getIndex() -> Int {
        return self.index!
    }
    
    func getList() -> NSManagedObject {
        return self.list!
    }
    
    func getListId() -> String {
        return getList().value(forKey: "list_id") as! String
    }
    
    func reloadCards(_ scrollToLast: Bool = false) {
        let list_id = self.list?.value(forKey: "list_id") as! String
        
        let persistence = JakPersistence.get()
        
        if ReachabilityObserver.isConnected() {
            JakCard.loadCards(list_id, token: token) { (response) in
                if let arr = response.object as? [[String:Any]] {
                    for c in arr {
                        let _ = persistence.newCard(title: c["name"] as! String, desc: c["description"] as! String, card_id: c["card_id"] as! String, owner: c["owner"] as! String, list_id: c["list_id"] as! String)
                    }
                    
                    self.cards = persistence.getCards(list_id)
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        
                        if scrollToLast {
                            let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)
                            //self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
                            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                        }
                    })
                }
            }
        } else {
            self.cards = persistence.getCards(list_id)
        }
    }
    
    func deleteCard(_ card_id: String) {
        JakCard.deleteCard(card_id, token: token) { (response) in
            JakPersistence.get().cleanupCards(self.getListId())
            self.reloadCards()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = self.cards![(indexPath as NSIndexPath).row]
        UserData.setSelectedCardId(card_id: card.value(forKey: "card_id") as! String)
        
        let cardController = self.useStoryboard!.instantiateViewController(withIdentifier: "carddetail")
        self.present(cardController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardcell", for: indexPath) as! CardTableViewCell
        let index = (indexPath as NSIndexPath).row
        cell.title.text = cards![index].value(forKey: "title") as? String
        cell.title.textColor = UIColor.white
        
        let desc = (cards![index].value(forKey: "desc") as! String)
        if desc.characters.count != 0 {
            cell.desc.text = desc
            cell.desc.textColor = UIColor.white
        } else {
            cell.desc.text = "No description"
            cell.desc.textColor = UIColor.lightGray
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card_id = self.cards![(indexPath as NSIndexPath).row].value(forKey: "card_id") as! String
            deleteCard(card_id)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cards != nil {
            return cards!.count
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
