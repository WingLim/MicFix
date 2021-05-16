//
//  Constants.swift
//  MicFix
//
//  Created by WingLim on 2021/5/14.
//

import Foundation

// HDAVerbs
//GET
let GET_STREAM_FORMAT: UInt32             =   0x0a00
let GET_AMP_GAIN_MUTE: UInt32             =   0x0b00
let GET_PROC_COEF: UInt32                 =   0x0c00
let GET_COEF_INDEX: UInt32                =   0x0d00
let PARAMETERS: UInt32                    =   0x0f00
let GET_CONNECT_SEL: UInt32               =   0x0f01
let GET_CONNECT_LIST: UInt32              =   0x0f02
let GET_PROC_STATE: UInt32                =   0x0f03
let GET_SDI_SELECT: UInt32                =   0x0f04
let GET_POWER_STATE: UInt32               =   0x0f05
let GET_CONV: UInt32                      =   0x0f06
let GET_PIN_WIDGET_CONTROL: UInt32        =   0x0f07
let GET_UNSOLICITED_RESPONSE: UInt32      =   0x0f08
let GET_PIN_SENSE: UInt32                 =   0x0f09
let GET_BEEP_CONTROL: UInt32              =   0x0f0a
let GET_EAPD_BTLENABLE: UInt32            =   0x0f0c
let GET_DIGI_CONVERT_1: UInt32            =   0x0f0d
let GET_DIGI_CONVERT_2: UInt32            =   0x0f0e
let GET_VOLUME_KNOB_CONTROL: UInt32       =   0x0f0f
let GET_GPIO_DATA: UInt32                 =   0x0f15
let GET_GPIO_MASK: UInt32                 =   0x0f16
let GET_GPIO_DIRECTION: UInt32            =   0x0f17
let GET_GPIO_WAKE_MASK: UInt32            =   0x0f18
let GET_GPIO_UNSOLICITED_RSP_MASK: UInt32 =   0x0f19
let GET_GPIO_STICKY_MASK: UInt32          =   0x0f1a
let GET_CONFIG_DEFAULT: UInt32            =   0x0f1c
let GET_SUBSYSTEM_ID: UInt32              =   0x0f20

// SET
let SET_STREAM_FORMAT: UInt32             =   0x200
let SET_AMP_GAIN_MUTE: UInt32             =   0x300
let SET_PROC_COEF: UInt32                 =   0x400
let SET_COEF_INDEX: UInt32                =   0x500
let SET_CONNECT_SEL: UInt32               =   0x701
let SET_PROC_STATE: UInt32                =   0x703
let SET_SDI_SELECT: UInt32                =   0x704
let SET_POWER_STATE: UInt32               =   0x705
let SET_CHANNEL_STREAMID: UInt32          =   0x706
let SET_PIN_WIDGET_CONTROL: UInt32        =   0x707
let SET_UNSOLICITED_ENABLE: UInt32        =   0x708
let SET_PIN_SENSE: UInt32                 =   0x709
let SET_BEEP_CONTROL: UInt32              =   0x70a
let SET_EAPD_BTLENABLE: UInt32            =   0x70c
let SET_DIGI_CONVERT_1: UInt32            =   0x70d
let SET_DIGI_CONVERT_2: UInt32            =   0x70e
let SET_VOLUME_KNOB_CONTROL: UInt32       =   0x70f
let SET_GPIO_DATA: UInt32                 =   0x715
let SET_GPIO_MASK: UInt32                 =   0x716
let SET_GPIO_DIRECTION: UInt32            =   0x717
let SET_GPIO_WAKE_MASK: UInt32            =   0x718
let SET_GPIO_UNSOLICITED_RSP_MASK: UInt32 =   0x719
let SET_GPIO_STICKY_MASK: UInt32          =   0x71a
let SET_CONFIG_DEFAULT_BYTES_0: UInt32    =   0x71c
let SET_CONFIG_DEFAULT_BYTES_1: UInt32    =   0x71d
let SET_CONFIG_DEFAULT_BYTES_2: UInt32    =   0x71e
let SET_CONFIG_DEFAULT_BYTES_3: UInt32    =   0x71f
let SET_CODEC_RESET: UInt32               =   0x7ff

// AMP values
let AMP_OUT_MUTE: UInt32 = 0xb080
let AMP_OUT_UNMUTE: UInt32 = 0xb000

// Pin widget control - 8bit
let AC_PINCTL_EPT: UInt32         =     (0x3<<0)
let AC_PINCTL_EPT_NATIVE: UInt32  =     0
let AC_PINCTL_EPT_HBR: UInt32     =     3
let AC_PINCTL_VREFEN: UInt32      =     (0x7<<0)
let AC_PINCTL_VREF_HIZ: UInt32    =     0    /* Hi-Z */
let AC_PINCTL_VREF_50: UInt32     =     1    /* 50% */
let AC_PINCTL_VREF_GRD: UInt32    =     2    /* ground */
let AC_PINCTL_VREF_80: UInt32     =     4    /* 80% */
let AC_PINCTL_VREF_100: UInt32    =     5    /* 100% */
let AC_PINCTL_IN_EN: UInt32       =     (1<<5)
let AC_PINCTL_OUT_EN: UInt32      =     (1<<6)
let AC_PINCTL_HP_EN: UInt32       =     (1<<7)

// Pinctl values
let PIN_IN: UInt32       =      (AC_PINCTL_IN_EN)
let PIN_VREFHIZ: UInt32  =      (AC_PINCTL_IN_EN | AC_PINCTL_VREF_HIZ)
let PIN_VREF50: UInt32   =      (AC_PINCTL_IN_EN | AC_PINCTL_VREF_50)
let PIN_VREFGRD: UInt32  =      (AC_PINCTL_IN_EN | AC_PINCTL_VREF_GRD)
let PIN_VREF80: UInt32   =      (AC_PINCTL_IN_EN | AC_PINCTL_VREF_80)
let PIN_VREF100: UInt32  =      (AC_PINCTL_IN_EN | AC_PINCTL_VREF_100)
let PIN_OUT: UInt32      =      (AC_PINCTL_OUT_EN)
let PIN_HP: UInt32       =      (AC_PINCTL_OUT_EN | AC_PINCTL_HP_EN)
let PIN_HP_AMP: UInt32   =      (AC_PINCTL_HP_EN)

let ALCVERB_PROVIDER = "ALCUserClientProvider"

let REALTEK_VENDOR_REGISTERS: UInt32 = 0x20

// Devices Values
let ALC236 = "0x10ec0236"
let ALC255 = "0x10ec0255"
let ALC256 = "0x10ec0256"

let SUPPORTED_DEVICES = [ALC236, ALC255, ALC256]

let HEADPHONE = 1751412846
let SPEAKER = 1769173099
