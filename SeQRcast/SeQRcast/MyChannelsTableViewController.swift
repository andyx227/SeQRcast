//
//  MyChannelsTableViewController.swift
//  SeQRcast
//
//  Created by user149673 on 5/23/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyChannelsTableViewController: UITableViewController {
    
    var channels: [MyChannel] = []
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channels = Storage.myChannels.enumerated().compactMap{ MyChannel(at: $0.offset ) }
        tableView.reloadData()
        tableView.isEditing = true
        dateFormatter.dateFormat = "MM/dd/yyyy"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell") ?? UITableViewCell(style: .default, reuseIdentifier: "channelCell")

        cell.textLabel?.text = channels[indexPath.row].name
        cell.detailTextLabel?.text = "Created on \(dateFormatter.string(from: channels[indexPath.row].createDate))"
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actions = UIAlertController(title: channels[indexPath.row].name, message: "Select the action you would like to perform on this channel.", preferredStyle: .actionSheet)
        let generate = UIAlertAction(title: "Publish Message", style: .default) { (action) in
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "publishMessageTableViewController") as! PublishMessageTableViewController
            viewController.channel = self.channels[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        let share = UIAlertAction(title: "Share Channel", style: .default) { (action) in
            // move to scan public key screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let scanPublicKeyVC = storyboard.instantiateViewController(withIdentifier: "scanPublicKeyViewController") as! ScanPublicKeyViewController
            scanPublicKeyVC.channelData = self.channels[indexPath.row]
            self.navigationController?.pushViewController(scanPublicKeyVC, animated: true)
        }
        let pastMessages = UIAlertAction(title: "View Messages", style: .default) { (action) in
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "messageLogTableViewController") as! MessageLogTableViewController
            viewController.channel = self.channels[indexPath.row]
            viewController.type = .my
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        let delete = UIAlertAction(title: "Delete Channel", style: .destructive) { (action) in
            self.delete(at: indexPath)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actions.addAction(generate)
        actions.addAction(share)
        actions.addAction(pastMessages)
        actions.addAction(delete)
        actions.addAction(cancel)
        self.present(actions, animated: true)
    }
    
    func delete(at indexPath: IndexPath) {
        let ask = UIAlertController(title: "Delete Channel", message: "Do you really want to delete \(channels[indexPath.row].name)?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.channels.remove(at: indexPath.row)
            Storage.myChannels.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        ask.addAction(cancel)
        ask.addAction(confirm)
        self.present(ask, animated: true)
    }
    
    @IBAction func addChannel(_ sender: UIBarButtonItem) {
        let form = UIAlertController(title: "Create Channel", message: "Enter a name for your new channel.", preferredStyle: .alert)
        form.addTextField { (textField) in
            textField.placeholder = "Channel Name"
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            guard let text = form.textFields?.first?.text, text.count > 0 else {
                self.showAlert(withTitle: "Channel Cannot Be Created", message: "Please enter a name for your channel.")
                return
            }
            if text.count > Channel.MAX_NAME_LENGTH {
                self.showAlert(withTitle: "Channel Cannot Be Created", message: "Channel name cannot exceed 64 letters.")
                return
            }
            guard let channel = MyChannel(named: text) else {
                self.showAlert(withTitle: "Channel Cannot Be Created", message: "You already have a channel named \(text).")
                return
            }
            
            self.showAlert(withTitle: "Channel Created", message: "Successfully created channel \(text).")
            DispatchQueue.main.async {
                self.channels.append(channel)
                self.tableView.insertRows(at: [IndexPath(row: self.channels.count - 1, section: 0)], with: .automatic)
            }
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        form.addAction(cancel)
        form.addAction(ok)
        self.present(form, animated: true)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .cancel) { (alertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        channels.insert(channels.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
        Storage.myChannels.insert(Storage.myChannels.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    

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
