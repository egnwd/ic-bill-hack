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
  var colour: UIColor?
  
  init(name: String, pictureName: String, mondoId: String) {
    self.name = name
    self.picture = UIImage(named: pictureName)!.circle!
    self.mondoId = mondoId
  }
}

private extension UIImage {
  var circle: UIImage? {
    let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
    let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
    imageView.contentMode = .ScaleAspectFill
    imageView.image = self
    imageView.layer.cornerRadius = square.width/2
    imageView.layer.masksToBounds = true
    UIGraphicsBeginImageContext(imageView.bounds.size)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    imageView.layer.renderInContext(context)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result
  }
}