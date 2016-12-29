//
//  ViewController.swift
//  FTP
//
//  Created by zhujian on 2016/11/29.
//  Copyright © 2016年 seewo. All rights reserved.
//

import UIKit
import MediaPlayer


class ViewController: UIViewController {
    internal var password: String = ""

    internal var username: String = "" 

    @IBAction func button1(_ sender: UIButton) {
        
     
    }
    
    
    func getDataSucess() {
        let tvc = storyboard?.instantiateViewController(withIdentifier: "123") as! TableViewController
        tvc.ftp = self.ftp
        
        self.navigationController?.pushViewController(tvc, animated: true)
    }
    
    
    @IBAction func play(_ sender: UIButton) {

        ftp.DownloadFile(path:"/to be",name: "半城烟沙.mp3")
        
    }
    
    @IBAction func Online(_ sender: Any) {
      
    }
    
    
    @IBOutlet var command: UITextField!
    
    let ftp = FTPModel()
    

    let ip = "192.168.2.8"
    let port = 21
    
    override func viewDidLoad() {
//        ftp.delegate = self
        


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

