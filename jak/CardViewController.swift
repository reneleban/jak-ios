import Foundation
import UIKit

class CardViewController : UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    override func viewDidLoad() {
//        if UserData.selectedCard != nil {
//            let card = UserData.selectedCard!
//            titleField.text = card.title
//            descriptionField.text = card.desc
//        }
    }
    
    fileprivate func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        dismiss()
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        // Save here
        
        dismiss()
    }
}
