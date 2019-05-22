//
//  Storage.swift
//  QRGuard
//
//  Created by user149673 on 5/22/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import Foundation
import SwiftyRSA

class Storage {
    static var publicKey: String {
        get {
            if let publicKey = UserDefaults.standard.string(forKey: "publicKey"),
            let _ = UserDefaults.standard.string(forKey: "privateKey") {
                return publicKey
            }
            let keys = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
            let publicKey = try! keys.publicKey.base64String()
            let privateKey = try! keys.privateKey.base64String()
            UserDefaults.standard.set(publicKey, forKey: "publicKey")
            UserDefaults.standard.set(privateKey, forKey: "privateKey")
            return publicKey
        }
    }
    
    static var privateKey: String {
        get {
            if let _ = UserDefaults.standard.string(forKey: "publicKey"),
                let privateKey = UserDefaults.standard.string(forKey: "privateKey") {
                return privateKey
            }
            let keys = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
            let publicKey = try! keys.publicKey.base64String()
            let privateKey = try! keys.privateKey.base64String()
            UserDefaults.standard.set(publicKey, forKey: "publicKey")
            UserDefaults.standard.set(privateKey, forKey: "privateKey")
            return privateKey
        }
    }
    
    static var subscribedChannels: [[String: Any]] {
        get {
            return UserDefaults.standard.array(forKey: "subscribedChannels") as? [[String: Any]] ?? []
        }
        set(subscribedChannels) {
            UserDefaults.standard.set(subscribedChannels, forKey: "subscribedChannels")
        }
    }
    
    static var myChannels: [[String: Any]] {
        get {
            return UserDefaults.standard.array(forKey: "myChannels") as? [[String: Any]] ?? []
        }
        set(myChannels) {
            UserDefaults.standard.set(myChannels, forKey: "myChannels")
        }
    }

}
