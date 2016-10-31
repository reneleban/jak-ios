import Foundation
import UIKit

class RegisterController : UIViewController {
    
    var loginController: LoginController?
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
        
    @IBAction func doRegister(_ sender: AnyObject) {
        (sender as! UIBarButtonItem).isEnabled = false
        
        if emailAddress.text?.characters.count == 0 {
            let alertController = UIAlertController(title: "E-Mail Address is empty", message: "Please specify a valid e-mail address!", preferredStyle: .alert)
            showAlertController(alertController)
        } else if password1.text != password2.text {
            let alertController = UIAlertController(title: "Passwords do not match", message: "Please enter the same passwords into each text field!", preferredStyle: .alert)
            showAlertController(alertController)
        } else {
            JakLogin.register(emailAddress.text!, password: password1.text!, handler: { (response) in
                DispatchQueue.main.async(execute: {
                    if response.statusCode != 200 {
                        let alertController = UIAlertController(title: "Account already exists", message: "It seems your account already exists. Try to login with given credentials!", preferredStyle: .alert)
                        self.showAlertController(alertController)
                    } else {
                        let alertController = UIAlertController(title: "Account created", message: "Your account has been created. You can now login!", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            self.dismissViewController()
                        }))
                        
                        self.loginController?.setCredentials(self.emailAddress.text!, password: self.password1.text!)
                    }
                })
            })
        }
        
        (sender as! UIBarButtonItem).isEnabled = false
    }
    
    @IBAction func abortRegister(_ sender: AnyObject) {
        dismissViewController()
    }
    
    func showAlertController(_ alertController: UIAlertController) {
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
