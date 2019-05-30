//
//  MessageDisplayTableViewController.swift
//  QRGuard
//
//  Created by user149673 on 5/28/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import CoreLocation

class MessageDisplayTableViewController: UITableViewController {
    
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var messageTypeLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var contentButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    
    var message = Message()
    var spinner = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if message.channel.publicKey != Storage.publicKey {
            self.navigationItem.backBarButtonItem?.isEnabled = false
            showSpinner()
            CLLocationManager().requestLocation()
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500.0
        channelNameLabel.text = message.channel.name
        contentButton.isHidden = message.type != .url
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        messageTypeLabel.text = message.type.string
        expirationDateLabel.text = dateFormatter.string(from: message.expirationDate)
        switch message.type {
        case .text: contentLabel.text = message.getTextInfo()
        case .url: contentLabel.text = message.getURLInfo()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func goToURL(_ sender: UIButton) {
        let urlString = message.getURLInfo().starts(with: "https://") || message.getURLInfo().starts(with: "http://") ? message.getURLInfo() : "https://" + message.getURLInfo()
        guard let url = URL(string: urlString) else {
        showAlert(withTitle: "URL Error", message: "The message does not contain a valid URL.")
        return
        }
        
        message.hasSafeURL { (isSafe) in
            if isSafe {
                UIApplication.shared.open(url, options: [:]) { (success) in
                    if !success {
                        self.showAlert(withTitle: "URL Error", message: "The URL could not be opened.")
                    }
                }
            }
            else {
                let alert = UIAlertController(title: "Suspicious URL", message: "This URL may be contain malicious content. Would you like to proceed?", preferredStyle: .alert)
                let proceed = UIAlertAction(title: "Proceed", style: .default, handler: { (action) in
                    UIApplication.shared.open(url, options: [:]) { (success) in
                        if !success {
                            self.showAlert(withTitle: "URL Error", message: "The URL could not be opened.")
                        }
                    }
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                })
                alert.addAction(cancel)
                alert.addAction(proceed)
                self.present(alert, animated: true)
            }
        }
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func showSpinner() {
        DispatchQueue.main.async {
            self.spinner = UIView.init(frame: self.view.bounds)
            self.spinner.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue:0.5, alpha: 0.5)
            let activity = UIActivityIndicatorView.init(style: .whiteLarge)
            activity.startAnimating()
            activity.center = self.spinner.center
            self.spinner.addSubview(activity)
            self.view.addSubview(self.spinner)
        }
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.spinner.removeFromSuperview()
        }
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

extension MessageDisplayTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first, let encoded = try? message.encryptedString() else {
            return
        }
        let log = MessageLog(for: message, withLatitude: location.coordinate.latitude, andLongitude: location.coordinate.longitude, withString: encoded, at: Date())
        Database.shared.storeLog(log)
        self.navigationItem.backBarButtonItem?.isEnabled = true
        removeSpinner()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let encoded = try? message.encryptedString() else {
            return
        }
        let log = MessageLog(for: message, withString: encoded, at: Date())
        Database.shared.storeLog(log)
        self.navigationItem.backBarButtonItem?.isEnabled = true
        removeSpinner()
    }
}
