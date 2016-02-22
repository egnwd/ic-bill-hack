//
//  FriendCollectionViewCell.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
  let cellSize = CGSize(width: 75, height: 100)
  let defaultColour = UIColor.clearColor()

  var name: UILabel = UILabel()
  var avatar: UIImageView = UIImageView()
  var friend: Friend?
  var isChosen = false

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func populateWithFriend(friend: Friend) {
    self.friend = friend
    
    let imageLength = 64
    let imageX = (Int(cellSize.width) - imageLength) / 2
    avatar = UIImageView(frame: CGRect(x: imageX, y: 0, width: imageLength, height: imageLength))
    avatar.image = friend.picture
    let lyr = avatar.layer
    lyr.masksToBounds = true
    lyr.cornerRadius = avatar.bounds.size.width / 2
    self.addSubview(avatar)
    
    name = UILabel(frame: CGRect(x: 0, y: imageLength+10, width: Int(cellSize.width), height: 24))
    name.text = friend.name
    name.textAlignment = .Center
    self.addSubview(name)
  }
  
  func highlightCell(withColour colour: UIColor) {
    self.avatar.layer.borderWidth = 4
    self.avatar.layer.borderColor = colour.CGColor
    friend!.colour = colour
  }
  
  func unhighlightCell() {
    self.avatar.layer.borderWidth = 0
    friend!.colour = defaultColour
  }
}
