import Foundation
import CoreData
import UIKit

class AvailableListsController: UITableViewController {
    
    var pageViewController:ListPageViewController?
    var lists:[NSManagedObject]?
    
    override func viewDidLoad() {
        loadLists()
    }
    
    func loadLists() {
        let board_id = UserData.getSelectedBoardId()!
        self.lists = JakPersistence.get().getLists(board_id)
        
        self.tableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listcell")! as UITableViewCell
        
        let list = lists![(indexPath as NSIndexPath).row]
        cell.textLabel?.text = list.value(forKey: "name") as? String
        cell.textLabel?.textColor = UIColor.white
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = lists![(indexPath as NSIndexPath).row]
        pageViewController!.selectList(list)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists!.count
    }
}
