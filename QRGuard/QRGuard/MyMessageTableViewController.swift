//
//  MyMessageTableViewController.swift
//  QRGuard
//
//  Created by user149673 on 5/26/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit

class MyMessageTableViewController: UITableViewController {

    @IBOutlet weak var generatedDateLabel: UILabel!
    @IBOutlet weak var messageTypeLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var contentButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var exportImageButton: UIButton!
    
    var messageLog = MessageLog()
    var exportImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500.0
        setShadowForButton(exportImageButton)
        contentButton.isHidden = messageLog.type != .url
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        generatedDateLabel.text = dateFormatter.string(from: messageLog.date)
        messageTypeLabel.text = messageLog.type.string
        expirationDateLabel.text = dateFormatter.string(from: messageLog.expirationDate)
        switch messageLog.type {
        case .text: contentLabel.text = messageLog.getTextInfo()
        case .url: contentLabel.text = messageLog.getURLInfo()
        }
        guard let qr = QRCode.generateQRCode(message: messageLog.encoded),
            let exportLogo = UIImage(named: "seqrcast_white")?.withBackground(color: UIColor.black),
            let exportCI = QRCode.generateExportableQRCode(qr, withLogo: exportLogo),
            let cgImage = CIContext().createCGImage(exportCI, from: exportCI.extent),
            let logo = UIImage(named: "seqrcast_white")?.withBackground(color: UIColor.black),
            let custom = QRCode.generateCustomizedQRCode(qr, in: UIColor.black, withLogo: logo) else {
            showAlert(withTitle: "QR Code Generation Error", message: "There was an error generating the QR code. Please try again.")
            return
        }
        
        exportImage = UIImage(cgImage: cgImage)
        qrImageView.image = UIImage(ciImage: custom)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setShadowForButton(_ button: UIButton) {
        button.layer.shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 10.0
        button.layer.masksToBounds = false
    }
    
    
    @IBAction func goToURL(_ sender: UIButton) {
        let urlString = messageLog.getURLInfo().starts(with: "https://") || messageLog.getURLInfo().starts(with: "http://") ? messageLog.getURLInfo() : "https://" + messageLog.getURLInfo()
        guard let url = URL(string: urlString) else {
            showAlert(withTitle: "URL Error", message: "The message does not contain a valid URL.")
            return
        }
        messageLog.hasSafeURL { (isSafe) in
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
    
    @IBAction func exportImage(_ sender: UIButton) {
        if let image = exportImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else {
            showAlert(withTitle: "QR Code Export Error", message: "There is no QR code to be exported.")
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            showAlert(withTitle: "QR Code Export Error", message: "There was an error exporting QR code. Please try again.")
        }
        showAlert(withTitle: "QR Code Exported", message: "The QR code was successfully exported.")
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
