//
//  streamAudio.swift
//  StreamAudio
//
//  Created by zhujian on 2017/2/5.
//  Copyright © 2017年 storm. All rights reserved.
//

import Foundation
import AudioToolbox

public  class MyData{
    var audioFileStream:AudioFileStreamID? = nil
    var audioQueue:AudioQueueRef? = nil
    var audioQueueBuffer = Array.init(repeating: AudioQueueBufferRef.init(bitPattern:MemoryLayout.size(ofValue: AudioQueueBuffer.self)), count: 3)
    var packetDescs = Array.init(repeating: AudioStreamPacketDescription(), count: streamAudio.kAQMaxPacketDescs)
    var fillBufferIndex:Int = 0
    var bytesFilled:UInt32 = 0
    var packetsFilled:UInt32 = 0
    var inuse = Array.init(repeating: false, count: streamAudio.kNumAQBufs)
    var started:Bool = false
    var failed:Bool = false
    var mutex = pthread_mutex_t()
    var cond = pthread_cond_t()
    var done = pthread_cond_t()
}


class streamAudio:StreamCreate {
    static  let kNumAQBufs = 3
    static  let kAQBufSize:UInt32 = 128 * 1024
    static  let kAQMaxPacketDescs = 512
    
    let kRecvBufSize = 40000
    var connection_socket:Int = 0
    var defaultIp = "127.0.0.1" as CFString
    var defaultPort:in_port_t = 51515
    var RecvdCompleted = false
    
    var myData = MyData()
    
    func mainStart(ip:CFString,Port:UInt32)  {
        defaultIp = ip
        defaultPort = in_port_t(Port)
        
        while kAudioQueueProperty_IsRunning == 0{
            continue
        }
        
        myData = MyData()
        
        pthread_mutex_init(&myData.mutex, nil)
        pthread_cond_init(&myData.cond, nil)
        pthread_cond_init(&myData.done, nil)
        
        //        let q = DispatchQueue.init(label: "1")
        DispatchQueue.main.async {
            self.connect(serverAddress: self.defaultIp, serverPort: UInt32(self.defaultPort))
        }
        
        
        //connect socket
        //        let connection_socket = MyConnectSocket()
        //        guard connection_socket > 0 else{
        //            print("connectfaild")
        //            return
        //        }
        //        print("connected")
        
        var err = AudioFileStreamOpen(&myData, MyPropertyListenerProc, MyPacketsProc,kAudioFileAAC_ADTSType, &myData.audioFileStream)
        guard err == 0 && myData.audioFileStream != nil else{
            print("AudioFileStreamOpenError")
            return
        }
        
        //            var buf = Array.init(repeating: Int8(), count: kRecvBufSize)
        //        while !myData.failed {
        //            print("receive")
        //            let bytesRecvd = recv(Int32(connection_socket), &buf, kRecvBufSize, 0)
        //            print("bytesRecvd:"+bytesRecvd.description)
        //            guard bytesRecvd > 0 else{
        //                print("RecvdComplete!")
        //                break
        //            }
        //            let err = AudioFileStreamParseBytes(myData.audioFileStream!, UInt32(bytesRecvd), buf, AudioFileStreamParseFlags(rawValue: 0))
        //            guard err == 0 else{
        //                print("AudioFileStreamParseBytesError"+err.description)
        //                break
        //            }
        
        //        }
        
        
        
        
        //        guard myData.started == true else{
        //            return
        //        }
        //
        //        err = streamAudio.MyEnqueueBuffer(&myData)
        //
        //        print("flushing")
        //        err = AudioQueueFlush(myData.audioQueue!)
        //        guard err == 0 else {
        //            print("AudioQueueFlushError")
        //            return
        //        }
        //
        //        print("stopping")
        //        err = AudioQueueStop(myData.audioQueue!, false)
        //        guard err == 0 else {
        //            print("AudioQueueStopError")
        //            return
        //        }
        //
        //        print("waiting until finished playing..")
        //        pthread_mutex_lock(&myData.mutex)
        //        pthread_cond_wait(&myData.done, &myData.mutex)
        //        pthread_mutex_unlock(&myData.mutex)
        //
        //        err = AudioFileStreamClose(myData.audioFileStream!)
        //        err = AudioQueueDispose(myData.audioQueue!, false)
        //        close(Int32(connection_socket))
    }
    
    //    func streamDataReceive(inDataByteSize:UInt32,buf:[Int8])->Bool  {
    //        print("receive")
    //        let err = AudioFileStreamParseBytes(myData.audioFileStream!, UInt32(inDataByteSize), buf, AudioFileStreamParseFlags(rawValue: 0))
    //        guard err == 0 else{
    //            print("AudioFileStreamParseBytesError"+err.description)
    //            return false
    //        }
    //        return true
    //    }
    
    let q = DispatchQueue.init(label: "1")
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        q.async {
            
            
            
            switch eventCode {
            case Stream.Event.hasBytesAvailable:
                if  let inputStream = aStream as? InputStream {
                    let bufferSize = 40000
                    var buffer = Array.init(repeating: UInt8(),count: bufferSize)
                    while (inputStream.hasBytesAvailable){
                        //将接收到的内容放到buffer里面
                        let len = inputStream.read(&buffer, maxLength: bufferSize)
                        if(len > 0){
                            print("receive")
                            let err = AudioFileStreamParseBytes(self.myData.audioFileStream!, UInt32(len), buffer, AudioFileStreamParseFlags(rawValue: 0))
                            guard err == 0 else{
                                print("AudioFileStreamParseBytesError"+err.description)
                                return
                            }
                            
                        }else{
                            
                            //                        var err = OSStatus()
                            //                        guard myData.started == true else{
                            //                            return
                            //                        }
                            //                        err = streamAudio.MyEnqueueBuffer(&myData)
                            //
                            //                        print("flushing")
                            //                        err = AudioQueueFlush(myData.audioQueue!)
                            //                        guard err == 0 else {
                            //                            print("AudioQueueFlushError")
                            //                            return
                            //                        }
                            //
                            //                        print("stopping")
                            //                        err = AudioQueueStop(myData.audioQueue!, false)
                            //                        guard err == 0 else {
                            //                            print("AudioQueueStopError")
                            //                            return
                            //                        }
                            //
                            //                        print("waiting until finished playing..")
                            //                        pthread_mutex_lock(&myData.mutex)
                            //                        pthread_cond_wait(&myData.done, &myData.mutex)
                            //                        pthread_mutex_unlock(&myData.mutex)
                            //
                            //                        err = AudioFileStreamClose(myData.audioFileStream!)
                            //                        err = AudioQueueDispose(myData.audioQueue!, false)
                            
                            self.inputStream?.close()
                            self.outputStream?.close()
                        }
                        
                    }
                }
                
            default:break
            }
        }
    }
    
    
    let MyPropertyListenerProc:AudioFileStream_PropertyListenerProc = { (inClientData, inAudioFileStream, inPropertyID, ioFlags) in
        //this is called by audio file stream when it finds property values
        var myData = inClientData.assumingMemoryBound(to: MyData.self)
        var err:OSStatus = noErr
        
        print("found property")
        //        print(inPropertyID)
        switch (inPropertyID){
        case kAudioFileStreamProperty_ReadyToProducePackets:
            var asbd = AudioStreamBasicDescription()
            var asbdSize = UInt32(MemoryLayout.size(ofValue: asbd.self))
            
            err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd)
            
            guard err == 0 else {
                print("AudioFileStreamGetPropertyError")
                myData.pointee.failed = true
                return
            }
            
            err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, myData, nil, nil, 0, &myData.pointee.audioQueue)
            
            guard err == 0 else{
                print("AudioQueueNewOutputError"+err.description)
                return
            }
            
            for i in 0..<streamAudio.kNumAQBufs{
                err = AudioQueueAllocateBuffer(myData.pointee.audioQueue!, streamAudio.kAQBufSize, &myData.pointee.audioQueueBuffer[i])
                guard err == 0 else{
                    print("AudioQueueAllocateBufferError")
                    return
                }
            }
            
            //get the cookie size
            var cookieSize = UInt32()
            var writeable = DarwinBoolean.init(booleanLiteral: Bool())
            err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writeable)
            
            guard err == 0 else{
                print("AudioFileStreamGetPropertyInfoError:"+err.description)
                break
            }
            print("cookieSize"+cookieSize.description)
            
            //get the cookie data
            var cookieData = calloc(1, Int(cookieSize))
            err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize,&cookieSize)
            guard err == 0 else{
                print("AudioFileStreamGetPropertyError")
                break
            }
            
            //set the cookie on the queue
            err = AudioFileStreamSetProperty(myData.pointee.audioQueue!, kAudioQueueProperty_MagicCookie, cookieSize,cookieData!)
            guard err == 0 else{
                print("AudioFileStreamSetPropertyError")
                break
            }
            
            
            
            //listen for kaudioQueueProperty_IsRunning
            err = AudioQueueAddPropertyListener(myData.pointee.audioQueue!, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, myData)
            
            guard err == 0 else {
                myData.pointee.failed = true
                print("AudioQueueAddPropertyListenerError")
                break
            }
            
        default: break
        }
        
    }
    
    
    let MyPacketsProc:AudioFileStream_PacketsProc = { (inClientData,inNumberBytes, inNumberPackets, inInputData, inPacketDescriptions) in
        var err = OSStatus()
        //this is called by audio file stream when it finds packets of audio
        var myData = inClientData.assumingMemoryBound(to: MyData.self)
        var str = "got data:"+inNumberBytes.description+" packets:"+inNumberPackets.description
        print(str)
        
        //the following code assumes wa're streaming VBR data. for CBR data, you'd need another code branch here
        for i in 0..<Int(inNumberPackets){
            var packetOffset = inPacketDescriptions[i].mStartOffset
            var packetSize = inPacketDescriptions[i].mDataByteSize
            
            var bufSpaceRemaining = kAQBufSize - myData.pointee.bytesFilled
            
            if (bufSpaceRemaining < packetSize){
                err =  streamAudio.MyEnqueueBuffer(myData)
                streamAudio.WaitForFreeBuffer(myData)
            }
            
            
            //copy data to the audio queue buffer
            var fillBuf:AudioQueueBufferRef = myData.pointee.audioQueueBuffer[myData.pointee.fillBufferIndex]!
            
            //            let distData = NSData.init(bytes: fillBuf.pointee.mAudioData, length: Int(packetSize))
            
            
            
            
            //swift下的参数内存无法访问,所以memcpy中的参数不能放倒swift变量中
            //            let x = fillBuf.pointee.mAudioData + Int(myData.pointee.bytesFilled)
            
            
            memcpy(fillBuf.pointee.mAudioData + Int(myData.pointee.bytesFilled),inInputData + Int(packetOffset), Int(packetSize))
            
            
            
            myData.pointee.packetDescs[Int(myData.pointee.packetsFilled)] = inPacketDescriptions[i]
            myData.pointee.packetDescs[Int(myData.pointee.packetsFilled)].mStartOffset = Int64(myData.pointee.bytesFilled)
            
            
            myData.pointee.bytesFilled += packetSize
            myData.pointee.packetsFilled += 1
            
            var packetsDescsRemaining = streamAudio.kAQMaxPacketDescs - Int(myData.pointee.packetsFilled)
            if packetsDescsRemaining == 0{
                err = streamAudio.MyEnqueueBuffer(myData)
                streamAudio.WaitForFreeBuffer(myData)
            }
        }
        
        
    }
    
    
    static  let MyAudioQueueOutputCallback:AudioQueueOutputCallback = { (inClientData,inAQ, inBuffer) in
        print("callback")
        //this is called by the audio queue when it has finshed decoding our data
        var myData = inClientData!.assumingMemoryBound(to: MyData.self)
        
        var bufIndex = MyFindQueueBuffer(myData, inBuffer: inBuffer)
        
        
        
        pthread_mutex_lock(&myData.pointee.mutex)
        myData.pointee.inuse[bufIndex] = false
        pthread_cond_signal(&myData.pointee.cond)
        pthread_mutex_unlock(&myData.pointee.mutex)
    }
    
    static let MyAudioQueueIsRunningCallback:AudioQueuePropertyListenerProc = { (inClientData,inAQ,inID) in
        var myData = inClientData!.assumingMemoryBound(to: MyData.self)
        var running = UInt32()
        var size = UInt32()
        var err = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &running, &size)
        
        guard err == 0 else{
            print("AudioQueueGetPropertyError")
            return
        }
        
        if (running == 0){
            pthread_mutex_lock(&myData.pointee.mutex)
            pthread_cond_signal(&myData.pointee.cond)
            pthread_mutex_unlock(&myData.pointee.mutex)
        }
        
    }
    
    
    
    
    static  func MyFindQueueBuffer(_ myData:UnsafeMutablePointer<MyData>,inBuffer:AudioQueueBufferRef) -> Int {
        for i in 0..<streamAudio.kNumAQBufs {
            if (inBuffer == myData.pointee.audioQueueBuffer[i]){
                return i
            }
        }
        return -1
    }
    
    
    
    static  func MyEnqueueBuffer(_ myData:UnsafeMutablePointer<MyData>) -> OSStatus {
        var err:OSStatus = noErr
        myData.pointee.inuse[myData.pointee.fillBufferIndex] = true
        
        let fillBuf = myData.pointee.audioQueueBuffer[myData.pointee.fillBufferIndex]!
        
        fillBuf.pointee.mAudioDataByteSize = myData.pointee.bytesFilled
        
        err = AudioQueueEnqueueBuffer(myData.pointee.audioQueue!, fillBuf, myData.pointee.packetsFilled, myData.pointee.packetDescs)
        
        guard err == 0 else{
            print("AudioQueueEnqueueBufferError")
            return -1
        }
        err = StartQueueIfNeeded(myData)
        
        
        return err
    }
    
    static  func StartQueueIfNeeded(_ myData:UnsafeMutablePointer<MyData>) -> OSStatus {
        var err:OSStatus = noErr
        if (!myData.pointee.started){
            err = AudioQueueStart(myData.pointee.audioQueue!, nil)
            if err == 0 {
                myData.pointee.started = true
                print("started")
            }else{
                myData.pointee.failed = true
                print("AudioQueueStartError"+err.description)
            }
        }
        return err
    }
    
    static func WaitForFreeBuffer(_ myData:UnsafeMutablePointer<MyData>) {
        
        
        if (myData.pointee.fillBufferIndex+1 >= streamAudio.kNumAQBufs){
            myData.pointee.fillBufferIndex = 0
        }
        myData.pointee.bytesFilled = 0
        myData.pointee.packetsFilled = 0
        print("->lock")
        pthread_mutex_lock(&myData.pointee.mutex)
        while (myData.pointee.inuse[myData.pointee.fillBufferIndex]) {
            print("...waiting...")
            pthread_cond_wait(&myData.pointee.cond, &myData.pointee.mutex)
        }
        pthread_mutex_unlock(&myData.pointee.mutex)
        print("<-unlock")
    }
    
    
    //    func MyConnectSocket()->Int{
    //
    //        let host = gethostbyname(defaultIp)
    //
    //        guard host != nil else{
    //            print("can't get host")
    //            return -1
    //        }
    //        connection_socket = Int(socket(AF_INET, SOCK_STREAM, 0))
    //        guard connection_socket >= 0 else{
    //            print("can't create socket")
    //            return -1
    //        }
    //
    //        var server_sockaddr = sockaddr_in()
    //
    //        server_sockaddr.sin_family = UInt8(host!.pointee.h_addrtype)
    //        memcpy(&server_sockaddr.sin_addr.s_addr, host!.pointee.h_addr_list[0], Int(host!.pointee.h_length))
    //
    //        server_sockaddr.sin_port = defaultPort.bigEndian
    //
    //        let nsd = NSData.init(bytes: &server_sockaddr, length: MemoryLayout.size(ofValue: server_sockaddr))
    //
    //        let  c1 = nsd.bytes.assumingMemoryBound(to: sockaddr.self)
    //
    //        //        let c1 = exchange(point: &server_sockaddr)
    //
    //        let err = connect(Int32(connection_socket),c1,socklen_t(MemoryLayout.size(ofValue: server_sockaddr)))
    //        guard err == 0 else {
    //            print("connect error")
    //            return -1
    //        }
    //
    //        return Int(connection_socket)
    //    }
    
    //    func exchange(point:UnsafeRawPointer) -> UnsafePointer<sockaddr> {
    //        let x = point.bindMemory(to: sockaddr.self, capacity: MemoryLayout.size(ofValue: sockaddr()))
    //        return x
    //    }
    
    func stop() {
        
        var err:OSStatus
        guard myData.started == true else{
            print("无法暂停")
            return
        }
        
        print("flushing")
        err = AudioQueueFlush(myData.audioQueue!)
        if err != 0  {
            print("AudioQueueFlushError")
        }
        
        print("stopping")
        err = AudioQueueStop(myData.audioQueue!, true)
        if err != 0  {
            print("AudioQueueStopError")
        }
        
        
        print("waiting until finished playing..")
        //        pthread_mutex_lock(&myData.mutex)
        //        pthread_cond_wait(&myData.done, &myData.mutex)
        //        pthread_mutex_unlock(&myData.mutex)
        
        //        err = AudioQueueDispose(myData.audioQueue!, true)
        //        print("AudioQueueDisposeError"+err.description)
        //        
        //        err = AudioFileStreamClose(myData.audioFileStream!)
        //        print("AudioFileStreamCloseError"+err.description)    
        
        self.inputStream?.close()
        self.outputStream?.close()
    }
    
    
    
}
