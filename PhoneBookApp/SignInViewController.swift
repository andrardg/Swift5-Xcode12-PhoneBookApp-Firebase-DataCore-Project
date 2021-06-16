import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleSignInButton : GIDSignInButton!

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let user = user else {return}
        guard let authentication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: {(AuthResult ,error) in
            if let error = error{
                print("Firebase sign in error with Google Account")
                print(error)
            }
            print("User sign in with Firebase and Google account, email is " +  user.profile.email)
            self.performSegue(withIdentifier: "showSignedInSegue", sender: nil)
        })
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    @IBAction func OnSignInTapped(_ sender: Any) {
        guard let email = emailTextField.text, email != "",
              let password = passwordTextField.text, password != ""
        else{
            AlertController.showAlert(inViewController: self, title: "Invalid Input", message: "Please fill all the fields")
            return}
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            guard error == nil else{
                AlertController.showAlert(inViewController: self, title: "Invalid Input", message: error!.localizedDescription)
                return
            }
            guard let user = user else {return}
            print(user.user.email ?? "MISSING EMAIL")
            print(user.user.displayName ?? "MISSING DISPLAY NAME")
            print(user.user.uid)
            self.performSegue(withIdentifier: "showSignedInSegue", sender: nil)
        })
    }

    @IBAction func onGoToSignUpTapped(_ sender: Any) {
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        self.performSegue(withIdentifier: "showSignUpSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true;
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func unwindWithSegue2(_ segue: UIStoryboardSegue) {
        do{
            GIDSignIn.sharedInstance()?.signOut()
            try Auth.auth().signOut()
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        } catch let signOutError as NSError{
            print(signOutError)
            return
        }
        print("SIGNED OUT SUCCESSFULLY")
    }
}
