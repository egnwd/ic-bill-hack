//
//  FriendCollectionViewCell.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
  let cellSize = CGSize(width: 75, height: 82)
  let defaultColour = UIColor.whiteColor()

  var name: UILabel = UILabel()
  var avatar: UIImageView = UIImageView()
  var friend: Friend?
  var isChosen = false

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func populateWithFriend(friend: Friend) {
    self.friend = friend
    
    let imageLength = 48
    let imageX = (Int(cellSize.width) - imageLength) / 2
    avatar = UIImageView(frame: CGRect(x: imageX, y: 0, width: imageLength, height: imageLength))
    avatar.image = friend.picture
    self.addSubview(avatar)
    
    name = UILabel(frame: CGRect(x: 0, y: imageLength+10, width: Int(cellSize.width), height: 24))
    name.text = friend.name
    name.textAlignment = .Center
    self.addSubview(name)
  }
  
  func highlightCell(withColour colour: UIColor) {
    self.backgroundColor = colour
    friend!.colour = colour
  }
  
  func unhighlightCell() {
    self.backgroundColor = defaultColour
    friend!.colour = defaultColour
  }
}
