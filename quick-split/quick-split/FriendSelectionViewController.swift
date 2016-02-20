//
//  FriendSelectionViewController.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class FriendSelectionViewController: UIViewController, UICollectionViewDelegate {
  
  var friends: [Friend] = []
  @IBOutlet var friendCollectionView: UICollectionViewController!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    friends = DemoFriends.getFriends()
    friendCollectionView.delete(self)
      
    // Do any additional setup after loading the view.
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
  
  // MARK: - Collection

}
