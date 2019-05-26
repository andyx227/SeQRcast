//
//  Database.swift
//  QRGuard
//
//  Created by user149673 on 5/26/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import Foundation
import SQLite

let TABLE_LOG = "log"
let COLUMN_CHANNEL_ID = "channel_id"
let COLUMN_MESSAGE_TYPE = "message_type"
let COLUMN_EXPIRATION_DATE = "expiration_date"
let COLUMN_GEN_DATE = "gen_date"
let COLUMN_MESSAGE_CONTENT = "message_content"
let COLUMN_LATITUDE = "latitude"
let COLUMN_LONGITUDE = "longitude"
let COLUMN_ENCODED = "encoded"

class Database {
    static let shared = Database()
    private var db: Connection
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        self.db = try! Connection("\(path)/db.sqlite3")
        
        do {
            let log = Table(TABLE_LOG)
            let cid = Expression<String>(COLUMN_CHANNEL_ID)
            let type = Expression<String>(COLUMN_MESSAGE_TYPE)
            let expr = Expression<Date>(COLUMN_EXPIRATION_DATE)
            let gen = Expression<Date>(COLUMN_GEN_DATE)
            let content = Expression<String>(COLUMN_MESSAGE_CONTENT)
            let latitude = Expression<Double>(COLUMN_LATITUDE)
            let longitude = Expression<Double>(COLUMN_LONGITUDE)
            let encoded = Expression<String>(COLUMN_ENCODED)
            
            try db.run(log.create(ifNotExists: true) { (t) in
                t.column(cid)
                t.column(type)
                t.column(expr)
                t.column(gen)
                t.column(content)
                t.column(latitude)
                t.column(longitude)
                t.column(encoded)
            })
        } catch {
            print(error)
        }
    }
    
    func getLogs(for channel: Channel) -> [MessageLog] {
        do {
            let log = Table(TABLE_LOG)
            let cid = Expression<String>(COLUMN_CHANNEL_ID)
            let type = Expression<String>(COLUMN_MESSAGE_TYPE)
            let expr = Expression<Date>(COLUMN_EXPIRATION_DATE)
            let gen = Expression<Date>(COLUMN_GEN_DATE)
            let content = Expression<String>(COLUMN_MESSAGE_CONTENT)
            let latitude = Expression<Double>(COLUMN_LATITUDE)
            let longitude = Expression<Double>(COLUMN_LONGITUDE)
            let encoded = Expression<String>(COLUMN_ENCODED)
            
            let list = log.filter(cid == channel.id).order(gen.desc)
            var logs: [MessageLog] = []
            
            for log in try db.prepare(list) {
                let mtype: MessageType
                switch log[type] {
                case MessageType.text.string:
                    mtype = .text
                case MessageType.url.string:
                    mtype = .url
                default:
                    mtype = .text
                }
                logs.append(MessageLog(type: mtype, expires: log[expr], withContent: log[content], for: channel, withLatitude: log[latitude], andLongitude: log[longitude], withString: log[encoded], at: log[gen]))
            }
            
            return logs
        } catch {
            print(error)
        }
        return []
    }
    
    func storeLog(_ messageLog: MessageLog) {
        do {
            let log = Table(TABLE_LOG)
            let cid = Expression<String>(COLUMN_CHANNEL_ID)
            let type = Expression<String>(COLUMN_MESSAGE_TYPE)
            let expr = Expression<Date>(COLUMN_EXPIRATION_DATE)
            let gen = Expression<Date>(COLUMN_GEN_DATE)
            let content = Expression<String>(COLUMN_MESSAGE_CONTENT)
            let latitude = Expression<Double>(COLUMN_LATITUDE)
            let longitude = Expression<Double>(COLUMN_LONGITUDE)
            let encoded = Expression<String>(COLUMN_ENCODED)
            
            try db.run(log.insert(cid <- messageLog.channel.id, type <- messageLog.type.string, expr <- messageLog.expirationDate, gen <- messageLog.date, content <- messageLog.content, latitude <- messageLog.latitude, longitude <- messageLog.longitude, encoded <- messageLog.encoded))
        } catch {
            print(error)
        }
    }
    
    func clearLog(for channel: Channel) {
        do {
            let log = Table(TABLE_LOG)
            let cid = Expression<String>(COLUMN_CHANNEL_ID)
            
            let list = log.filter(cid == channel.id)
            
            try db.run(list.delete())
        } catch {
            print(error)
        }
    }
}
