//
//  Stream.swift
//  FTP
//
//  Created by zhujian on 2016/12/22.
//  Copyright © 2016年 seewo. All rights reserved.
//

import Foundation


class StreamCreate:NSObject,StreamDelegate {
    
    var inputStream:InputStream?
    var outputStream:OutputStream?
    
    
    
    func connect(serverAddress:CFString,serverPort:UInt32) {
        if inputStream != nil && outputStream != nil{
            inputStream?.close()
            outputStream?.close()
        }
        let serverAddress: CFString = serverAddress
        let serverPort: UInt32 = serverPort
        print("链接建立中...")
        
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, serverAddress, serverPort, &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
            inputStream?.delegate = self
            outputStream?.delegate = self
            
            inputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            outputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            
            inputStream?.open()
            outputStream?.open()

    }

}
