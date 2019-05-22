//
//  Channel.swift
//  QRGuard
//
//  Created by user149673 on 5/22/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyRSA

class Channel {
    var name: String
    var id: String
    var key: String
    
    static let ID_BYTES = 32
    static let KEY_BYTES = 32
    static let ID_LENGTH = 44
    static let KEY_LENGTH = 44
    static let MAX_NAME_LENGTH = 64
    static let PUBLIC_KEY_LENGTH = 360

    
    init() {
        name = ""
        id = ""
        key = ""
    }
    
    init(name: String, id: String, key: String) {
        self.name = name
        self.id = id
        self.key = key
    }
    
    init(json: JSON) {
        self.name = json["name"].stringValue
        self.id = json["id"].stringValue
        self.key = json["key"].stringValue
    }
}

class SubscribedChannel: Channel {
    var publicKey: String
    
    init(at index: Int) {
        let json = JSON(Storage.subscribedChannels[index])
        publicKey = json["publicKey"].stringValue
        super.init(json: json)
    }
    
    init?(withID id: String) {
        let list = JSON(Storage.subscribedChannels)
        for (_, json) in list {
            if json["id"].stringValue == id {
                publicKey = json["publicKey"].stringValue
                super.init(json: json)
                return
            }
        }
        return nil
    }
    
    static func subscribe(with data: String) throws {
        let publicKeyIndex = data.index(data.startIndex, offsetBy: Channel.PUBLIC_KEY_LENGTH)
        let publicKey = String(data[data.startIndex ..< publicKeyIndex])
        
        let remain = String(data[publicKeyIndex ..< data.endIndex])
        let privateKey = try PrivateKey(base64Encoded: Storage.privateKey)
        let encryted = try EncryptedMessage(base64Encoded: remain)
        let decrypted = try encryted.decrypted(with: privateKey, padding: .PKCS1)
        
        let message = try decrypted.string(encoding: .utf8)
        let keyIndex = message.index(message.startIndex, offsetBy: Channel.KEY_LENGTH)
        let idIndex = message.index(keyIndex, offsetBy: Channel.ID_LENGTH)
        let key = String(message[message.startIndex ..< keyIndex])
        let id = String(message[keyIndex ..< idIndex])
        let name = String(message[idIndex ..< message.endIndex])
        
        Storage.subscribedChannels.append(["name": name, "id": id, "key": key, "publicKey": publicKey])
    }
}

class MyChannel: Channel {
    
    init(at index: Int) {
        super.init(json: JSON(Storage.subscribedChannels[index]))
    }
    
    init?(named name: String) {
        super.init()
        let list = JSON(Storage.subscribedChannels)
        for (_, json) in list {
            if json["name"].stringValue == name {
                return nil
            }
        }
        self.name = name
        self.id = getRandom32Bytes()
        self.key = getRandom32Bytes()
    }
    
    func encrypt(with publicKey: String) throws -> CIImage? {
        let pubKey = try PublicKey(base64Encoded: publicKey)
        let data = "\(key)\(id)\(name)"
        let message = try ClearMessage(string: data, using: .utf8)
        let encrypted = try message.encrypted(with: pubKey, padding: .PKCS1)
        
        return QRCode.generateQRCode(message: Storage.publicKey + encrypted.base64String)
    }
    
    func getRandom32Bytes() -> String {
        var data = Data(count: Channel.ID_LENGTH)
        let _ = data.withUnsafeMutableBytes{ SecRandomCopyBytes(kSecRandomDefault, Channel.ID_LENGTH, $0.baseAddress!) }
        
        return data.base64EncodedString()
    }
}
