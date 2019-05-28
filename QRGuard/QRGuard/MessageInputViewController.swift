//
//  MessageInputViewController.swift
//  QRGuard
//
//  Created by Andy Xue on 5/27/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit

class MessageInputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var messageInput: UITextView!
    @IBOutlet weak var messageTypePicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var channel: Channel?
    var messageTypes: [MessageType] = [MessageType.text, MessageType.url]
    var messageTypeChosen: MessageType = MessageType.text  // Select "text" by default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTypePicker.delegate = self
        messageTypePicker.dataSource = self
        self.hideKeyboardWhenScreenIsTapped()
    }
    
    @IBAction func generateEncryptedQR(_ sender: Any) {
        if datePicker.date <= Date() {
            showAlert(withTitle: "Invalid Expiration Date", message: "Please choose an expiration date that is later than the current date.")
            return
        }
        
        guard let currentChannel = channel else {
            showAlert(withTitle: "An Internal Error Has Occurred", message: "The QR code for your message could not be generated. Please try again.")
            return
        }
        
        let expirationDate = datePicker.date
        let content = messageInput.text ?? ""
        if content.isEmpty { showAlert(withTitle: "Empty Message", message: "Please enter a message.") }
        let message = Message(type: messageTypeChosen, expires: expirationDate, withContent: content, for: currentChannel)
        
        guard let qr = try? message.encrypt(), let image = CIContext().createCGImage(qr, from: qr.extent) else {
            showAlert(withTitle: "QR Code Generation Error", message: "There was an error generating the QR code. Please try again.")
            return
        }
        /// TODO: transfer encrypted message qr code to MessageQRViewController

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return messageTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return messageTypes[row].string
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        messageTypeChosen = messageTypes[row]
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

extension UIViewController {
    func hideKeyboardWhenScreenIsTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
