//
//  ConfirmationViewController.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.21.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {
  
  var friends: [FriendTotalCollectionViewCell] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    print(friends.count)
    // Call api
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
  */

}
