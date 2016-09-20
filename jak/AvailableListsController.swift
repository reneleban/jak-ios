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
            if let lists = response.object as? [[String:Any]] {
                for list in lists {
                    let l = List(list_id: list["list_id"] as! String, board_id: list["board_id"] as! String, name: list["name"] as! String, owner: list["owner"] as! String)
                    self.lists.append(l)
                }
                
                self.tableView.reloadData()
            }
        }

    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listcell")! as UITableViewCell
        
        cell.textLabel?.text = lists[(indexPath as NSIndexPath).row].name
        cell.textLabel?.textColor = UIColor.white
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = lists[(indexPath as NSIndexPath).row]
        pageViewController!.selectList(list)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
}
