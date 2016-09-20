import Foundation
import UIKit

class ListViewController : UITableViewController {
    var index:Int?
    var list:List?
    var useStoryboard: UIStoryboard?
    
    fileprivate var cards:[Card] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(list: List, index: Int, useStoryboard: UIStoryboard) {
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
    
    func getList() -> List {
        return self.list!
    }
    
    func reloadCards(_ scrollToLast: Bool = false) {
        JakCard.loadCards((list?.list_id)!, token: UserData.token!) { (response) in
            if let arr = response.object as? [[String:Any]] {
                self.cards.removeAll()
                for c in arr {
                    let card = Card(title: c["name"] as! String, desc: c["description"] as! String, card_id: c["card_id"] as! String, owner: c["owner"] as! String, list_id: c["list_id"] as! String)
                    self.cards.append(card)
                }
                
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
    }
    
    func deleteCard(_ card_id: String) {
        JakCard.deleteCard(card_id, token: UserData.token!) { (response) in
            self.reloadCards()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = self.cards[(indexPath as NSIndexPath).row]
        UserData.selectedCard = card
        
        let cardController = self.useStoryboard!.instantiateViewController(withIdentifier: "carddetail")
        self.present(cardController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardcell", for: indexPath) as! CardTableViewCell
        let index = (indexPath as NSIndexPath).row
        cell.title.text = cards[index].title!
        cell.title.textColor = UIColor.white
        
        if cards[index].desc!.characters.count != 0 {
            cell.desc.text = cards[index].desc!
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
            let card_id = self.cards[(indexPath as NSIndexPath).row].card_id
            deleteCard(card_id!)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
