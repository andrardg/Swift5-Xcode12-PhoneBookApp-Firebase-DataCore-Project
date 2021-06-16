
import UIKit
import CoreData
import Firebase

class CallsCollectionViewController: UICollectionViewController {

    var calls = [Calls]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        let fetchRequest2: NSFetchRequest<Calls> = Calls.fetchRequest()
        do {
            let calls = try PersistenceServce.context.fetch(fetchRequest2)
            for call in calls{
                if call.idCaller == Auth.auth().currentUser?.uid{
                    self.calls.append(call)
                }
            }
        } catch {}
        self.calls.sort(by: {$0.idCall > $1.idCall})
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let callCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CallsCollectionViewCell{
            callCell.configure(with: calls[indexPath.row])
            cell = callCell
        }
        return cell
   }
}
