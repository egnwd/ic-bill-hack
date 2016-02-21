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
  let host = Friend(name: "Jonathan", pictureName: "jonathan.jpg", mondoId: "0")

  override func viewDidLoad() {
    super.viewDidLoad()
    let transactionId = String(Int(NSDate().timeIntervalSince1970))
    for friendCell in friends {
      pushTransactionToDinnerWith(friendCell.friend!, transactionId: transactionId, total: friendCell.total)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func pushTransactionToMondo(mondo_id: String) {
    let postEndpoint = "https://api.getmondo.co.uk/feed"
    guard let url = NSURL(string: postEndpoint) else {
      print("Error: cannot create url")
      return
    }
    let urlRequest = NSMutableURLRequest(URL: url)
    urlRequest.HTTPMethod = "POST"
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)
    
    let bodyData = "account_id"
    urlRequest.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
    
    let task = session.dataTaskWithRequest(urlRequest, completionHandler: makeTransaction)
    task.resume()
  }
  
  func pushTransactionToDinnerWith(friend: Friend, transactionId: String, total: Int) {
    let postEndpoint = "http://localhost:3000/request"
    guard let url = NSURL(string: postEndpoint) else {
      print("Error: cannot create url")
      return
    }
    let urlRequest = NSMutableURLRequest(URL: url)
    urlRequest.HTTPMethod = "POST"
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)
    
    let bodyData = "request[mondo_id]=\(friend.mondoId)&request[transaction_id]=\(transactionId)&request[amount]=\(total)&request[who_from]=\(host.name)"
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
