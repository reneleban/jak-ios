import Foundation
import UIKit

class AvailableListsController: UITableViewController {
    
    var pageViewController:ListPageViewController?
    var lists:[List] = []
    
    override func viewDidLoad() {
        loadLists()
    }
    
    func loadLists() {
        self.lists.removeAll()
        
        let board_id = UserData.selectedBoard!.board_id
        JakList.loadLists(board_id, token: UserData.token!) { (response) in
            if let lists = response.object as? NSArray {
                for list in lists {
                    let l = List(list_id: list["list_id"] as! String, board_id: list["board_id"] as! String, name: list["name"] as! String, owner: list["owner"] as! String)
                    self.lists.append(l)
                }
                
                self.tableView.reloadData()
            }
        }

    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listcell")! as UITableViewCell
        
        cell.textLabel?.text = lists[indexPath.row].name
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let list = lists[indexPath.row]
        pageViewController!.selectList(list)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
}