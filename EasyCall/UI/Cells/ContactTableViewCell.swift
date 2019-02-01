//
//  ContactTableViewCell.swift
//  EasyCall
//
//  Created by formation 8 on 23/01/2019.
//  Copyright © 2019 mojito. All rights reserved.
//

import UIKit
import FontAwesome_swift

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var labelContactFirstName: UILabel!
    @IBOutlet weak var labelContactLastName: UILabel!
    @IBOutlet weak var imageViewGravatar: UIImageView!
    @IBOutlet weak var buttonPhone: UIButton!
    
    var contactPhoneNumber: String!
    var contactEmail: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageViewGravatar.layer.cornerRadius = 5
        buttonPhone.titleLabel?.font = UIFont.fontAwesome(ofSize: 55, style: .solid)
        buttonPhone.setTitle(String.fontAwesomeIcon(name: .phoneSquare), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func tapToCall(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2,
             animations: {
                sender.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        },
             completion: { finish in
                UIButton.animate(withDuration: 0.2, animations: {
                    sender.transform = CGAffineTransform.identity
                })
        })
        open(scheme: "tel:\(self.contactPhoneNumber!)")
    }
    
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: {
                    (success) in
                    print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
}
