import UIKit
import CoreData
import Firebase
import GoogleSignIn
import AVFoundation

var myIndex = 0
let appDelegate = UIApplication.shared.delegate as? AppDelegate

class ViewController: UIViewController, UITableViewDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        <#code#>
//    }
    
    
    @IBOutlet weak var tableView: UITableView!

    var people = [Person]()
    var calls = [Calls]()
    var maxPeopleId : Int32 = 0 // nr of people in the table
    var maxCallId : Int32 = 0
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true;
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "song", ofType: "wav")!))
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("audio playing")
        }
        catch{
            print(error)
            return
        }
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        do {
            let people = try PersistenceServce.context.fetch(fetchRequest)
            for person in people{
                if person.uid == Auth.auth().currentUser?.uid{
                    self.people.append(person)
                }
                if person.id > maxPeopleId { maxPeopleId = person.id}
            }
            self.people.sort(by: {$0.phoneNumber < $1.phoneNumber})
            self.people.sort(by: {$0.name! < $1.name!})
            self.tableView.reloadData()
            self.tableView.delegate = self
            self.tableView.dataSource = self
        } catch {}
        let fetchRequest2: NSFetchRequest<Calls> = Calls.fetchRequest()
        do {
            let calls = try PersistenceServce.context.fetch(fetchRequest2)
//            for item in calls {
//                PersistenceServce.context.delete(item)
//                PersistenceServce.saveContext()
//                }
            for call in calls{
                if call.idCaller == Auth.auth().currentUser?.uid{
                    self.calls.append(call)
                }
                if call.idCall > maxCallId { maxCallId = call.idCall}
            }
        } catch {}
        self.calls.sort(by: {$0.idCall > $1.idCall})
    }
    
    @IBAction func onPlusTapped() {
        let alert = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words;
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Phone Number"
            textField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
        
        let action = UIAlertAction(title: "Add", style: .default) { (_) in
            let name = alert.textFields!.first!.text!
            let phoneNumber = alert.textFields!.last!.text!
            let uid = Auth.auth().currentUser?.uid
            if Int32(phoneNumber) != nil{
                let person = Person(context: PersistenceServce.context)
                person.name = name
                person.phoneNumber = Int32(phoneNumber)!;
                person.uid = uid
                person.id = self.maxPeopleId + 1
                self.maxPeopleId += 1
                print(person.id)
                print(person.name)
                PersistenceServce.saveContext()
                self.people.append(person)
                self.people.sort(by: {$0.phoneNumber < $1.phoneNumber})
                self.people.sort(by: {$0.name! < $1.name!})
                self.tableView.reloadData()
            }
            else{
                AlertController.showAlert(inViewController: self, title: "Invalid Input", message: "Please fill the phone number field")
            }
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = people[indexPath.row].name
        cell.detailTextLabel?.text = String(people[indexPath.row].phoneNumber)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        myIndex = indexPath.row
        performSegue(withIdentifier: "showContactDetail", sender: self)
        }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        print("Deleted row ", indexPath)
        PersistenceServce.context.delete(people[indexPath.row])
        PersistenceServce.saveContext()

        self.people.remove(at: indexPath.row)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableView.endUpdates()
        self.tableView.reloadData()
        
      }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactDetailViewController {
            destination.person = people[(self.tableView.indexPathForSelectedRow?.row)!]
            destination.personId = people[(self.tableView.indexPathForSelectedRow?.row)!].id
            destination.calls = self.calls
            destination.maxCallId = self.maxCallId
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
        }
        if let destination = segue.destination as? SignInViewController{
            if audioPlayer.isPlaying{
                audioPlayer.stop()
                print("audio stopped")
            }
        }
//        if let destination = segue.destination as? CallsCollectionViewController{
//            destination.calls = self.calls
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.people.sort(by: {$0.phoneNumber < $1.phoneNumber})
        self.people.sort(by: {$0.name! < $1.name!})
        let fetchRequest2: NSFetchRequest<Calls> = Calls.fetchRequest()
        do {
            let calls = try PersistenceServce.context.fetch(fetchRequest2)
            for call in calls{
                if call.idCall > maxCallId { maxCallId = call.idCall}
            }
        } catch {}
        self.calls.sort(by: {$0.idCall > $1.idCall})
        self.tableView.reloadData()
    }
}
