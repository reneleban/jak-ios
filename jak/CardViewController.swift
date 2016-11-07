import Foundation
import UIKit

class CardViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var pickedImage:UIImage? = nil
    
    override func viewDidLoad() {
        imagePicker.delegate = self
        imageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CardViewController.imageTapped))
        imageView.addGestureRecognizer(tapRecognizer)
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
