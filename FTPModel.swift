//
//  FTPModel.swift
//  FTP
//
//  Created by zhujian on 2016/12/15.
//  Copyright © 2016年 seewo. All rights reserved.
//

import Foundation
import AVFoundation

protocol loginDelegate {
    //    func LoginInformation()
    var username:String{get set}
    var password:String{get set}
    var ipAddress:CFString{get set}
    var Port:UInt32{get set}
    func getDataSucess()
}

class FTPModel:controllerStreamDelegate,listStreamDelegate,dataStreamDalegate {
    
    var listStream = ListStream()
    
    var dataStream = DataStream()
    
    var controllerStream = ControllerStream()
    
    let  sortBrain = SortModel()
    
    var delegate:loginDelegate?
    
    var file:String?
    
    var isMessage = true
    
    var Rcode = 0
    
    var currentPath = ""
    //在这里存放命令字符串
    var commands:[String] = []
    
    var fileAndDictionary:[[String]]?{
        didSet{
            delegate?.getDataSucess()
        }
    }
    
    func login()  {
        controllerStream.delegate = self
        listStream.delegate = self
        dataStream.delegate = self
        if delegate != nil{
            controllerStream.connect(serverAddress: (delegate?.ipAddress)!, serverPort: (delegate?.Port)!)
            commands = ["USER "+(delegate?.username ?? ""),"PASS "+(delegate?.password ?? ""),"OPTS UTF8 ON","PASV","LIST"]
        }
        
        
    }
    
    func needLogin() {
        print("需要重新登录")
        if delegate != nil{
            controllerStream.connect(serverAddress: (delegate?.ipAddress)!, serverPort: (delegate?.Port)!)
            var x = ["USER "+(delegate?.username ?? ""),"PASS "+(delegate?.password ?? ""),"OPTS UTF8 ON"]
            x += commands
            commands = x
        }
        
    }

    //建立数据链接
    private  func DataStreamConnect(port: UInt32) {
        
        if delegate != nil{
            if isMessage{
                listStream.connect(serverAddress: (delegate?.ipAddress)!, serverPort: port)
            }else{
                dataStream.connect(serverAddress: (delegate?.ipAddress)!, serverPort: port)
            }
            //ftp无法拥有两个数据端口，所以下载数据时不能查看文件目录。否则会下载失败
        }
    }
    
    
    internal  func handleWithControllerStreamMessage(message: String) {
        //从接收的消息中提取前三位应答码
        let codeArray = Array.init(message.characters)
        if let code = Int(String(codeArray[0])+String(codeArray[1])+String(codeArray[2])){
            Rcode = code
            switch code {
            case 227:
                //获取服务器数据链接端口号
                let xdivide = message.components(separatedBy: ",")
                if  xdivide.count > 2 {
                    let xdivide1 = UInt32(xdivide[xdivide.count - 2]) ?? 0
                    let xdivide2 = UInt32(xdivide[xdivide.count - 1].components(separatedBy: ")")[0]) ?? 0
                    let port = xdivide1*256+xdivide2
                    print("成功获取到数据端口号："+String(port))
                    DataStreamConnect(port: port)
                }
            case 257:
                let x = message.components(separatedBy: "\"")
                currentPath = x[1]
            default:
                break
            }
            
        }
        commandQueue()
    }
    
    internal  func handleWithDataStreamFile(data: Data) {
        file  = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String + "/1.Mp3"
        if   FileManager().createFile(atPath:file!, contents: data, attributes: nil){
            
            playSong()
        }
        isMessage = true
    }
    
    internal   func handleWithListStreamMessage(message: String) {
        
        var strArr = message.components(separatedBy: "\r\n")
        print(strArr.count)
        strArr.removeLast()
        //MLSD
        //        var xy = [[String]]()
        //
        //        for c in 0..<x.count-1{
        //            var xs = x[c].components(separatedBy: ";")
        //            xs[0] = xs[0].replacingOccurrences(of: "type=", with: "")
        //            xs[1] = xs[1].replacingOccurrences(of: "modify=", with: "")
        //            xs[2] = xs[2].replacingOccurrences(of: "size=", with: "")
        //            xy.append(xs)
        //        }
        //        fileAndDictionary = xy
        var xy = [[String]]()
        
        for c in 0..<strArr.count{
            var x = [String].init(repeating: "", count: 8)
            var xcopy:[String] = []
            var x1 = strArr[c].components(separatedBy: " ")
            for a in 0..<x1.count{
                if x1[a] != "" {
                    xcopy.append(x1[a])
                }
            }
            
            for c in 0...7{
                x[c] = xcopy[c]
            }
            
            xcopy.removeFirst(8)
            var name = ""
            for c in 0..<xcopy.count{
                if c == xcopy.count - 1{
                    name = name + xcopy[c]
                }else{
                    name = name + xcopy[c] + " "
                }
            }
            x.append(name)
            xy.append(x)
            x = [String].init(repeating: "", count: 8)
        }
        
        fileAndDictionary = sortBrain.compareChineseNumber(chineseNumberArray: xy)
        print(fileAndDictionary ?? [])
    }
    
    
    
    
    private  func commandQueue()  {
        print(commands)
        if !commands.isEmpty{
            if controllerStream.outputStream?.streamStatus.rawValue == 2 && Rcode != 421{
                let command = commands.removeFirst()
                controllerStream.SentCommand(command: command, withOutputStream: controllerStream.outputStream!)
            }else{
                print("outPutStream不在打开状态，无法发出命令")
                needLogin()
            }
        }
    }
    
    
    
    func ListFile(path:String) {
        if dataStream.inputStream?.streamStatus.rawValue != 2{
            commands = ["CWD "+path,"PWD","PASV","LIST"]
            commandQueue()
        }else{
            print("命令无法打开列表，请稍后尝试")
        }
        
    }
    
    
    func DownloadFile(path:String,name:String)  {
        //dataStream写入的时候不再发出命令
        if dataStream.inputStream?.streamStatus.rawValue != 2{
            let RETR = "RETR "+name
            let SIZE = "SIZE "+name
            commands = ["CWD "+path,SIZE,"PASV",RETR]
            isMessage = false
            commandQueue()
            
        }else{
            print("有任务或者有错误无法下载")
        }
        
    }
    
    //退回上一目录
    func Back()  {
        if dataStream.inputStream?.streamStatus.rawValue != 2{
            commands = ["CDUP","PWD","PASV","LIST"]
            commandQueue()
        }else{
            print("无法返回，请稍后尝试")
        }
    }
    
    //上传文件
    func Upload(path:String,file:Data)  {
        
    }
    
    //重命名文件
    func RenameFile(sourceName:String,targetName:String)  {
        commands = ["RNFR "+sourceName,"RNTO "+targetName]
        commandQueue()
    }
    
    //创建新目录
    func CreateNewFile(fileName:String) {
        commands = ["MKD "+fileName]
        commandQueue()
    }
    
    func DeleteFile(path:String,fileName:String){
        commands = ["CWD "+path,"DELE "+fileName,"PASV","LIST"]
        commandQueue()
    }
    
    func DeleteDictionary(path:String,dictionary:String){
        commands = ["CWD "+path,"RMD "+dictionary,"PASV","LIST"]
        commandQueue()
    }
    
    
    
    
    var a:AVAudioPlayer?
    var songIsStart = false
    func playSong()  {
        if file != nil{
            do  {
                a = try AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: file!))
                
            }
            catch {
                a = nil
            }
            if a != nil{
                a!.play()
                print(a!.duration/60)
                print(a!.currentTime)
            }
            
            songIsStart = true
        }
        
    }
    
    
}
