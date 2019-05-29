//
//  Channel.swift
//  SeQRcast
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
    var publicKey: String
    var createDate: Date
    
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
        publicKey = ""
        createDate = Date()
    }
    
    init(name: String, id: String, key: String, publicKey: String) {
        self.name = name
        self.id = id
        self.key = key
        self.publicKey = publicKey
        self.createDate = Date()
    }
    
    init(json: JSON) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.name = json["name"].stringValue
        self.id = json["id"].stringValue
        self.key = json["key"].stringValue
        self.publicKey = json["publicKey"].stringValue
        self.createDate = dateFormatter.date(from: json["createDate"].stringValue) ?? Date()
    }
    
    convenience init?(withID id: String) {
        let sc = JSON(Storage.subscribedChannels)
        for (_, json) in sc {
            if json["id"].stringValue == id {
                self.init(json: json)
                return
            }
        }
        let mc = JSON(Storage.myChannels)
        for (_, json) in mc {
            if json["id"].stringValue == id {
                self.init(json: json)
                self.publicKey = Storage.publicKey
                return
            }
        }
        return nil
    }
}

enum SubscriptionFailure {
    case alreadySubscribed, isMyChannel, invalid, none
}

class SubscribedChannel: Channel {
    
    override init(json: JSON) {
        super.init(json: json)
    }
    
    init(at index: Int) {
        let json = JSON(Storage.subscribedChannels[index])
        super.init(json: json)
    }
    
    init?(withID id: String) {
        let list = JSON(Storage.subscribedChannels)
        for (_, json) in list {
            if json["id"].stringValue == id {
                super.init(json: json)
                return
            }
        }
        return nil
    }
    
    static func subscribe(with data: String) throws -> (SubscribedChannel?, SubscriptionFailure) {
        if String(data.prefix(QR_TYPE_CHANNEL_SHARE.count)) != QR_TYPE_CHANNEL_SHARE {
            return (nil, .invalid)
        }
        
        let data = data.dropFirst(QR_TYPE_CHANNEL_SHARE.count)
        
        if data.count < Channel.PUBLIC_KEY_LENGTH {
            return (nil, .invalid)
        }
        
        let publicKeyIndex = data.index(data.startIndex, offsetBy: Channel.PUBLIC_KEY_LENGTH)
        let publicKey = String(data[data.startIndex ..< publicKeyIndex])
        
        let remain = String(data[publicKeyIndex ..< data.endIndex])
        let privateKey = try PrivateKey(base64Encoded: Storage.privateKey)
        let encryted = try EncryptedMessage(base64Encoded: remain)
        let decrypted = try encryted.decrypted(with: privateKey, padding: .PKCS1)
        let message = try decrypted.string(encoding: .utf8)
        
        if message.count < Channel.KEY_LENGTH + Channel.ID_LENGTH + 1 {
            return (nil, .invalid)
        }
        
        let keyIndex = message.index(message.startIndex, offsetBy: Channel.KEY_LENGTH)
        let idIndex = message.index(keyIndex, offsetBy: Channel.ID_LENGTH)
        let key = String(message[message.startIndex ..< keyIndex])
        let id = String(message[keyIndex ..< idIndex])
        let name = String(message[idIndex ..< message.endIndex])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let _ = SubscribedChannel(withID: id) {
            return (nil, .alreadySubscribed)
        }
        if let _ = MyChannel(withID: id) {
            return (nil, .isMyChannel)
        }
        
        let json = ["name": name, "id": id, "key": key, "publicKey": publicKey, "createDate": dateFormatter.string(from: Date())]
        Storage.subscribedChannels.append(json)
        return (SubscribedChannel(json: JSON(json)), .none)
    }
}

class MyChannel: Channel {
    
    init(at index: Int) {
        super.init(json: JSON(Storage.myChannels[index]))
        self.publicKey = Storage.publicKey
    }
    
    init?(withID id: String) {
        let list = JSON(Storage.myChannels)
        for (_, json) in list {
            if json["id"].stringValue == id {
                super.init(json: json)
                self.publicKey = Storage.publicKey
                return
            }
        }
        return nil
    }
    
    init?(named name: String) {
        super.init()
        let list = JSON(Storage.myChannels)
        for (_, json) in list {
            if json["name"].stringValue == name {
                return nil
            }
        }
        self.name = name
        self.id = getRandom32Bytes()
        self.key = getRandom32Bytes()
        self.publicKey = Storage.publicKey
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        Storage.myChannels.append(["name": self.name, "id": self.id, "key": self.key, "createDate": dateFormatter.string(from: Date())])
    }
    
    override init() {
        super.init()
    }
    
    func encrypt(with publicKey: String) throws -> CIImage? {
        let pubKey = try PublicKey(base64Encoded: String(publicKey.dropFirst(QR_TYPE_PUBLIC_KEY.count)))
        let data = "\(key)\(id)\(name)"
        let message = try ClearMessage(string: data, using: .utf8)
        let encrypted = try message.encrypted(with: pubKey, padding: .PKCS1)
        
        return QRCode.generateQRCode(message: QR_TYPE_CHANNEL_SHARE + Storage.publicKey + encrypted.base64String)
    }
    
    private func getRandom32Bytes() -> String {
        var data = Data(count: Channel.ID_BYTES)
        let _ = data.withUnsafeMutableBytes{ SecRandomCopyBytes(kSecRandomDefault, Channel.ID_BYTES, $0.baseAddress!) }
        
        return data.base64EncodedString()
    }
}
