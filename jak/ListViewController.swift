import Foundation
import UIKit

class ListViewController : UITableViewController {
    var index:Int?
    var list:List?
    var useStoryboard: UIStoryboard?
    
    private var cards:[Card] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(list: List, index: Int, useStoryboard: UIStoryboard) {
        super.init(style: UITableViewStyle.Plain)
        self.index = index
        self.list = list
        self.useStoryboard = useStoryboard
    }
    
    override func viewDidLoad() {
        //self.tableView.registerClass(CardTableViewCell.self, forCellReuseIdentifier: "cardcell")
        self.tableView.contentInset = UIEdgeInsetsMake(65,0,0,0)
    }
    
    func getIndex() -> Int {
        return self.index!
    }
    
    func getList() -> List {
        return self.list!
    }
    
    func reloadCards() {
        JakCard.loadCards((list?.list_id)!, token: UserData.token!) { (response) in
            if let arr = response.object as? NSArray {
                self.cards.removeAll()
                for c in arr {
                    let card = Card(title: c["name"] as! String, desc: c["description"] as! String, card_id: c["card_id"] as! String, owner: c["owner"] as! String, list_id: c["list_id"] as! String)
                    self.cards.append(card)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func deleteCard(card_id: String) {
        JakCard.deleteCard(card_id, token: UserData.token!) { (response) in
            self.reloadCards()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let card = self.cards[indexPath.row]
        UserData.selectedCard = card
        
        let cardController = self.useStoryboard!.instantiateViewControllerWithIdentifier("carddetail")
        self.presentViewController(cardController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cardcell", forIndexPath: indexPath) as! CardTableViewCell
        let index = indexPath.row
        cell.title.text = cards[index].title!
        cell.title.textColor = UIColor.whiteColor()
        
        if cards[index].desc!.characters.count != 0 {
            cell.desc.text = cards[index].desc!
            cell.desc.textColor = UIColor.whiteColor()
        } else {
            cell.desc.text = "No description"
            cell.desc.textColor = UIColor.lightGrayColor()
        }
        
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let card_id = self.cards[indexPath.row].card_id
            deleteCard(card_id!)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}