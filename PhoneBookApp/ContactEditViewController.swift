
import UIKit
import CoreData
import FirebaseStorage

class ContactEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var doneButtonPressed: UIBarButtonItem!
    @IBOutlet weak var contactPhoto : UIImageView!
    private let storage  = Storage.storage().reference()
    var myPickerController = UIImagePickerController()
    var id: Int32 = 0
    var person = Person()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = person.name
        phoneNumberField.text = String(person.phoneNumber)
        //contactPhoto.image = UIImage(named: "contactIcon")
        self.storage.child("images/" + String(self.id) + ".png").downloadURL { (url, error) in
            guard let url = url, error == nil else {
                self.contactPhoto.image = UIImage(named: "contactIcon")
                return}
            let urlString = url.absoluteString
            UserDefaults.standard.set(urlString, forKey: "url")
            self.contactPhoto.sd_setImage(with: url)
        }
    }
    
    @IBAction func selectContactPhotoButtonTapped(_ sender: Any) {
        myPickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [self](action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.myPickerController.sourceType = .camera
                self.present(myPickerController, animated: true, completion: nil)
            } else{
                AlertController.showAlert(inViewController: self, title: "Error!", message: "Camera not available")
                print("Camera not available")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [self](action:UIAlertAction) in
            self.myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            print("Picked a photo")
            contactPhoto.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func newImageUrl(completion:@escaping((String?) ->Void )) {
        guard let imageData = contactPhoto.image?.pngData() else {completion(nil); return}
        print("Upload in progress...")
        DispatchQueue.main.async{
            self.storage.child("images/" + String(self.id) + ".png").putData(imageData, metadata: nil, completion: { _, error in
                guard error == nil else{
                    print("Failed to upload")
                    completion(nil);
                    return
                }
            self.storage.child("images/" + String(self.id) + ".png").downloadURL { (url, error) in
                guard let url = url, error == nil else {completion(nil); return}
                let urlString = url.absoluteString
                UserDefaults.standard.set(urlString, forKey: "url")
                self.contactPhoto.sd_setImage(with: url)
                completion(urlString)
            }
        })
        }
    }
    
    
    @IBAction func onDoneTapped(_ sender: Any) {
        print("done button tapped")
        person.name = nameField.text!
        if phoneNumberField.text == ""{
            /*nameField.resignFirstResponder()
            phoneNumberField.text = String(person.phoneNumber)
            phoneNumberField.resignFirstResponder()
            AlertController.showAlert(inViewController: self, title: "Invalid Input", message: "Please fill the phone number field")*/
            nameField.resignFirstResponder()
            phoneNumberField.resignFirstResponder()
            phoneNumberField.customizeTextField()
            phoneNumberField.shake(horizantaly: 4)
        }
        else{
            person.phoneNumber = Int32(phoneNumberField.text!)!
            self.performSegue(withIdentifier: "showContactDetailEdited", sender: self)
        }
    }
}

