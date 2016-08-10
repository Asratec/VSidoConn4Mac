//
//  ViewController.h
//  SelectRobot
//
//  Created by yma on 2016/01/27.
//  Copyright © 2016年 tech01@asra.co.jp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetoothUserLib.h>
#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothDeviceInquiry.h>


@interface ViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
    NSMutableArray *deviceArray_;
    bool busy_;

    IOBluetoothDeviceInquiry *_inquiry;
}

- (IBAction)findBT:(id)sender;
@property (strong) IBOutlet NSButton *radioBT_;
@property (strong) IBOutlet NSTextField *btStatus_;
@property (strong) IBOutlet NSTableView *btDevices_;
- (IBAction)btSelect:(id)sender;

- (IBAction)selectSerial:(id)sender;
@property (strong) IBOutlet NSButton *radioSerial_;
@property (strong) IBOutlet NSTextField *textSerial_;
@end

