//
//  Sound.swift
//  Tsuccomu
//
//  Created by kazuma maekawa on 2015/11/29.
//  Copyright © 2015年 speechrec. All rights reserved.
//

import UIKit;
import AVFoundation;

class Sound: NSObject {
    
    func playSound()->Void{
        let sound_data = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("test", ofType: "wav")!)
        
        do{
            let audioPlayer: AVAudioPlayer = try AVAudioPlayer(contentsOfURL: sound_data)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            sleep(1)

        }catch let error as NSError {
            print(error)
        }
        
    }
    
}
