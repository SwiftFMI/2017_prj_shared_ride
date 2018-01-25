//
//  Utils.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 15.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Utils {
    static func getUserDetails(uuid: String, callBack: @escaping (_ user: User) -> Void ) {
        let ref = Database.database().reference().child(Constants.Users.ROOT).child(uuid)
        
        ref.observe(.value, with: { (snapshot) in
            
            if let nsd = snapshot.value as? NSDictionary {
                let email = nsd[Constants.Users.EMAIL] as! String
                let name = nsd[Constants.Users.NAME] as! String
                let phone = nsd[Constants.Users.PHONE] as! String
                
                let user = User(id: uuid, email: email, name: name, phone: phone)
                callBack(user)
            }
        })
    }
}
