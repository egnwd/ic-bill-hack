//
//  FriendTotalCollectionViewCell.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class FriendTotalCollectionViewCell: UICollectionViewCell {
  let cellSize = CGSize(width: 75, height: 110)
  let defaultColour = UIColor.whiteColor()

  var total: Int = 0 {
    didSet {
      totalLabel.text = priceFormat(total)
    }
  }
  var totalLabel: UILabel = UILabel()
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
    
    totalLabel = UILabel(frame: CGRect(x: 0, y: imageLength+10, width: Int(cellSize.width), height: 24))
    totalLabel.text = priceFormat(0)
    totalLabel.textAlignment = .Center
    self.addSubview(totalLabel)
    
    self.highlightCell(withColour: friend.colour!)
  }
  
  func highlightCell(withColour colour: UIColor) {
    self.backgroundColor = colour
    friend!.colour = colour
  }
  
  func unhighlightCell() {
    self.backgroundColor = defaultColour
    friend!.colour = defaultColour
  }
  
  func selectCell() {
    self.totalLabel.textColor = UIColor.whiteColor()
    self.isChosen = true
  }
  
  func deselectCell() {
    self.totalLabel.textColor = UIColor.blackColor()
    self.isChosen = false
  }
  
  private func priceFormat(price: Int) -> String {
    return String(format: "£%d.%02d", arguments: [price / 100, price % 100])
  }
}
