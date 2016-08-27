import Foundation
import UIKit

class CardViewController : UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    override func viewDidLoad() {
        if UserData.selectedCard != nil {
            let card = UserData.selectedCard!
            titleField.text = card.title
            descriptionField.text = card.desc
        }
    }
    
    private func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        dismiss()
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        // Save here
        
        dismiss()
    }
}