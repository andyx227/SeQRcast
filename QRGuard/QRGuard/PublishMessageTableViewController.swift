//
//  PublishMessageTableViewController.swift
//  QRGuard
//
//  Created by user149673 on 5/27/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit

class PublishMessageTableViewController: UITableViewController {
    
    
    @IBOutlet weak var segmedtedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var wordCountLabel: UILabel!
    
    var channel = MyChannel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = Date(timeIntervalSinceNow: 60.0)
        contentTextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        tableView.addGestureRecognizer(tapGesture)
        
        if MessageType(rawValue: segmedtedControl.selectedSegmentIndex) == .url {
            contentTextView.keyboardType = .URL
            contentTextView.autocapitalizationType = .none
        }
        else {
            contentTextView.keyboardType = .default
            contentTextView.autocapitalizationType = .sentences
        }
        wordCountLabel.text = "\(contentTextView.text.count) / \(Message.MAX_CONTENT_LENGTH)"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func tableTapped() {
        self.view.endEditing(true)
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        if MessageType(rawValue: segmedtedControl.selectedSegmentIndex) == .url {
            contentTextView.keyboardType = .URL
            contentTextView.autocapitalizationType = .none
        }
        else {
            contentTextView.keyboardType = .default
            contentTextView.autocapitalizationType = .sentences
        }
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        self.view.endEditing(true)
    }
    
    @IBAction func publishMessage(_ sender: UIBarButtonItem) {
        guard let type = MessageType(rawValue: segmedtedControl.selectedSegmentIndex) else {
            showAlert(withTitle: "Message Publication Error", message: "There was an error publishing the message. Please try again.")
            return
        }
        
        if contentTextView.text.count > Message.MAX_CONTENT_LENGTH {
            showAlert(withTitle: "Message Publication Error", message: "The message content should not be over \(Message.MAX_CONTENT_LENGTH) characters.")
        }
        else if datePicker.date < Date() {
            datePicker.minimumDate = Date(timeIntervalSinceNow: 60.0)
            showAlert(withTitle: "Message Publication Error", message: "The expiration date must be after the current time.")
        }
        else if contentTextView.text.count == 0 {
            showAlert(withTitle: "Message Publication Error", message: "The message content cannot be empty.")
        }
        else if type == .url, !contentTextView.text.isValidURL {
            showAlert(withTitle: "Message Publication Error", message: "The message content should be in the form of a URL.")
        }
        
        let message = Message(type: type, expires: datePicker.date, withContent: contentTextView.text, for: channel)
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "messageQRViewController") as! MessageQRViewController
        viewController.message = message
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PublishMessageTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        wordCountLabel.text = "\(textView.text.count) / \(Message.MAX_CONTENT_LENGTH)"
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
        
        if textView.text.count > Message.MAX_CONTENT_LENGTH {
            wordCountLabel.textColor = UIColor.red
        }
        else {
            wordCountLabel.textColor = UIColor.black
        }
    }
}
