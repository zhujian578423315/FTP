//
//  DataStream.swift
//  FTP
//
//  Created by zhujian on 2016/12/22.
//  Copyright © 2016年 seewo. All rights reserved.
//

import Foundation
import AVFoundation


protocol dataStreamDalegate {
    func handleWithDataStreamFile(data:Data)
}

class DataStream:StreamCreate {
    
    var delegate:dataStreamDalegate?
    
    
    var tempBuffer = [UInt8](repeating: 0, count: 0)
    var tempData = Data()

//    var queue1 = DispatchQueue.init(label: "1")
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
//        case Stream.Event.openCompleted:
//            print(aStream.description+"数据流打开成功")
        case Stream.Event.hasBytesAvailable:
            
            if  let inputStream = aStream as? InputStream {
                let bufferSize = 40000
                var buffer = [UInt8](repeating: 0, count: bufferSize)
                while (inputStream.hasBytesAvailable){
                    //将接收到的内容放到buffer里面
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    if(len > 0){
                        let temp = buffer.dropLast(bufferSize-len)
                        self.tempBuffer += temp
                    }else{
                        let data = Data.init(bytes: tempBuffer)
                        delegate?.handleWithDataStreamFile(data: data)
                        tempBuffer = [UInt8](repeating: 0, count: 0)
                        self.inputStream?.close()
                        self.outputStream?.close()
                    }
                }
            }
//        case Stream.Event.hasSpaceAvailable:
//            print("数据流有可写空间")
//        case Stream.Event.errorOccurred:
//            print("数据流遇到错误")
//            print(aStream.streamError?.localizedDescription ?? "unknow error")
//        case Stream.Event.endEncountered:
//            aStream.close()
//            aStream.remove(from: .current, forMode: .defaultRunLoopMode)
//            print("数据流结束")
            default:break
        }
        
    }
    
    
    
}
