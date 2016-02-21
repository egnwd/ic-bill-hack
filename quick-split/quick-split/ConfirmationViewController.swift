//
//  ConfirmationViewController.swift
//  quick-split
//
//  Created by Elliot Greenwood on 02.21.2016.
//  Copyright © 2016 stealth-phoenix. All rights reserved.
//

import UIKit
import MondoKit

class ConfirmationViewController: UIViewController {
  
  var friends: [FriendTotalCollectionViewCell] = []
  let host = Friend(name: "Jonathan", pictureName: "jonathan.jpg", mondoId: "0")

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController!.navigationBar.hidden = true
    let transactionId = String(Int(random()*100))
    for friendCell in friends {
      if (friendCell.friend?.mondoId == "acc_000094cjbHqqTaBqC8CQMb") {
        pushTransactionToMondo((friendCell.friend?.name)!, total: friendCell.total, transaction_id: transactionId)
      }
      pushTransactionToDinnerWith(friendCell.friend!, transactionId: transactionId, total: friendCell.total)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func pushTransactionToMondo(mondo_id: String, total: Int, transaction_id: String) {
    print("http://dinner-with.herokuapp.com/request/\(mondo_id)/\(transaction_id)")
    if MondoAPI.instance.isAuthorized {
      print("yea")
      MondoAPI.instance.addFeedItemForAccount(mondo_id, url: "http://dinner-with.herokuapp.com/request/\(mondo_id)/\(transaction_id)", title: "You have a new payment request", body: String(format: "£%d.%02d", arguments: [total / 100, total % 100]), image_url: "http://dinner-with.herokuapp.com/assets/images/mondo_icon.png", completion: { (error) in print("Hey \(error)") })
    } else {
      let oauthViewController = MondoAPI.instance.newAuthViewController() { (success, error) in
        if success {
          self.dismissViewControllerAnimated(true) {
            print("yea2")
            MondoAPI.instance.addFeedItemForAccount(mondo_id, url: "http://dinner-with.herokuapp.com/request/\(mondo_id)/\(transaction_id)", title: "You have a new payment request", body: String(format: "£%d.%02d", arguments: [total / 100, total % 100]), image_url: "http://dinner-with.herokuapp.com/assets/images/mondo_icon.png", completion: { (error) in print(error) })
          }
        } else {
            print("Error")
        }
      }
      presentViewController(oauthViewController, animated: true, completion: nil)
    }
  }
  
  func pushTransactionToDinnerWith(friend: Friend, transactionId: String, total: Int) {
    let postEndpoint = "http://dinner-with.herokuapp.com/request"
    guard let url = NSURL(string: postEndpoint) else {
      print("Error: cannot create url")
      return
    }
    let urlRequest = NSMutableURLRequest(URL: url)
    urlRequest.HTTPMethod = "POST"
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)
    
    let bodyData = "request[mondo_id]=\(friend.name)&request[transaction_id]=\(transactionId)&request[amount]=\(total)&request[who_from]=\(host.name)"
    urlRequest.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
    
    let task = session.dataTaskWithRequest(urlRequest, completionHandler: makeTransaction)
    task.resume()
  }
  
  func makeTransaction(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void {
    guard error == nil else {
      print("error calling POST on /request")
      print(error)
      return
    }
    print("Load success page")
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