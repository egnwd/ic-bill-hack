//
//  MondoAPI.swift
//  MondoKit
//
//  Created by Mike Pollard on 21/01/2016.
//  Copyright © 2016 Mike Pollard. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyJSONDecodable
import KeychainAccess

internal struct AuthData {
    
    private static let OAuth2CreatedAtKey: String = "MondoOAuth2CreatedAt"
    private static let OAuth2AccessTokenKey: String = "MondoOAuth2AccessToken"
    private static let OAuth2RefreshTokenKey: String = "MondoOAuth2RefreshToken"
    private static let OAuth2ExpiresInKey: String = "MondoOAuth2ExpiresInToken"
    
    let createdAt : NSDate
    //let userId : String
    let accessToken : String
    let expiresIn : Int
    let refreshToken : String?
    var expiresAt : NSDate {
        return createdAt.dateByAddingTimeInterval(NSTimeInterval(expiresIn))
    }
    
    internal init(createdAt: NSDate, accessToken: String, expiresIn: Int, refreshToken: String? = nil) {
        self.createdAt = createdAt
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
    }
    
    private init?(keychain: Keychain) {
        
        guard
        let createdAt = keychain[AuthData.OAuth2CreatedAtKey],
        let createdAtDate = JSONDate.dateFormatterNoMillis.dateFromString(createdAt),
        let accessToken = keychain[AuthData.OAuth2AccessTokenKey],
        let expiresIn = keychain[AuthData.OAuth2ExpiresInKey]
            else {
                return nil
        }
        
        self.createdAt = createdAtDate
        self.accessToken = accessToken
        self.expiresIn = Int(expiresIn)!
        self.refreshToken = keychain[AuthData.OAuth2RefreshTokenKey]
    }
    
    internal func storeInKeychain(keychain: Keychain) {
        
        keychain[AuthData.OAuth2CreatedAtKey] = createdAt.toJsonDateTime
        keychain[AuthData.OAuth2AccessTokenKey] = accessToken
        keychain[AuthData.OAuth2RefreshTokenKey] = refreshToken
        keychain[AuthData.OAuth2ExpiresInKey] = String(expiresIn)
    }
}

/**
 A Swift wrapper around the Mondo API at https://api.getmondo.co.uk/
 
 This is a singleton, use `MondAPI.instance` to play with it and call `MondAPI.instance.initialiseWithClientId(:clientSecret)`
 before you do anything else.
 
 Once you've done that grab a `UIViewController` using `newAuthViewController` and present it to allow user authentication.
 
 Then go ahead and play with:
 
 - `listAccounts`
 - `getBalanceForAccount`
 - `listTransactionsForAccount`
 
 */
public class MondoAPI {
    
    internal static let APIRoot = "https://api.getmondo.co.uk/"
    
    /// The only one you'll ever need!
    public static let instance = MondoAPI()
    
    internal var clientId : String?
    internal var clientSecret : String?
    
    internal var authData : AuthData?
    internal var keychain : Keychain!
    
    private var initialised : Bool {
        
        return clientId != nil && clientSecret != nil
    }
    
    internal let alamofireManager : Alamofire.Manager
    
    /**
     MondoAPI uses this `NSOperationQueue` to manage the execution of API calls.
     This ensures all API calls are run on a dispatch_queue other than the main_queue and also provides the ability to manage dependencies if necessary.
     */
    internal let apiOperationQueue : NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.underlyingQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        return queue
    }()
    
    private init() {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        alamofireManager = Alamofire.Manager(configuration: sessionConfiguration)
        alamofireManager.startRequestsImmediately = false
    }
    
    public var isAuthorized : Bool {
        
        assert(initialised, "MondoAPI.instance not initialised!")
        
        guard let authData = authData else { return false }
        
        return authData.refreshToken != nil || authData.expiresAt.timeIntervalSinceNow > 60 // Return false if we're expired or about to expire in the next minute and don't have a refreshToken
    }
    
    private var authHeader : [String:String]? {
        guard let authData = authData else { return nil }
        return ["Authorization":"Bearer " + authData.accessToken]
    }
    
    /**
     Initializes the MondoAPI instance with the specified clientId & clientSecret.
     
     You need to do this before using the MondAPI.
     
     ie call `MondAPI.instance.initialiseWithClientId(:clientSecret)` in `applicationDidFinishLaunchingWithOptions`
     
     */
    public func initialiseWithClientId(clientId : String, clientSecret : String) {
        
        assert(!initialised, "MondoAPI.instance already initialised!")
        
        self.clientId = clientId
        self.clientSecret = clientSecret
        
        keychain = Keychain(service: MondoAPI.APIRoot + clientId)
        authData = AuthData(keychain: keychain)
    }
    
    /**
     Creates and returns a `UIViewController` that manages authentication with Mondo.
     
     Present this and wait for the callback.
     
     - parameter onCompletion:     The callback closure called to let you know how the authentication went.
     */
    public func newAuthViewController(onCompletion completion : (success : Bool, error : ErrorType?) -> Void) -> UIViewController {
        
        assert(initialised, "MondoAPI.instance not initialised!")
        
        return OAuthViewController(mondoApi: self, onCompletion: completion)
    }
    
    /**
     Cancels any outstanding operations on the queue and nils out authData
     */
    public func signOut() {
        apiOperationQueue.cancelAllOperations()
        apiOperationQueue.addOperationWithBlock() { [unowned self] in
            self.keychain[AuthData.OAuth2CreatedAtKey] = nil
            self.keychain[AuthData.OAuth2AccessTokenKey] = nil
            self.keychain[AuthData.OAuth2RefreshTokenKey] = nil
            self.keychain[AuthData.OAuth2ExpiresInKey] = nil
            self.authData = nil
        }
    }
    
    // MARK: Pagination
    
    /**
    A struct to encapsulte the Pagination parameters used by the Mondo API for cursor based pagination.
    */
    public struct Pagination {
        
        public enum Constraint {
            case Date(NSDate)
            case Id(String)
            
            private var headerValue : String {
                switch self {
                case .Date(let date):
                    return date.toJsonDateTime
                case .Id(let id):
                    return id
                }
            }
        }
        
        let limit : Int?
        let since : Constraint?
        let before : NSDate?
        
        public init(limit: Int? = nil, since: Constraint? = nil, before: NSDate? = nil) {
            self.limit = limit
            self.since = since
            self.before = before
        }
        
        private var parameters : [String : String] {
            var parameters = [String:String]()
            if let limit = limit {
                parameters["limit"] = String(limit)
            }
            if let since = since {
                parameters["since"] = since.headerValue
            }
            if let before = before {
                parameters["before"] = before.toJsonDateTime
            }
            return parameters
        }
    }
    
    
    // MARK: internal and private helpers
    
    internal func dispatchCompletion(completion: ()->Void) {
        
        dispatch_async(dispatch_get_main_queue(), completion)
    }
 
    private func createRefreshTokenOperationIfNecessary() -> MondoAPIOperation? {
        
        // Only attempt refresh if we're authed, have a refreshToken and the accessToken expires within a minute
        guard let authData = self.authData,
            refreshToken = authData.refreshToken where authData.expiresAt.timeIntervalSinceNow < 60
            else {
                return nil
        }
        
        let refreshOperation = reauthorizeOperationFromRefreshToken(refreshToken) { (success, error) in
        }
        
        apiOperationQueue.operations.forEach() { operation in
            refreshOperation.addDependency(operation)
        }
        
        return refreshOperation
    }
    
    private func optionallyRefreshAccessTokenAndAddOperation(operation: MondoAPIOperation) {
    
        if let refreshOperation = createRefreshTokenOperationIfNecessary() {
            operation.addDependency(refreshOperation)
            apiOperationQueue.addOperation(refreshOperation)
        }
        
        apiOperationQueue.addOperation(operation)
    }
}

// MARK: listAccounts

extension MondoAPI {
    
    /**
     Calls https://api.getmondo.co.uk/accounts and calls the completion closure with
     either an `[MondoAccount]` or an `ErrorType`
     
     - parameter completion:
     */
    public func listAccounts(completion: (mondoAccounts: [MondoAccount]?, error: ErrorType?) -> Void) {
        
        assert(initialised, "MondoAPI.instance not initialised!")
        
        let operation = MondoAPIOperation(method: .GET, urlString: MondoAPI.APIRoot+"accounts", authHeader: { self.authHeader }) { (json, error) in
            
            var mondoAccounts : [MondoAccount]?
            var anyError : ErrorType?
            
            defer {
                self.dispatchCompletion() {
                    completion(mondoAccounts: mondoAccounts, error: anyError)
                }
            }
            
            guard error == nil else { return }
            
            mondoAccounts = [MondoAccount]()
            
            if let json = json, accounts = json["accounts"].array {
                for accountJson in accounts {
                    do {
                        let mondoAccount = try MondoAccount(json: accountJson)
                        mondoAccounts!.append(mondoAccount)
                    }
                    catch {
                        debugPrint("Could not create MondoAccount from \(accountJson) \n Error: \(error)")
                        anyError = error
                    }
                }
            }
            
        }
        
        optionallyRefreshAccessTokenAndAddOperation(operation)
    }
}

// MARK: getBalanceForAccount

extension MondoAPI {
    
    /**
     Calls https://api.getmondo.co.uk/balance and calls the completion closure with
     either an `MondoAccountBalance` or an `ErrorType`
     
     - parameter account:       an account from which to get the accountId
     - parameter completion:
     */
    public func getBalanceForAccount(account: MondoAccount, completion: (balance: MondoAccountBalance?, error: ErrorType?) -> Void) {
        
        assert(initialised, "MondoAPI.instance not initialised!")
        
        let operation = MondoAPIOperation(method: .GET, urlString: MondoAPI.APIRoot+"balance", parameters: ["account_id" : account.id], authHeader: { self.authHeader }) { (json, error) in
            
            var balance : MondoAccountBalance?
            var anyError : ErrorType?
            
            defer {
                self.dispatchCompletion() {
                    completion(balance: balance, error: anyError)
                }
            }
            
            guard error == nil else { return }
            
            if let json = json {
                do {
                    balance = try MondoAccountBalance(json: json)
                }
                catch {
                    debugPrint("Could not create MondoAccountBalance from \(json) \n Error: \(error)")
                    anyError = error
                }
            }
        }
        
        optionallyRefreshAccessTokenAndAddOperation(operation)
    }
}

// MARK: getTransactionForId

extension MondoAPI {
    
    /**
     Calls https://api.getmondo.co.uk/transaction/$transaction_id and calls the completion closure with
     either an `MondoTransaction` or an `ErrorType`
     
     - parameter transactionId: a transaction Id
     - parameter expand:        what to pass as expand[] parameter. eg. merchant. `nil` by default.
     - parameter completion:
     */
    public func getTransactionForId(transactionId: String, expand: String? = nil, completion: (transaction: MondoTransaction?, error: ErrorType?) -> Void) {
        
        assert(initialised, "MondoAPI.instance not initialised!")
        
        var parameters = [String:String]()
        if let expand = expand {
            parameters["expand[]"] = expand
        }
        
        let operation = MondoAPIOperation(method: .GET, urlString: MondoAPI.APIRoot+"transactions/"+transactionId, parameters: parameters, authHeader: { self.authHeader }) { (json, error) in
            
            var transaction : MondoTransaction?
            var anyError : ErrorType?
            
            defer {
                self.dispatchCompletion() {
                    completion(transaction: transaction, error: anyError)
                }
            }
            
            guard error == nil else { return }
            
            if let json = json {
                do {
                    transaction = try json.decodeValueForKey("transaction") as MondoTransaction
                }
                catch {
                    debugPrint("Could not create MondoTransaction from \(json) \n Error: \(error)")
                    anyError = error
                }
            }
        }
        
        optionallyRefreshAccessTokenAndAddOperation(operation)
    }
}

// MARK : annotateTransaction

extension MondoAPI {
    
    public func annotateTransaction(transaction: MondoTransaction, withKey key: String, value: String, completion: (transaction: MondoTransaction?, error: ErrorType?) -> Void) {
        
        assert(initialised, "MondoAPI.instance not initialised!")
        
        guard key.characters.count > 0 else {
            self.dispatchCompletion() {
                completion(transaction: transaction, error: nil)
            }
            return
        }
        
        var parameters = ["metadata["+key+"]":value]
        
        let operation = MondoAPIOperation(method: .PATCH, urlString: MondoAPI.APIRoot+"transactions/"+transaction.id, parameters: parameters, authHeader: { self.authHeader }) { (json, error) in
            
            var transaction : MondoTransaction?
            var anyError : ErrorType?
            
            defer {
                self.dispatchCompletion() {
                    completion(transaction: transaction, error: anyError)
                }
            }
            
            guard error == nil else { return }
            
            if let json = json {
                do {
                    transaction = try json.decodeValueForKey("transaction") as MondoTransaction
                }
                catch {
                    debugPrint("Could not create MondoTransaction from \(json) \n Error: \(error)")
                    anyError = error
                }
            }
        }
        
        optionallyRefreshAccessTokenAndAddOperation(operation)
    }
}

// MARK: listTransactionsForAccount

extension MondoAPI {
    
    /**
     Calls https://api.getmondo.co.uk/transactions and calls the completion closure with
     either an `[MondoTransaction]` or an `ErrorType`
     
     - parameter account:       an account from which to get the accountId
     - parameter expand:        what to pass as expand[] parameter. eg. merchant. `nil` by default.
     - parameter pagination:    the pagination parameters. `nil` by default.
     - parameter completion:
     */
    public func listTransactionsForAccount(account: MondoAccount, expand: String? = nil, pagination: Pagination? = nil, completion: (transactions: [MondoTransaction]?, error: ErrorType?) -> Void) {
        
        assert(initialised, "MondoAPI.instance not initialised!")
        
        var parameters = ["account_id" : account.id]
        if let expand = expand {
            parameters["expand[]"] = expand
        }
        
        if let pagination = pagination {
            pagination.parameters.forEach { parameters.updateValue($1, forKey: $0) }
        }
        
        let operation = MondoAPIOperation(method: .GET, urlString: MondoAPI.APIRoot+"transactions", parameters: parameters, authHeader: { self.authHeader }) { (json, error) in
            
            var transactions : [MondoTransaction]?
            var anyError : ErrorType?
            
            defer {
                self.dispatchCompletion() {
                    completion(transactions: transactions, error: anyError)
                }
            }
            
            guard error == nil else { return }
            
            if let json = json {
                do {
                    transactions = try json.decodeArrayForKey("transactions")
                }
                catch {
                    debugPrint("Could not create MondoTransactions from \(json) \n Error: \(error)")
                    anyError = error
                }
            }
        }
        
        optionallyRefreshAccessTokenAndAddOperation(operation)
    }
}

extension MondoAPI {
    
    /**
     Calls https://api.getmondo.co.uk/feed and calls the completion closure with
     either an `[MondoFeedItem]` or an `ErrorType`
     
     - parameter account:       an account from which to get the accountId
     - parameter completion:
     */
    public func listFeedForAccount(account: MondoAccount, completion: (items: [MondoFeedItem]?, error: ErrorType?) -> Void) {
        
        assert(initialised, "MondoAPI.instance not initialised!")
        
        var parameters = ["account_id" : account.id]
        
        let operation = MondoAPIOperation(method: .GET, urlString: MondoAPI.APIRoot+"feed", parameters: parameters, authHeader: { self.authHeader }) { (json, error) in
            
            var items : [MondoFeedItem]?
            var anyError : ErrorType?
            
            defer {
                self.dispatchCompletion() {
                    completion(items: items, error: anyError)
                }
            }
            
            guard error == nil else { return }
            
            if let json = json {
                do {
                    items = try json.decodeArrayForKey("items")
                }
                catch {
                    debugPrint("Could not create MondoTransactions from \(json) \n Error: \(error)")
                    anyError = error
                }
            }
        }

        optionallyRefreshAccessTokenAndAddOperation(operation)
    }
  
}

extension MondoAPI {

  public func addFeedItemForAccount(account: String, url: String, title: String, body: String, image_url: String, completion: (error: ErrorType?) -> Void) {
    assert(initialised, "MondoAPI.instance not initialised!")
    var parameters = ["account_id" : account, "type": "basic", "url": url, "params": ["title": title, "body": body, "image_url": image_url]]
    let operation = MondoAPIOperation(method: .POST, urlString: MondoAPI.APIRoot+"feed", parameters: parameters as! [String : AnyObject], authHeader: { self.authHeader }) { (json, error) in
      var anyError : ErrorType?
      
      defer {
        self.dispatchCompletion() {
          completion(error: anyError)
        }
      }
      
      guard error == nil else { return }
      
    }
    
    optionallyRefreshAccessTokenAndAddOperation(operation)
  }
}