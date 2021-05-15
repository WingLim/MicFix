//
//  ComboJack.swift
//  ComboJack-Swift
//
//  Created by WingLim on 2021/5/14.
//

import Foundation


class ComboJack {
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
        
        openServiceConnection()
        
        if !SUPPORTED_DEVICES.contains(codecID) {
            print("No compatible audio device found! Exit now.\n")
            exit(1)
        }
        
        alcInit()
        
        listener.combojack = self
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
    private func sendHdaVerb(_ command: UInt32) -> UInt32 {
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
            return 1
        }
        
        // print(String(format: "%x, %x, %llx", arguments: [nid, verb, output]))
        
        return UInt32(output)
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
    
    private func updateCoefEX(nid: UInt32, index: UInt32, value: UInt32) -> Int32 {
        var setCoefIndex = HDAVerbIOCtl()
        var getProcCoef = HDAVerbIOCtl()
        var setProcCoef = HDAVerbIOCtl()
        
        setCoefIndex.verb = HDAVerb(nid: nid, verb: SET_COEF_INDEX, param: index)
        setCoefIndex.res = sendHdaVerb(setCoefIndex.verb)
        if setCoefIndex.res != 0 {
            print("Received weird response.")
            return -1
        }
        
        getProcCoef.verb = HDAVerb(nid: nid, verb: GET_PROC_COEF, param: 0x00)
        getProcCoef.res = sendHdaVerb(getProcCoef.verb)
        
        if value != getProcCoef.res {
            setCoefIndex.res = sendHdaVerb(setCoefIndex.verb)
            
            setProcCoef.verb = HDAVerb(nid: nid, verb: SET_PROC_COEF, param: value)
            setProcCoef.res = sendHdaVerb(setProcCoef.verb)
            if setProcCoef.res != 0 {
                print("Received strange response")
                return -1
            }
        }
        
        setCoefIndex.res = sendHdaVerb(setCoefIndex.verb)
        getProcCoef.res = sendHdaVerb(getProcCoef.verb)
        
        return Int32(getProcCoef.res)
    }
    
    private func writeCoefEX(nid: UInt32, idx: UInt32, value: UInt32) -> Int32 {
        return updateCoefEX(nid: nid, index: idx, value: value)
    }
    
    private func writeCoef(idx: UInt32, value: UInt32) -> Int32 {
        return writeCoefEX(nid: UInt32(REALTEK_VENDOR_REGISTERS), idx: idx, value: value)
    }
    
    /// Headset: CTIA (iPhone-style plug)
    private func headsetCTIA() {
        print("Jack Status: headset (CTIA/iPhone) plugged in.\n")
        
        switch codecID {
        case ALC255:
            _ = writeCoef(idx: 0x45, value: 0xd489)
            _ = writeCoef(idx: 0x1b, value: 0x0c2b)
            _ = writeCoefEX(nid: 0x57, idx: 0x03, value: 0x8ea6)
        default: break
        }
    }
    
    
    /// Headset: OMTP (Nokia-style plug)
    private func headsetOMTP() {
        print("Jack Status: headset (OMTP/Nokia) plugged in.\n")
        switch codecID {
        case ALC255:
            _ = writeCoef(idx: 0x45, value: 0xe489)
            _ = writeCoef(idx: 0x1b, value: 0x0c2b)
            _ = writeCoefEX(nid: 0x57, idx: 0x03, value: 0x8ea6)
        default: break
        }
    }
    
    
    /// Headset Auto-Detection (CTIA/OMTP)
    func headSetCheck() {
        print("Jack Status: headset plugged in. Checking type...\n")
        var setCoefIndex = HDAVerbIOCtl()
        var getProcCoef = HDAVerbIOCtl()
        
        let nid = REALTEK_VENDOR_REGISTERS
        
        switch codecID {
        case ALC255:
            _ = sendHdaVerb(HDAVerb(nid: 0x19, verb: SET_PIN_WIDGET_CONTROL, param: 0x24))
            _ = writeCoef(idx: 0x45, value: 0xd089)
            _ = writeCoef(idx: 0x49, value: 0x0149)
            usleep(350000)
            setCoefIndex.verb = HDAVerb(nid: nid, verb: SET_COEF_INDEX, param: 0x46)
            setCoefIndex.res = sendHdaVerb(setCoefIndex.verb)
            getProcCoef.verb = HDAVerb(nid: nid, verb: GET_PROC_COEF, param: 0x46)
            getProcCoef.res = sendHdaVerb(getProcCoef.verb)
        default: break
        }
        
        if getProcCoef.res & 0x0070 == 0x0070 {
            headsetCTIA()
        } else {
            headsetOMTP()
        }
    }
    
    
    /// Unplugged Settings
    func unplugged() {
        print("Jack Status: unplugged.\n")
        switch codecID {
        case ALC255:
            _ = writeCoef(idx: 0x1b, value: 0x0c0b)
            _ = writeCoef(idx: 0x45, value: 0xd089)
            _ = updateCoefEX(nid: 0x57, index: 0x05, value: 0)
            _ = writeCoef(idx: 0x06, value: 0x6104)
            _ = writeCoefEX(nid: 0x57, idx: 0x03, value: 0x8aa6)
        default: break
        }
    }
}
