//
//  MicFix.swift
//  MicFix
//
//  Created by WingLim on 2021/5/14.
//

import Foundation


class MicFix {
    let listener = Listener()
    var ALCVerbIOService: io_service_t = 0
    var codecID = ""
    var subVendor = ""
    var subDevice = ""
    var DataConnection: io_connect_t = 0

    func start() {
        var iterator: io_iterator_t = 0
        IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(ALCVERB_PROVIDER), &iterator)
        
        repeat {
            ALCVerbIOService = IOIteratorNext(iterator)
            getAudioID()
            guard ALCVerbIOService != 0 else {
                print("Provider \(ALCVERB_PROVIDER) not available!")
                exit(1)
            }
        } while !SUPPORTED_DEVICES.contains(codecID)
        
        print(String(format: "CodecID: %@\n", codecID))
        
        openServiceConnection()
        
        if !SUPPORTED_DEVICES.contains(codecID) {
            print("No compatible audio device found! Exit now.\n")
            exit(1)
        }
        
        alcInit()
        
        listener.micfix = self
        listener.listen()
    }
    
    /// Open connection to IOService
    private func openServiceConnection() {
        guard kIOReturnSuccess == IOServiceOpen(ALCVerbIOService, mach_task_self_, 0, &DataConnection),
              DataConnection != 0 else {
            print("Failed to connect to ALCUserClientProvider")
            exit(1)
        }
    }

    
    /// Send verb command
    /// - Parameter command: verb command
    /// - Returns: execute output
    private func sendHdaVerb(_ command: UInt32) -> Int32 {
        let nid = command >> 20
        let verb = (command >> 8) & 0xFFF
        let param = command & 0xFF
        
        var input: [UInt64] = [
            UInt64(nid),
            UInt64(verb),
            UInt64(param)
        ]
        
        var outputCount: UInt32 = 1
        var output: UInt64 = 0
        
        if kIOReturnSuccess != IOConnectCallScalarMethod(DataConnection, 0, &input, 3, &output, &outputCount) {
            print("Failed to execute HDA verb\n")
            return -1
        }
        
        // print(String(format: "%x, %x, %llx", arguments: [nid, verb, output]))
        
        return Int32(output)
    }
    
    
    /// Get onboard audio device info
    private func getAudioID() {
        var HDACodecDevIOService: io_service_t = 0
        var HDACtrlIOService: io_service_t = 0
        var pciDevIOService: io_service_t = 0
        
        
        IORegistryEntryGetParentEntry(ALCVerbIOService, kIOServicePlane, &HDACodecDevIOService) //IOHDACodecDevice
        IORegistryEntryGetParentEntry(HDACodecDevIOService, kIOServicePlane, &HDACtrlIOService) //AppleHDAController
        IORegistryEntryGetParentEntry(HDACtrlIOService, kIOServicePlane, &pciDevIOService)      //HDEF
        
        let codecID_raw: CFNumber = IORegistryEntrySearchCFProperty(
            HDACodecDevIOService,
            kIOServicePlane,
            "IOHDACodecVendorID" as CFString,
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)) as! CFNumber
        var num = 0
        CFNumberGetValue(codecID_raw, CFNumberType.intType, &num)
        codecID = String(format: "0x%02x", num)
        
        let subVendor_raw: CFData = IORegistryEntrySearchCFProperty(
            pciDevIOService,
            kIOServicePlane,
            "subsystem-vendor-id" as CFString,
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)) as! CFData
        subVendor = getCFDataString(data: subVendor_raw)
        
        let subDevice_raw: CFData = IORegistryEntrySearchCFProperty(
            pciDevIOService,
            kIOServicePlane,
            "subsystem-id" as CFString,
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively)) as! CFData
        subDevice = getCFDataString(data: subDevice_raw)
        
        // print("CodecID: ", codecID)
        // print("subVendor: ", subVendor)
        // print("subDevice: ", subDevice)
        
        IOObjectRelease(HDACodecDevIOService)
        IOObjectRelease(HDACtrlIOService)
        IOObjectRelease(pciDevIOService)
    }
    
    
    /// Convert CFData to Hex string
    /// - Parameter data: CFData
    /// - Returns: String with Hex format
    private func getCFDataString(data: CFData) -> String {
        let n = CFDataGetLength(data)
        var buffer = [UInt8](repeating: 0, count: n)
        CFDataGetBytes(data, CFRangeMake(0, n), &buffer)
        var res = ""
        for num in buffer.reversed() {
            if num == 0 {
                continue
            }
            res = String(format: "0x%02x", num)
        }
        return res
    }
    
    
    /// Codec fixup, invoked when boot/wake
    private func alcInit() {
        print("Init codec\n")
        switch codecID {
        case ALC255:
            _ = sendHdaVerb(HDAVerb(nid: 0x19, verb: SET_PIN_WIDGET_CONTROL, param: 0x24))
            _ = sendHdaVerb(HDAVerb(nid: 0x1a, verb: SET_PIN_WIDGET_CONTROL, param: 0x20))
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_UNSOLICITED_ENABLE, param: 0x83))
        default: break
        }
    }
    
    private func alcReadCoef(idx: UInt32) -> Int32 {
        return alcReadCoefEX(nid: REALTEK_VENDOR_REGISTERS, idx: idx)
    }
    
    private func alcReadCoefEX(nid: UInt32, idx: UInt32) -> Int32 {
        var val: Int32 = 0
        
        _ = sendHdaVerb(HDAVerb(nid: nid, verb: SET_COEF_INDEX, param: idx))
        val = sendHdaVerb(HDAVerb(nid: nid, verb: GET_PROC_COEF, param: idx))
        
        return val
    }
    
    private func alcWriteCoef(idx: UInt32, value: UInt32) {
        alcWriteCoefEX(nid: REALTEK_VENDOR_REGISTERS, idx: idx, value: value)
    }
    
    private func alcWriteCoefEX(nid: UInt32, idx: UInt32, value: UInt32) {
        _ = sendHdaVerb(HDAVerb(nid: nid, verb: SET_COEF_INDEX, param: idx))
        _ = sendHdaVerb(HDAVerb(nid: nid, verb: SET_PROC_COEF, param: value))
    }
    
    private func alcUpdateCoef(idx: UInt32, mask: Int32, value: UInt32) {
        alcUpdateCoefEX(nid: REALTEK_VENDOR_REGISTERS, index: idx, mask: mask, value: value)
    }
    
    private func alcUpdateCoefEX(nid: UInt32, index: UInt32, mask: Int32, value: UInt32) {
        let val = alcReadCoefEX(nid: nid, idx: index)
        let tmp = Int32(value)
        
        if val != -1 {
            alcWriteCoefEX(nid: nid, idx: index, value: UInt32((val & ~mask) | tmp))
        }
    }
    
    private func alcProcessCoef(coefArray: [coef]) {
        for item in coefArray {
            if item.mask == -1 {
                alcWriteCoefEX(nid: item.nid, idx: item.idx, value: item.val)
            } else {
                alcUpdateCoefEX(nid: item.nid, index: item.idx, mask: item.mask, value: item.val)
            }
        }
    }
    
    /// Mic: CTIA (iPhone-style plug)
    private func micCTIA() {
        print("Jack Status: headset (CTIA/iPhone) plugged in.\n")
        var val: Int32 = 0
        
        let coef0255: [coef] = [
            writeCoef(0x45, 0xd489),
            writeCoef(0x1b, 0x0c2b),
            writeCoefEX(0x57, 0x03, 0x8ea6)
        ]
        
        let coef0256: [coef] = [
            writeCoef(0x45, 0xd489),
            writeCoef(0x1b, 0x0e6b)
        ]
        
        let coef0288: [coef] = [
            updateCoef(0x50, 0x2000, 0x2000),
            updateCoef(0x56, 0x0006, 0x0006),
            updateCoef(0x66, 0x0008, 0),
            updateCoef(0x67, 0x2000, 0)
        ]
        
        switch codecID {
        case ALC255:
            // Comes from https://github.com/torvalds/linux/blob/63d1cb53e26a9a4168b84a8981b225c0a9cfa235/sound/pci/hda/patch_realtek.c#L5026
            alcProcessCoef(coefArray: coef0255)
        case ALC236, ALC256:
            alcProcessCoef(coefArray: coef0256)
        case ALC286, ALC288:
            alcUpdateCoef(idx: 0x4f, mask: 0xfcc0, value: 0xd400)
            usleep(300000)
            alcProcessCoef(coefArray: coef0288)
        case ALC298:
            val = alcReadCoef(idx: 0x50)
            if (val & (1 << 12)) != 0 {
                alcUpdateCoef(idx: 0x8e, mask: 0x0070, value: 0x0020)
                alcUpdateCoef(idx: 0x4f, mask: 0xfcc0, value: 0xd400)
                usleep(300000)
            } else {
                alcUpdateCoef(idx: 0x8e, mask: 0x0070, value: 0x0010)
                alcUpdateCoef(idx: 0x4f, mask: 0xfcc0, value: 0xd400)
                usleep(300000)
            }
        default: break
        }
    }
    
    
    /// Mic: OMTP (Nokia-style plug)
    private func micOMTP() {
        print("Jack Status: headset (OMTP/Nokia) plugged in.\n")
        
        let coef0255: [coef] = [
            writeCoef(0x45, 0xe489),
            writeCoef(0x1b, 0x0c2b),
            writeCoefEX(0x57, 0x03, 0x8ea6)
        ]
        
        let coef0256: [coef] = [
            writeCoef(0x45, 0xe489),
            writeCoef(0x1b, 0x0e6b)
        ]
        
        let coef0288: [coef] = [
            updateCoef(0x50, 0x2000, 0x2000),
            updateCoef(0x56, 0x0006, 0x0006),
            updateCoef(0x66, 0x0008, 0),
            updateCoef(0x67, 0x2000, 0)
        ]
        
        switch codecID {
        case ALC255:
            // Comes from https://github.com/torvalds/linux/blob/63d1cb53e26a9a4168b84a8981b225c0a9cfa235/sound/pci/hda/patch_realtek.c#L5144
            alcProcessCoef(coefArray: coef0255)
        case ALC236, ALC256:
            alcProcessCoef(coefArray: coef0256)
        case ALC286, ALC288:
            alcUpdateCoef(idx: 0x4f, mask: 0xfcc0, value: 0xe400)
            usleep(300000)
            alcProcessCoef(coefArray: coef0288)
        case ALC298:
            alcUpdateCoef(idx: 0x8e, mask: 0x0070, value: 0x0010)
            alcUpdateCoef(idx: 0x4f, mask: 0xfcc0, value: 0xe400)
            usleep(300000)
        default: break
        }
    }
    
    
    /// Mic Auto-Detection (CTIA/OMTP)
    func micCheck() {
        print("Jack Status: headset plugged in. Checking type...\n")
        var isCTIA = false
        var val: Int32 = 0
        
        let coef0255: [coef] = [
            writeCoef(0x45, 0x0d089),
            writeCoef(0x49, 0x0149)
        ]
        
        let coef0288: [coef] = [
            updateCoef(0x4f, 0xfcc0, 0xd400)
        ]
        
        let coef0298: [coef] = [
            updateCoef(0x50, 0x2000, 0x2000),
            updateCoef(0x56, 0x0006, 0x0006),
            updateCoef(0x66, 0x0008, 0),
            updateCoef(0x67, 0x2000, 0),
            updateCoef(0x19, 0x1300, 0x1300)
        ]
        
        switch codecID {
        case ALC255:
            alcProcessCoef(coefArray: coef0255)
            usleep(350000)
            val = alcReadCoef(idx: 0x46)
            isCTIA = (val & 0x0070) == 0x0070
        case ALC236, ALC256:
            alcWriteCoef(idx: 0x1b, value: 0x0e4b)
            alcWriteCoef(idx: 0x06, value: 0x6104)
            alcWriteCoefEX(nid: 0x57, idx: 0x3, value: 0x09a3)
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_AMP_GAIN_MUTE, param: AMP_OUT_MUTE))
            usleep(80000)
            
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_PIN_WIDGET_CONTROL, param: 0x0))
            alcProcessCoef(coefArray: coef0255)
            usleep(350000)
            val = alcReadCoef(idx: 0x46)
            isCTIA = (val & 0x0070) == 0x0070
            
            alcWriteCoefEX(nid: 0x57, idx: 0x3, value: 0x0da3)
            alcUpdateCoefEX(nid: 0x57, index: 0x5, mask: 1<<14, value: 0)
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_PIN_WIDGET_CONTROL, param: PIN_OUT))
            usleep(80000)
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_AMP_GAIN_MUTE, param: AMP_OUT_UNMUTE))
        case ALC286, ALC288:
            alcProcessCoef(coefArray: coef0288)
            usleep(350000)
            val = alcReadCoef(idx: 0x50)
            isCTIA = (val & 0x0070) == 0x0070
        case ALC298:
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_AMP_GAIN_MUTE, param: AMP_OUT_MUTE))
            usleep(100000)
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_PIN_WIDGET_CONTROL, param: 0x0))
            usleep(200000)
            
            val = alcReadCoef(idx: 0x50)
            if (val & (1 << 12)) != 0 {
                alcUpdateCoef(idx: 0x8e, mask: 0x0070, value: 0x0020)
                alcProcessCoef(coefArray: coef0288)
                usleep(350000)
                val = alcReadCoef(idx: 0x50)
                isCTIA = (val & 0x0070) == 0x0070
            } else {
                alcUpdateCoef(idx: 0x8e, mask: 0x0070, value: 0x0010)
                alcProcessCoef(coefArray: coef0288)
                usleep(350000)
                val = alcReadCoef(idx: 0x50)
                isCTIA = (val & 0x0070) == 0x0070
            }
            alcProcessCoef(coefArray: coef0298)
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_PIN_WIDGET_CONTROL, param: PIN_HP))
            usleep(75000)
            _ = sendHdaVerb(HDAVerb(nid: 0x21, verb: SET_AMP_GAIN_MUTE, param: AMP_OUT_UNMUTE))
        default: break
        }
        
        if isCTIA {
            micCTIA()
        } else {
            micOMTP()
        }
    }
    
    
    /// Unplugged Settings
    func unplugged() {
        print("Jack Status: unplugged.\n")
        
        let coef0255: [coef] = [
            writeCoef(0x1b, 0x0c0b),
            writeCoef(0x45, 0x0d089),
            updateCoefEX(0x57, 0x05, 1<<14, 0),
            writeCoef(0x06, 0x06104),
            writeCoefEX(0x57, 0x03, 0x8aa6)
        ]
        
        let coef0256: [coef] = [
            writeCoef(0x1b, 0x0c4b),
            writeCoef(0x45, 0xd089),
            writeCoef(0x06, 0x6104),
            writeCoefEX(0x57, 0x03, 0x09a3),
            updateCoefEX(0x57, 0x05, 1<<14, 0)
        ]
        
        let coef0288: [coef] = [
            updateCoef(0x4f, 0xfcc0, 0xc400),
            updateCoef(0x50, 0x2000, 0x2000),
            updateCoef(0x56, 0x0006, 0x0006),
            updateCoef(0x66, 0x0008, 0),
            updateCoef(0x67, 0x2000, 0)
        ]
        
        let coef0298: [coef] = [
            updateCoef(0x19, 0x1300, 0x0300)
        ]
        
        switch codecID {
        case ALC255:
            alcProcessCoef(coefArray: coef0255)
        case ALC236, ALC256:
            alcProcessCoef(coefArray: coef0256)
        case ALC286, ALC288:
            alcProcessCoef(coefArray: coef0288)
        case ALC298:
            alcProcessCoef(coefArray: coef0298)
            alcProcessCoef(coefArray: coef0288)
        default: break
        }
    }
}
