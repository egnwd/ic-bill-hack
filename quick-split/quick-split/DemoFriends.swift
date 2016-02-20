//
//  DemoFriends.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import Foundation
import UIKit

class DemoFriends {
  var friends: [Friend]
  static let sharedInstance = DemoFriends()
  
  init() {
    let alice = Friend(name: "Alice", pictureName: "alice.png", mondoId: "acc_1")
    let bob = Friend(name: "Bob", pictureName: "bob.png", mondoId: "acc_2")
    let clare = Friend(name: "Clare", pictureName: "clare.png", mondoId: "acc_3")
    let david = Friend(name: "David", pictureName: "david.png", mondoId: "acc_4")
    let elliot = Friend(name: "Elliot", pictureName: "elliot.png", mondoId: "acc_5")
    let fred = Friend(name: "Fred", pictureName: "fred.png", mondoId: "acc_6")
    let george = Friend(name: "George", pictureName: "george.png", mondoId: "acc_7")
    let harry = Friend(name: "Harry", pictureName: "harry.png", mondoId: "acc_8")
    let isaac = Friend(name: "Isaac", pictureName: "isaac.png", mondoId: "acc_9")
    let jonathan = Friend(name: "Jonathan", pictureName: "jonathan.png", mondoId: "acc_10")
    
    friends = [alice, bob, clare, david, elliot, fred, george, harry, isaac, jonathan]
  }
  
  static func getFriends() -> [Friend] {
    return sharedInstance.friends
  }

  static func demoFriends() -> DemoFriends {
    return sharedInstance
  }
  
}