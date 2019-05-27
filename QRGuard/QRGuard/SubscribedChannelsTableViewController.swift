//
//  SubscribedChannelsTableViewController.swift
//  QRGuard
//
//  Created by user149673 on 5/23/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit

class SubscribedChannelsTableViewController: UITableViewController {

    var channels: [SubscribedChannel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channels = Storage.subscribedChannels.enumerated().compactMap{ SubscribedChannel(at: $0.offset ) }
        tableView.reloadData()
        tableView.isEditing = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actions = UIAlertController(title: channels[indexPath.row].name, message: "Select the action you would like to perform on this channel.", preferredStyle: .actionSheet)
        let pastMessages = UIAlertAction(title: "View Messages", style: .default) { (action) in
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "messageLogTableViewController") as! MessageLogTableViewController
            viewController.channel = self.channels[indexPath.row]
            viewController.type = .subscribed
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        let unsubscribe = UIAlertAction(title: "Unsubscribe", style: .destructive) { (action) in
            self.unsubscribe(at: indexPath)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actions.addAction(pastMessages)
        actions.addAction(unsubscribe)
        actions.addAction(cancel)
        self.present(actions, animated: true)
    }

    func unsubscribe(at indexPath: IndexPath) {
        let ask = UIAlertController(title: "Unsubscribe", message: "Do you really want to unsubscribe from \(channels[indexPath.row].name)?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.channels.remove(at: indexPath.row)
            Storage.subscribedChannels.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        ask.addAction(cancel)
        ask.addAction(confirm)
        self.present(ask, animated: true)
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
