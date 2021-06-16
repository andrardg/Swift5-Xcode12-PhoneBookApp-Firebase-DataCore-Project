//
//  CallsCollectionViewCell.swift
//  PhoneBookApp
//
//  Created by user192493 on 6/11/21.
//

import UIKit
import Foundation
class CallsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func configure(with call: Calls){
        nameLabel.text = call.namePerson
        dateLabel.text = call.date
        
    }
}
