//
//  TableViewController.swift
//  FTP
//
//  Created by zhujian on 2016/12/23.
//  Copyright © 2016年 seewo. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController,loginDelegate {

    
    @IBAction func Back(_ sender: UIBarButtonItem) {
        ftp.Back()
    }
    @IBAction func Online(_ sender: Any) {
        ftp.login()
        
    }
    
    var ftp = FTPModel.init(ip: "192.168.2.8" as CFString, port: 21, username: "zhujian", password: "zaq12wsx")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ftp.delegate = self

        
        ftp.login()
        
    }
    
    func getDataSucess() {
        
        self.tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return (ftp.fileAndDictionary ?? []).count
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.backgroundColor = UIColor.white
        
        //        var fileAndDictionary = ftp.fileAndDictionary
        
        
        
        
        if ftp.fileAndDictionary != nil{
            cell.textLabel?.text = ftp.fileAndDictionary?[indexPath.row][8]
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            if !(ftp.fileAndDictionary![indexPath.row][0].contains("d")){
                cell.textLabel?.backgroundColor = UIColor.gray
            }
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ftp.fileAndDictionary != nil{
            if ftp.fileAndDictionary![indexPath.row][0].contains("d"){
                ftp.ListFile(path: ftp.fileAndDictionary![indexPath.row][8])
            }else{
                ftp.DownloadFile(path: ftp.currentPath, name: ftp.fileAndDictionary![indexPath.row][8])
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        switch event!.subtype {
        case .remoteControlPlay:  // play按钮
            print("play")
            ftp.a?.play()
        case .remoteControlPause:  // pause按钮
            print("pause")
            ftp.a?.pause()
        case .remoteControlNextTrack:  // next
            // ▶▶
            break
        case .remoteControlPreviousTrack:  // previous
            // ◀◀
            break
        default:
            break
        }
    }
}
