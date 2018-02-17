//
//  DefaultsUtils.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 25.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import Foundation

final class Defaults {
    
    private init() {}
    
    static func removeLoggedUser() {
        UserDefaults.standard.removeObject(forKey: Constants.Defaults.USER)
    }
    
    static func setLoggedUser(user: User) {
        do {
            let jsonData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(jsonData, forKey: Constants.Defaults.USER)
        } catch {
            print(error)
        }
    }
    
    static func getLoggedUser() -> User? {
        do {
            let userData = UserDefaults.standard.data(forKey: Constants.Defaults.USER)
            if let safeUserData = userData {
                let myStruct = try JSONDecoder().decode(User.self, from: safeUserData)
                return myStruct
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
}
