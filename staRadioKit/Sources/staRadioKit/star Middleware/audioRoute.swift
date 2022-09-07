//
//  audioRoute.swift
//  StarPlayrRadioApp
//
//  Created by Todd Bruss on 9/6/22.
//

import Foundation

func audioRoute() -> ((HttpRequest) -> HttpResponse) {
    return { request in
        
        autoreleasepool {
            guard
                let aac  = request.params[":aac"]
            else {
                return HttpResponse.ok(.data(Data(), contentType: ""))
            }
            
            let endpoint = AudioX(data: aac, channelId: userX.channel )
            
            var audio = Data()
            
            //MARK: Call back
            dataSync(endpoint: endpoint, method: "AAC") { (data) in
                
                autoreleasepool {
                    guard
                        let data = data
                    else {
                        return
                    }
                    
                    audio = data
                }
            
            }
            
            return HttpResponse.ok(.data(audio, contentType: "audio/aac"))
            
            //we match the bitrate so this should keep up just fine
            
            //getting skips in the sounds - bah hum bug
//            let contentType = ["Content-Type": "audio/aac"]
//            return HttpResponse.raw(200, "OK", contentType, { writer in
//                let bufferSize = 4096
//                let stream = InputStream(data: audio)
//                var buf = [UInt8](repeating: 0, count: bufferSize)
//
//                stream.open()
//                while case let amount = stream.read(&buf, maxLength: bufferSize), amount > 0 {
//                    try writer.write(buf[..<amount])
//                }
//                stream.close()
//            })
        }
        
    }
}
