//
//  PriceAllocationViewController.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.20.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit
import CoreGraphics

class PriceAllocationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SelectImageViewDelegate, PPScanDelegate, UITableViewDelegate, UITableViewDataSource {
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
  var coordinator:PPCoordinator?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Set the delegate of the SelectImageView
    imageView.delegate = self
    
    let error : NSErrorPointer = nil
    coordinator = self.coordinatorWithError(error)
    
    /** If scanning isn't supported, present an error */
    if coordinator == nil {
        let messageString: String = (error.memory?.localizedDescription) ?? ""
        UIAlertView(title: "Warning", message: messageString, delegate: nil, cancelButtonTitle: "Ok").show()
        return
    }
    
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
    
    coordinator!.processImage(croppedImage, scanningRegion: CGRectMake(0.0, 0.0, 1.0, 1.0), delegate: self)
    
    // Colour it in...

    let ratio = imageView.frame.size.width / (imageView.image?.size.width)!
    
    let width = selection.size.width * ratio
    let height = selection.size.height * ratio
    
    let x = imageView.frame.origin.x + (selection.origin.x * ratio)
    let y = imageView.frame.origin.y + (selection.origin.y * ratio)
    
    let highlight = UIView(frame: CGRectMake(x, y, width, height))
    highlight.alpha = 0.3
    NSLog(NSStringFromCGRect(selection))
    highlight.backgroundColor = selectedFriend?.friend?.colour
    self.view.addSubview(highlight)
    
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
    
    
  // MARK - OCR
    
  func coordinatorWithError(error: NSErrorPointer) -> PPCoordinator? {
    
        /** 1. Initialize the Scanning settings */
         
         // Initialize the scanner settings object. This initialize settings with all default values.
        let settings: PPSettings = PPSettings()
        
        
        /** 2. Setup the license key */
        
        // Visit www.microblink.com to get the license key for your app
        settings.licenseSettings.licenseKey = "62KNMAZV-FD4GRA4K-UCTGTZKV-QXIOKVMF-2DSVLBOQ-4VKYLUHF-KWC5BZKV-RUAJHDL5"
        
        
        /**
         * 3. Set up what is being scanned. See detailed guides for specific use cases.
         * Here's an example for initializing raw OCR scanning.
         */
         
         // To specify we want to perform MRTD (machine readable travel document) recognition, initialize the MRTD recognizer settings
        let ocrRecognizerSettings = PPOcrRecognizerSettings()
        
        // Add MRTD Recognizer setting to a list of used recognizer settings
        settings.scanSettings.addRecognizerSettings(ocrRecognizerSettings)
    
    
        ocrRecognizerSettings.addOcrParser(PPRawOcrParserFactory(), name: "Raw ocr")
        ocrRecognizerSettings.addOcrParser(PPPriceOcrParserFactory(), name: "Price")
        
        /** 4. Initialize the Scanning Coordinator object */
        
        let coordinator: PPCoordinator = PPCoordinator(settings: settings)
        
        return coordinator
    }

    func scanningViewControllerUnauthorizedCamera(scanningViewController: UIViewController) {
        // Add any logic which handles UI when app user doesn't allow usage of the phone's camera
    }
    
    func scanningViewController(scanningViewController: UIViewController, didFindError error: NSError) {
        // Can be ignored. See description of the method
    }
    
    func scanningViewControllerDidClose(scanningViewController: UIViewController) {
        // As scanning view controller is presented full screen and modally, dismiss it
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scanningViewController(scanningViewController: UIViewController!, didOutputResults results: [AnyObject]!) {
        NSLog("OCR Results")
        for result in results {
            if(result.isKindOfClass(PPOcrRecognizerResult)) {
                let ocrRecognizerResult : PPOcrRecognizerResult = result as! PPOcrRecognizerResult
                NSLog("OCR results are:")
                NSLog("Raw ocr: %@", ocrRecognizerResult.parsedResultForName("Raw ocr"))
                NSLog("Price: %@", ocrRecognizerResult.parsedResultForName("Price"))
                
                
                if let priceTest = ocrRecognizerResult.parsedResultForName("Price") {
                    
                    if (priceTest.characters.count != 0) {
                        let poundsPence = priceTest.componentsSeparatedByString(",")
                        
                        if (poundsPence.count != 0) {
                            let pounds:Int? = Int(poundsPence[0])
                            let pence:Int? = Int(poundsPence[1])
                            
                            if (pounds != nil && pence != nil) {
                                let price = pence! + (pounds! * 100);
                                selectedFriend?.total += price
                            }
                        }
                    }
                    
                }

                
                NSLog("Dimensions of ocrLayout are %@", NSStringFromCGRect(ocrRecognizerResult.ocrLayout().box));
            }
        }
    }
    


}
