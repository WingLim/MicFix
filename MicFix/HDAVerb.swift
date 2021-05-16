//
//  HDAVerb.swift
//  MicFix
//
//  Created by WingLim on 2021/5/15.
//

import Foundation

func HDAVerb(nid: UInt32, verb: UInt32, param: UInt32) -> UInt32 {
    return nid << 20 | verb << 8 | param
}
