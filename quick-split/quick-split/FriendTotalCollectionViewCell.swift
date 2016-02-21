//
//  FriendTotalCollectionViewCell.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class FriendTotalCollectionViewCell: UICollectionViewCell {
  let cellSize = CGSize(width: 80, height: 110)
  let defaultColour = UIColor.whiteColor()
  let defaultBorderWidth: CGFloat = 4.0
  let maxBorderWidth: CGFloat = 6.0
  
  var indicator: UIView = UIView()

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
    indicator.frame = CGRect(x: cellSize.width/8, y: -defaultBorderWidth, width: cellSize.width*3/4, height: defaultBorderWidth)
    self.addSubview(indicator)
  }
  
  func populateWithFriend(friend: Friend) {
    self.friend = friend
    
    let imageLength = 64
    let imageX = (Int(cellSize.width) - imageLength) / 2
    avatar = UIImageView(frame: CGRect(x: imageX, y: 10, width: imageLength, height: imageLength))
    avatar.image = friend.picture
    let lyr = avatar.layer
    lyr.masksToBounds = true
    lyr.cornerRadius = avatar.bounds.size.width / 2
    self.addSubview(avatar)
    
    totalLabel = UILabel(frame: CGRect(x: 0, y: imageLength+10, width: Int(cellSize.width), height: 24))
    totalLabel.text = priceFormat(0)
    totalLabel.textAlignment = .Center
    self.addSubview(totalLabel)
    
    self.highlightCell(withColour: friend.colour!)
  }
  
  func highlightCell(withColour colour: UIColor) {
    setBorderWidth(defaultBorderWidth)
    self.avatar.layer.borderColor = colour.CGColor
    self.indicator.backgroundColor = colour
    friend!.colour = colour
  }
  
  func unhighlightCell() {
    setBorderWidth(0)
    friend!.colour = defaultColour
  }
  
  func selectCell() {
    showIndicator(true)
  }
  
  func deselectCell() {
    showIndicator(false)
  }
  
  private func showIndicator(show: Bool) {
    let amount = show ? defaultBorderWidth : -defaultBorderWidth
    UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
      self.indicator.frame.origin.y += amount
    }, completion: nil)
  }
  
  private func setBorderWidth(width: CGFloat) {
    self.avatar.layer.borderWidth = width
  }
  
  private func priceFormat(price: Int) -> String {
    return String(format: "£%d.%02d", arguments: [price / 100, price % 100])
  }
}
