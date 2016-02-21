//
//  PriceAllocationViewController.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit
import CoreGraphics

class PriceAllocationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SelectImageViewDelegate, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet var friendCollectionView: UICollectionView!
  @IBOutlet var instructions: UILabel!
  @IBOutlet var nextButton: UIButton!
  @IBOutlet var pricesTable: UITableView!
  @IBOutlet weak var imageView: SelectImageView!
  @IBOutlet var displayImageView: UIImageView!
    
  var friends: [Friend] = []
  var selectedFriend: FriendTotalCollectionViewCell?
  var dummyPrices: Dictionary<Int, FriendTotalCollectionViewCell?> = [95: nil, 45: nil, 160: nil, 1000: nil, 52136: nil]
  var selectionCount = 0

  override func viewDidLoad() {
    weak var selectionDisplayImageView: UIImageView!
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Set the delegate of the SelectImageView
    imageView.delegate = self
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
  // MARK: - SelectImageViewDelegate
  func selectionWasMade(selection: CGRect) {
    NSLog("Selection made")
    let ref:CGImageRef = CGImageCreateWithImageInRect(imageView.image?.CGImage, selection)!
    let croppedImage:UIImage = UIImage(CGImage: ref)
    displayImageView.image = croppedImage
  }
  
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "goToConfirmation") {
      let confirmation = segue.destinationViewController as! ConfirmationViewController
      confirmation.friends = self.getFriends()
    }
  }
  
  // MARK: - Collection
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return friends.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendTotalCollectionViewCell
    cell.populateWithFriend(friends[indexPath.row])
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let old_friend = selectedFriend {
      old_friend.deselectCell()
    }
    let cell = friendCollectionView.cellForItemAtIndexPath(indexPath) as? FriendTotalCollectionViewCell
    if (cell !== selectedFriend) {
      selectedFriend = cell!
      selectedFriend!.selectCell()
    } else {
      selectedFriend = nil
    }
  }
  
  func getFriends() -> [FriendTotalCollectionViewCell] {
    let cells = friendCollectionView.visibleCells() as! [FriendTotalCollectionViewCell]
    return cells.filter({$0.total != 0})
  }
  
  // MARK: - Table View
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dummyPrices.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PriceCell", forIndexPath: indexPath)
    let price = Array(dummyPrices.keys)[indexPath.row]
    cell.textLabel?.backgroundColor = UIColor.clearColor()
    cell.textLabel?.text = String(format: "£%d.%02d", arguments: [price / 100, price % 100])
    cell.textLabel?.textAlignment = .Right
    cell.textLabel?.frame.origin.x = 375 - (cell.textLabel?.frame.width)!
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    guard selectedFriend != nil else { return }
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    let price = getPrice((cell?.textLabel!.text!)!)
    if let friend = dummyPrices[price] {
      friend?.total -= price
      if (friend !== nil) {
        selectionCount--
      }
    }
    cell?.backgroundColor = selectedFriend!.friend?.colour
    dummyPrices[price] = selectedFriend!
    selectedFriend!.total += price
    selectionCount++
    updateNavigation()
  }
  
  func getPrice(text: String) -> Int {
    let stringArray = text.componentsSeparatedByCharactersInSet(
      NSCharacterSet.decimalDigitCharacterSet().invertedSet)
    let newString = stringArray.joinWithSeparator("")
    return Int(newString)!
  }
  
  @IBAction func longPressed(sender: UILongPressGestureRecognizer)
  {
    let touchLoc = sender.locationInView(pricesTable)
    if let indexPath = pricesTable.indexPathForRowAtPoint(touchLoc) {
      let cell = pricesTable.cellForRowAtIndexPath(indexPath)
      cell?.backgroundColor = UIColor.whiteColor()
      let price = getPrice((cell?.textLabel!.text!)!)
      if let friend = dummyPrices[price] {
        friend?.total -= price
        selectionCount--
      }
      dummyPrices.removeValueForKey(price)
    }
    updateNavigation()
  }
  
  func updateNavigation() {
    let canProceed = selectionCount >= 1
    nextButton.hidden = !canProceed
    instructions.hidden = canProceed
  }
}
