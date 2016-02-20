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

  var name: UILabel
  var avatar: UIImageView
  var friend: Friend
  
  init(friend: Friend, origin: CGPoint) {
    let frame = CGRect(x: origin.x, y: origin.y, width: cellSize.width, height: cellSize.height)
    self.friend = friend
    
    let imageLength = 48
    let imageX = Int(cellSize.width) - (imageLength/2)
    avatar = UIImageView(frame: CGRect(x: imageX, y: 0, width: imageLength, height: imageLength))
    avatar.image = friend.picture
    
    name = UILabel(frame: CGRect(x: 0, y: imageLength+10, width: Int(cellSize.width), height: 24))
    name.text = friend.name
    
    super.init(frame: frame)
  }

  // Not called as we are not use a nib
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
