//
//  PriceAllocationViewController.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit

class PriceAllocationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet var friendCollectionView: UICollectionView!
  @IBOutlet var instructions: UILabel!
  @IBOutlet var nextButton: UIButton!
  @IBOutlet var pricesTable: UITableView!
  
  var friends: [Friend] = []
  var selectedFriend: FriendTotalCollectionViewCell?
  var dummyPrices: Dictionary<Int, FriendTotalCollectionViewCell?> = [95: nil, 45: nil, 160: nil, 1000: nil, 52136: nil]

  override func viewDidLoad() {
    super.viewDidLoad()
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
  
  // MARK: - Table View
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dummyPrices.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PriceCell", forIndexPath: indexPath)
    let price = Array(dummyPrices.keys)[indexPath.row]
    cell.textLabel?.backgroundColor = UIColor.clearColor()
    cell.textLabel?.text = String(format: "£%d.%02d", arguments: [price / 100, price % 100])
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    guard selectedFriend != nil else { return }
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    let price = getPrice((cell?.textLabel!.text!)!)
    if let friend = dummyPrices[price] {
      friend?.total -= price
    }
    cell?.backgroundColor = selectedFriend!.backgroundColor
    dummyPrices[price] = selectedFriend!
    selectedFriend!.total += price
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
      }
      dummyPrices.removeValueForKey(price)
    }
  }
}
