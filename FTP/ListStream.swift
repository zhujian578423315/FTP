//
//  ListStream.swift
//  FTP
//
//  Created by zhujian on 2016/12/22.
//  Copyright © 2016年 seewo. All rights reserved.
//

import Foundation

//
//  DataStream.swift
//  FTP
//
//  Created by zhujian on 2016/12/22.
//  Copyright © 2016年 seewo. All rights reserved.
//

import Foundation
import AVFoundation

protocol listStreamDelegate {
    func handleWithListStreamMessage(message:String)->Void
}

class ListStream:StreamCreate {
    
    var delegate:listStreamDelegate?
    
    var tempBuffer = [UInt8](repeating: 0, count: 0)
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
//        case Stream.Event.openCompleted:
//            print(aStream.description+"列表流打开成功")
        case Stream.Event.hasBytesAvailable:
//            print("列表流检测到有待接收数据！！")
            
            if  let inputStream = aStream as? InputStream {
                
                let bufferSize = 1024*4
                var buffer = [UInt8](repeating: 0, count: bufferSize)
                while (inputStream.hasBytesAvailable){
                    //将接收到的内容放到buffer里面
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    if(len > 0){
                        let temp = buffer.dropLast(bufferSize-len)
                        self.tempBuffer += temp
                    }else{
                        let y = Data.init(bytes: tempBuffer)
                        
                        let x = String.init(data: y, encoding: .utf8)
                        
                        if x != nil{
                            delegate?.handleWithListStreamMessage(message: x!)
                        }
                        tempBuffer = [UInt8](repeating: 0, count: 0)
                        self.inputStream?.close()
                        self.outputStream?.close()
                        
                    }   
                }
            }
//        case Stream.Event.hasSpaceAvailable:
//            print("列表流有可写空间")
//        case Stream.Event.errorOccurred:
//            print("列表流遇到错误")
//            print(aStream.streamError?.localizedDescription ?? "unknow error")
//        case Stream.Event.endEncountered:
//            aStream.close()
//            aStream.remove(from: .current, forMode: .defaultRunLoopMode)
//            print("列表流结束")
            default:break
        }
        
    }
    
}
