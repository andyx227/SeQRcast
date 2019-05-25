//
//  Message.swift
//  QRGuard
//
//  Created by Noshin Kamal on 5/25/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import Foundation

class Message {
    var message: [String] = []
    
    override func viewDidLoad() {
        
    }
    
    public func generateMessage(text:String) -> [String] {
        message[0] = text;
        message[1] = getExpirationDate(2).toDateTimeString();
        if validateUrl(text) == true {
            message[2] = "URL"
        }
        else {
            message[2] = "STRING"
        }
        return message;
    }
    
    public func getExpirationDate(minutes: Int) -> Date {
        var components = DateComponents();
        components.setValue(minutes, for: .minutes);
        let date: Date = Date();
        let expirationDate = Calendar.current.date(byAdding: components, to: date);
        
        return expirationDate!;
    }
    
    func validateUrl (urlString: String?) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluateWithObject(urlString)
    }
}

extension Date {
    func toDateTimeString() -> String {
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        
        let myString = formatter.string(from: self);
        
        return myString;
    }
}

