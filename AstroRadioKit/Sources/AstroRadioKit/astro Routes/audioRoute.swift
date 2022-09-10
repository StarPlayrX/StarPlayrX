//
//  audioRoute.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/6/22.
//

import Foundation
import SwifterLite

func audioRoute(useBuffer: Bool) -> httpReq {{ request in
    autoreleasepool {
        guard
            let aac  = request.params[":aac"]
        else {
            return HttpResponse.ok(.data(Data(), contentType: ""))
        }
        
        let endpoint = AudioX(data: aac, channelId: userX.channel )
        
        var audio = Data()
        
        dataSync(endpoint: endpoint, method: audioFormat) { (data) in
            autoreleasepool {
                guard
                    let data = data
                else {
                    return
                }
                audio = data
            }
        }
        
        if useBuffer {
            let contentType = ["Content-Type": audioFormat]
            return HttpResponse.raw(200, "OK", contentType, { writer in
                let bufferSize = 1024
                let stream = InputStream(data: audio)
                var buf = [UInt8](repeating: 0, count: bufferSize)
                
                stream.open()
                while case let amount = stream.read(&buf, maxLength: bufferSize), amount > 0 {
                    try writer.write(bytes: [UInt8](buf[..<amount]))
                }
                stream.close()
            })
        } else {
            return HttpResponse.ok(.data(audio, contentType: audioFormat))
        }
    }
}}
