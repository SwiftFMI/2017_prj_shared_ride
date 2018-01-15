//
//  ReplaceSegue.swift
//  SharedTogether
//
//  Created by Rosen Stoyanov on 15.01.18.
//  Copyright © 2018 SharedTogether Team. All rights reserved.
//

import UIKit

class ReplaceSegue: UIStoryboardSegue {
    
    override func perform() {
//        if let source = source.navigationController {
//            source.navigationController?.setViewControllers([destination], animated: true)
//        }
        
        UIApplication.shared.keyWindow?.rootViewController = destination;
    }

}
