import Foundation
import UIKit

class CardViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var pickedImage:UIImage? = nil
    
    var updateCard = true
    var selectedList:String?
    var listViewController:ListViewController?
    
    override func viewDidLoad() {
        imagePicker.delegate = self
        imageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CardViewController.imageTapped))
        imageView.addGestureRecognizer(tapRecognizer)
        
        if UserData.getSelectedCardId() != nil {
            let card = JakPersistence.get().getCard(UserData.getSelectedCardId()!)
            
            if card != nil {
                titleField.text = card?.value(forKey: "title") as? String
                descriptionField.text = card?.value(forKey: "desc") as? String
            }
        } else {
            self.title = "Add new card"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Abort", style: .plain, target: self, action: #selector(abort))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserData.setSelectedCardId(card_id: nil)
    }
    
    fileprivate func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        saveChanges()
    }
    
    func abort() {
        self.navigationController!.popViewController(animated: true)
    }
    
    func saveChanges() {
        if !updateCard {
            JakCard.addCard(self.titleField.text!, description: self.descriptionField.text!, list_id: selectedList!, token: UserData.getToken()!, handler: { (response) in
                if response.statusCode == 200 {
                    let card = response.object as! NSDictionary
                    let _ = JakPersistence.get().newCard(title: self.titleField.text!, desc: self.descriptionField.text!, card_id: card.value(forKey: "card_id") as! String, owner: card.value(forKey: "owner") as! String, list_id: self.selectedList!)
                    DispatchQueue.main.async(execute: {
                        self.listViewController!.reloadCards()
                        AppDelegate.navController!.popViewController(animated: true)
                    })
                }
            })
        }
    }
    
    func imageTapped(sender: AnyObject) {
        performSegue(withIdentifier: "showimage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.pickedImage != nil {
            if let viewController = segue.destination as? ImageViewController {
                viewController.setImage(self.pickedImage!)
            }
        } else {
            print("Picked image was nil")
        }
    }
    
    @IBAction func addPicture(_ sender: Any) {
        let sheet = UIAlertController(title: "Please choose", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Use picture of your photo library", style: .default, handler: { (UIAlertAction) in
            self.presentImagePicker(.photoLibrary)
        }))
        
        sheet.addAction(UIAlertAction(title: "Take picture with your camera", style: .default, handler: { (UIAlertAction) in
            self.presentImagePicker(.camera)
        }))
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func presentImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            self.pickedImage = pickedImage.copy() as? UIImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
