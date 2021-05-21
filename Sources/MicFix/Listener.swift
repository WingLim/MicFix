//
//  Listener.swift
//  MicFix
//
//  Created by WingLim on 2021/5/14.
//

import CoreAudio
import Foundation


class Listener {
    private var defaultDevice: AudioDeviceID = 0
    private var defaultSize = UInt32(MemoryLayout<AudioDeviceID>.size)
    
    private var dataSourceID: UInt32 = 0
    private var dataSourceSize = UInt32(MemoryLayout<UInt32>.size)
    
    var micfix: MicFix?
    
    private var defaultAddr = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMaster
    )
    private var sourceAddr = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyDataSource,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMaster
    )
    
    init() {
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &defaultAddr, 0, nil, &defaultSize, &defaultDevice)
    }
    
    func listen() {
        print("Starting jack watcher\n")
        
        // Detect jack status when program start listenning
        AudioObjectGetPropertyData(defaultDevice, &sourceAddr, 0, nil, &dataSourceSize, &dataSourceID)
        if dataSourceID == HEADPHONE {
            _ = micfix?.micCheck()
        }
        AudioObjectAddPropertyListenerBlock(defaultDevice, &sourceAddr, .main, outputPropertyListenerBlock)
    }
    
    func outputPropertyListenerBlock(inNumberAddresses: UInt32, inAddresses: UnsafePointer<AudioObjectPropertyAddress>) {
        AudioObjectGetPropertyData(defaultDevice, inAddresses, 0, nil, &dataSourceSize, &dataSourceID)
        
        if dataSourceID == HEADPHONE {
            _ = micfix?.micCheck()
        }
        
        if dataSourceID == SPEAKER {
            _ = micfix?.unplugged()
        }
    }
    
}
