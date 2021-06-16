import UIKit
import Firebase
class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func OnSignUpTapped(_ sender: UIButton!) {
        guard let email = emailTextField.text, email != "",
              let password = passwordTextField.text, password != ""
        else{
            AlertController.showAlert(inViewController: self, title: "Invalid Input", message: "Please fill all the fields")
            return}

        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            guard error == nil else{
                AlertController.showAlert(inViewController: self, title: "Invalid Input", message: error!.localizedDescription)
                return
            }
            guard let user = user else {
                return
            }
            print(user.user.email ?? "MISSSING EMAIL")
            print(user.user.uid)
            let changeRequest = user.user.createProfileChangeRequest()
            changeRequest.commitChanges(completion: {(error) in
                guard error == nil else{
                    AlertController.showAlert(inViewController: self, title: "Error!", message: error!.localizedDescription)
                    return
                }
                
            })
            AlertController.showAlert(inViewController: self, title: "Congratulations!", message: "Signed Up Successfully")
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
