//
//  Message.swift
//  QRGuard
//
//  Created by user149673 on 5/22/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import Foundation
import SwiftyRSA
import SwiftyJSON
import CryptoSwift

enum MessageType: Int {
    case text = 0
    case url = 1
}

class Message {
    var type: MessageType
    var expirationDate: Date
    var content: String
    var channel: Channel
    
    static let TYPE_LENGTH = 1
    static let DATE_FORMAT = "yyyy-MM-dd HH:mm"
    static let SIGNATURE_LENGTH = 344
    static let IV = "SeQRcast:BestApp"
    
    init(type: MessageType, expires expirationDate: Date, withContent content: String, for channel: Channel) {
        self.type = type
        self.expirationDate = expirationDate
        self.content = content
        self.channel = channel
    }
    
    static func decrypt(data: String) throws {
        let idIndex = data.index(data.startIndex, offsetBy: Channel.ID_LENGTH)
        let id = String(data[data.startIndex ..< idIndex])
        var key = ""
        var name = ""
        
        for (_, json) in JSON(Storage.subscribedChannels) {
            if json["id"].stringValue == id {
                name = json["name"].stringValue
                key = json["key"].stringValue
            }
        }
        
        if key.count == 0 {
            
        }
        
        let signatureIndex = data.index(idIndex, offsetBy: Message.SIGNATURE_LENGTH)
        let signature = String(data[idIndex ..< signatureIndex])
        let body = String(data[signatureIndex ..< data.endIndex])
        let aes = try AES(key: key, iv: Message.IV)
        guard let decrypted = try String(bytes: body.decryptBase64(cipher: aes), encoding: .utf8),
            let t = Int(String(decrypted.prefix(1)))
            else {
            return
        }
        
        let typeIndex = decrypted.index(decrypted.startIndex, offsetBy: 1)
        let dateIndex = decrypted.index(typeIndex, offsetBy: Message.DATE_FORMAT.count)
        let dateString = String(decrypted[typeIndex ..< dateIndex])
        let content = String(decrypted[dateIndex ..< decrypted.endIndex])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Message.DATE_FORMAT
        
        
        guard let type = MessageType(rawValue: t),
            let date = dateFormatter.date(from: dateString)
            else {
            return
        }
        
        
        
        
        
    }
    
    func encrypt() throws -> CIImage? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Message.DATE_FORMAT
        let date = dateFormatter.string(from: expirationDate)
        let body = "\(type.rawValue)\(date)\(content)"
        let doc = "\(channel.name)\(body)"
        
        let privateKey = try PrivateKey(base64Encoded: Storage.privateKey)
        let document = try ClearMessage(string: doc, using: .utf8)
        let signature = try document.signed(with: privateKey, digestType: .sha256)
        
        let aes = try AES(key: channel.key, iv: Message.IV)
        guard let encrypted = try aes.encrypt(Array(body.utf8)).toBase64() else {
            print("encryption failed")
            return QRCode.generateQRCode(message: "")
        }
        
        return QRCode.generateQRCode(message: channel.id + signature.base64String + encrypted)
    }
}
