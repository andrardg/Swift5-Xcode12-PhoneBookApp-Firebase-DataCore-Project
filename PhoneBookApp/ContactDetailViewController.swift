
import UIKit
import Photos
import SDWebImage
import Firebase
import FirebaseStorage
import UserNotifications

class ContactDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UNUserNotificationCenterDelegate  {
    @IBOutlet weak var tableView: UITableView!

    var person = Person()
    var calls = [Calls]()
    var personId: Int32 = 0
    var maxCallId : Int32 = 0
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var contactPhoto : UIImageView!
    private let storage  = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = person.name
        phoneNumberLabel.text = String(person.phoneNumber)
        //contactPhoto.image = UIImage(named: "contactIcon")
        self.storage.child("images/" + String(self.personId) + ".png").downloadURL { (url, error) in
            guard let url = url, error == nil else {
                self.contactPhoto.image = UIImage(named: "contactIcon")
                return}
            let urlString = url.absoluteString
            UserDefaults.standard.set(urlString, forKey: "url")
            print(url)
            self.contactPhoto.sd_setImage(with: url)
        }
        //if contactPhoto.image.size.width == 0
    }
    
    @IBAction func onCallTapped(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        let content = UNMutableNotificationContent()
        content.title = "You are calling..."
        if self.person.name != "" {
            content.body = String(self.person.name!)
            
        }
        else{
            content.body = String(self.person.phoneNumber)
        }
        let callingDate = Date().addingTimeInterval(1)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: callingDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        center.add(request) {(error) in }
        
            let call = Calls(context: PersistenceServce.context)
            call.idCaller = Auth.auth().currentUser?.uid
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "MMM dd,yyyy HH:mm:ss"
            let date = Date()
            call.date = dateFormatterGet.string(from: date)
            if self.person.name != "" {
                call.namePerson = self.person.name}
            else{
                call.namePerson = String(self.person.phoneNumber)
            }
            call.idCall = self.maxCallId + 1
            self.maxCallId += 1
            print("Added call:")
            print(call.idCall)
            print(call.idCaller!)
            print(call.namePerson!)
            print(call.date!)
            self.calls.append(call)
            self.calls.sort(by: {$0.idCall > $1.idCall})
            PersistenceServce.saveContext()
        }

    @IBAction func onEditTapped(_ sender: Any) {
        performSegue(withIdentifier: "showContactEdit", sender: self)
    }

    @IBAction func onShareTapped(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [person.name, person.phoneNumber, contactPhoto], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactEditViewController {
            destination.person = self.person
            destination.id = self.personId
            destination.contactPhoto = self.contactPhoto
        }
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        guard let source = segue.source as? ContactEditViewController else {return}
        self.person = source.person
        print(self.person.phoneNumber)
        if self.contactPhoto.image != source.contactPhoto.image/* && source.contactPhoto.image != UIImage(named: "contactIcon")*/{
            self.contactPhoto.image = source.contactPhoto.image
            source.newImageUrl{ (str) in print(str!)}
            print("contact photo change")
        }
        PersistenceServce.saveContext()
        nameLabel.text = person.name
        phoneNumberLabel.text = String(person.phoneNumber)
        }
}


