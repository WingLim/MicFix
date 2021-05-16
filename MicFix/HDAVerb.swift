//
//  HDAVerb.swift
//  MicFix
//
//  Created by WingLim on 2021/5/15.
//

import Foundation

struct coef {
    var nid: UInt32 = 0
    var idx: UInt32 = 0
    var mask: Int32 = -1
    var val: UInt32 = 0
}

func updateCoefEX(_ nid: UInt32, _ idx: UInt32, _ mask: Int32, _ val: UInt32) -> coef {
    return coef(nid: nid, idx: idx, mask: mask, val: val)
}

func writeCoefEX(_ nid: UInt32, _ idx: UInt32, _ val: UInt32) -> coef {
    return updateCoefEX(nid, idx, -1, val)
}

func updateCoef(_ idx: UInt32, _ mask: Int32, _ val: UInt32) -> coef {
    return updateCoefEX(REALTEK_VENDOR_REGISTERS, idx, mask, val)
}

func writeCoef(_ idx: UInt32, _ val: UInt32) -> coef {
    return writeCoefEX(REALTEK_VENDOR_REGISTERS, idx, val)
}

func HDAVerb(_ nid: UInt32, _ verb: UInt32, _ param: UInt32) -> UInt32 {
    return nid << 20 | verb << 8 | param
}
