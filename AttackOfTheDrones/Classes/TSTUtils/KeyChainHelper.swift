//
//  KeyChainHelper.swift
//  CocosSwift
//
//  Created by Thales Toniolo on 9/12/14.
//  Copyright (c) 2014 Flameworks. All rights reserved.
//
import Foundation
import Security

// Identifyers
let userAccount = "authenticatedUser"

// MARK: - Class Definition
public class KeyChainHelper {
	// MARK: - Public Objects

	// MARK: - Private Objects

	// MARK: - Private Methods
	private class func save(service: NSString, data: NSString) {
		let dataFromString: NSData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

		// Instantiate a new default keychain query
//		var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, userAccount, dataFromString], forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecValueData])
		let keychainQuery: NSMutableDictionary = NSMutableDictionary()
		keychainQuery[kSecClass as NSString] = kSecClassGenericPassword
		keychainQuery[kSecAttrService as NSString] = service
		keychainQuery[kSecAttrAccount as NSString] = userAccount
		keychainQuery[kSecValueData as NSString] = dataFromString

		// Delete any existing items
		SecItemDelete(keychainQuery as CFDictionaryRef)

		// Add the new keychain item
		SecItemAdd(keychainQuery as CFDictionaryRef, nil)
	}
	
	private class func load(service: NSString) -> NSString? {
		// Instantiate a new default keychain query
		// Tell the query to return a result
		// Limit our results to one item
//		var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, userAccount, kCFBooleanTrue, kSecMatchLimitOne], forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecReturnData, kSecMatchLimit])
		let keychainQuery: NSMutableDictionary = NSMutableDictionary()
		keychainQuery[kSecClass as NSString] = kSecClassGenericPassword
		keychainQuery[kSecAttrService as NSString] = service
		keychainQuery[kSecAttrAccount as NSString] = userAccount
		keychainQuery[kSecReturnData as NSString] = kCFBooleanTrue
		keychainQuery[kSecMatchLimit as NSString] = kSecMatchLimitOne

		var contentsOfKeychain: NSString?
		var result: AnyObject?
		let status = withUnsafeMutablePointer(&result) { SecItemCopyMatching(keychainQuery, UnsafeMutablePointer($0)) }
		if status == 0 {
			if let data = result as! NSData? {
				if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
					contentsOfKeychain = string
				}
			}
		}

		return contentsOfKeychain
	}

	// MARK: - Public Methods
	class func saveToken(token:String?, withKeyID:String) {
		var saveValue: String = ""
		if (token != nil) {
			saveValue = token!
		}

		self.save(withKeyID, data: saveValue)
	}

	class func loadTokenWithKeyID(aKeyID:String) -> String? {
		var token = self.load(aKeyID)

		if (token == nil) {
			token = ""
		}
		
		return token as? String
	}

	class func haveKey(aKeyID:String) -> Bool {
		let token = self.load(aKeyID)

		return (token == nil || token == "") ? false : true
	}
}
