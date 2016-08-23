import Foundation
import UIKit

class ListViewController : UITableViewController {
    
    private var index:Int?
    private var list:List?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(list: List, index: Int) {
        super.init(style: UITableViewStyle.Plain)
        self.index = index
        self.list = list
    }
    
    func getIndex() -> Int {
        return self.index!
    }
    
    func getList() -> List {
        return self.list!
    }
}