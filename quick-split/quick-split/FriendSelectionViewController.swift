//
//  FriendSelectionViewController.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class FriendSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  @IBOutlet var friendCollectionView: UICollectionView!
  @IBOutlet var instructions: UILabel!
  @IBOutlet var nextButton: UIButton!
  
  var friends: [Friend] = []
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
    

  
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "goToPriceAllocation") {
      let priceAllocator = segue.destinationViewController as! PriceAllocationViewController
      priceAllocator.friends = self.selectedFriends
    }
  }

  
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
      colours.append(cell.friend!.colour!)
      cell.unhighlightCell()
      selectedFriends.removeAtIndex(selectedFriends.indexOf({$0 === cell.friend!})!)
    } else {
      if (colours.count == 0) { return }
      let colour = colours.popLast()
      cell.highlightCell(withColour: colour!)
      selectedFriends.append(cell.friend!);
    }
    cell.isChosen = !cell.isChosen
    
    let canProceed = selectedFriends.count >= 1
    nextButton.hidden = !canProceed
    instructions.hidden = canProceed
  }
  
}