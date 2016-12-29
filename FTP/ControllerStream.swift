//
//  ControllerStream.swift
//  FTP
//
//  Created by zhujian on 2016/12/22.
//  Copyright © 2016年 seewo. All rights reserved.
//

import Foundation


protocol controllerStreamDelegate {
    func handleWithControllerStreamMessage(message:String)->Void
}

class ControllerStream: StreamCreate {
    
    var delegate:controllerStreamDelegate?
    
    
    var currentCode = Int()
    
    
    
    //利用输出流发送ftp命令
    func SentCommand(command:String,withOutputStream:OutputStream)  {
            let command = command+"\r\n"
            
            let buffer:[UInt8] = Array.init(command.utf8)
         let x =  withOutputStream.write(buffer, maxLength: buffer.count)
            print("已发送命令："+command)
        
    }
    
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.openCompleted:
            print(aStream.description+"控制流打开成功")
        case Stream.Event.hasBytesAvailable:
            print("控制流检测到有待接收数据！！")
            //异步保存数据到容器中
            if  let inputStream = aStream as? InputStream {
                
                var buffer = [UInt8](repeating: 0, count: 1024*8)
                while (inputStream.hasBytesAvailable){
                    //将接收到的内容放到buffer里面
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    print("接收到长度为"+len.description+"的数据")
                    if(len > 0){
                        let y = Data.init(bytes: buffer)
                        
                        let x = String.init(data: y, encoding: .utf8)
                        
                        if x != nil{
                            print("ControllerStreamSay:"+x!)
                            delegate?.handleWithControllerStreamMessage(message: x!)
                        }
                    }
                }
            }
        case Stream.Event.hasSpaceAvailable:
            print("控制流有可写空间")
        case Stream.Event.errorOccurred:
            print("控制流遇到错误")
            print(aStream.streamError?.localizedDescription ?? "unknow error")
        case Stream.Event.endEncountered:
            aStream.close()
            aStream.remove(from: .current, forMode: .defaultRunLoopMode)
            print("控制流结束")
        default:
            print("default")
        }
        
    }
    
}
