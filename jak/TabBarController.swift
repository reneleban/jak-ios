import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    let list_image = UIImage(named: "list.png")
    let settings_image = UIImage(named: "settings.png")
    
    let selected_list_image = UIImage(named: "list_active.png")
    let selected_settings_image = UIImage(named: "settings_active.png")
    
    override func viewDidLoad() {
        self.tabBar.items?[0].title = "Boards"
        self.tabBar.items?[1].title = "Settings"
        
        self.tabBar.items?[0].image = list_image!
        self.tabBar.items?[1].image = settings_image!
        
        self.tabBar.items?[0].selectedImage = selected_list_image!
        self.tabBar.items?[1].selectedImage = selected_settings_image!
    }    
}
