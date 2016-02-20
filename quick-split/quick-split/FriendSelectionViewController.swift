//
//  FriendSelectionViewController.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class FriendSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var friends: [Friend] = []
  @IBOutlet var friendCollectionView: UICollectionView!
  var colours: [UIColor] = []
  var selectedFriends: [Friend] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    friends = DemoFriends.getFriends()
    let green = UIColor.greenColor()
    let yellow = UIColor.yellowColor()
    let purple = UIColor.purpleColor()
    let red = UIColor.redColor()
    let blue = UIColor.blueColor()
    colours = [green, yellow, purple, red, blue]
      
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
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return friends.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = friendCollectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCollectionViewCell
    cell.populateWithFriend(friends[indexPath.row])
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = friendCollectionView.cellForItemAtIndexPath(indexPath) as! FriendCollectionViewCell
    if (cell.isChosen) {
      if let friend = cell.friend {
        colours.append(friend.colour!)
        let defaultColour = UIColor.whiteColor()
        cell.backgroundColor = defaultColour
        friend.colour = defaultColour
      }
    } else {
      if (colours.count == 0) { return }
      let colour = colours.popLast()
      cell.backgroundColor = colour
      if let friend = cell.friend {
        friend.colour = colour
        selectedFriends.append(friend);
      }
    }
     cell.isChosen = !cell.isChosen
  }
  
}