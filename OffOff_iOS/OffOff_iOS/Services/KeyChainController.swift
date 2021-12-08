//
//  KeyChainController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/22.
//

import Foundation
import Security

class KeyChainController {
    static let shared = KeyChainController()
    
    func create(_ service: String, account: String, value: String) {
        
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
        ]
        
        
        SecItemDelete(keyChainQuery)
        
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "failed to saving Token")
        NSLog("status = \(status)")
    }
    
    func read(_ service: String, account: String) -> String? {
        let KeyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        // Read
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(KeyChainQuery, &dataTypeRef)
        
        // Result
        if(status == errSecSuccess) {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: String.Encoding.utf8)
            return value
        } else {
            print("failed to loading, status code = \(status)")
            return nil
        }
    }
    
    func delete(_ service: String, account: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        
        let status = SecItemDelete(keyChainQuery)
        assert(status == noErr, "failed to delete the value, status code = \(status)")
    }
    
    func getAuthorizationHeader(service: String, account: String) -> [String: String]? {
        if let accessToken = self.read(service, account: account) {
            return ["Authorization" : "Bearer \(accessToken)"]
        } else {
            return nil
        }
    }
    
    func getAuthorizationString(service: String, account: String) -> String? {
        if let accessToken = self.read(service, account: account) {
            return "\(accessToken)"
        } else {
            return nil
        }
    }
}
