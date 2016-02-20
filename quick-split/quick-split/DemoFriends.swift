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
  
  init() {
    let alice = Friend.init(name: "Alice", pictureName: "alice.png", mondoId: "acc_1")
    let bob = Friend.init(name: "Bob", pictureName: "bob.png", mondoId: "acc_2")
    let clare = Friend.init(name: "Clare", pictureName: "clare.png", mondoId: "acc_3")
    let david = Friend.init(name: "David", pictureName: "david.png", mondoId: "acc_4")
    let elliot = Friend.init(name: "Elliot", pictureName: "elliot.png", mondoId: "acc_5")
    let fred = Friend.init(name: "Fred", pictureName: "fred.png", mondoId: "acc_6")
    let george = Friend.init(name: "George", pictureName: "george.png", mondoId: "acc_7")
    let harry = Friend.init(name: "Harry", pictureName: "harry.png", mondoId: "acc_8")
    let isaac = Friend.init(name: "Isaac", pictureName: "isaac.png", mondoId: "acc_9")
    let jonathan = Friend.init(name: "Jonathan", pictureName: "jonathan.png", mondoId: "acc_10")
    
    friends = [alice, bob, clare, david, elliot, fred, george, harry, isaac, jonathan]
  }
  
  func getFriends() -> [Friend] {
    return self.friends
  }
}