//
//  Friend.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import Foundation
import UIKit

class Friend {
  var name: String 
  var picture: UIImage
  var mondoId: String
  
  init(name: String, pictureName: String, mondoId: String) {
    self.name = name
    self.picture = UIImage(named: pictureName)!
    self.mondoId = mondoId
  }
}