//
//  ViewController.m
//  SelectRobot
//
//  Created by yma on 2016/01/27.
//  Copyright © 2016年 tech01@asra.co.jp. All rights reserved.
//

#import "ViewController.h"



@implementation ViewController

#pragma mark - NSTableView data source
- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    NSLog(@"%s: deviceArray_=<%@>",__func__, deviceArray_);
    NSInteger rows = [deviceArray_ count];
    return rows;
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"%s tableView=<%@>", __func__,tableView);
    NSLog(@"%s tableColumn=<%@>", __func__,tableColumn);
    NSLog(@"%s deviceArray_=<%@>", __func__,deviceArray_);
    
    NSDictionary *dataRow = [deviceArray_ objectAtIndex:row];
    NSLog(@"%s dataRow=<%@>", __func__,dataRow);
    NSString *identifier =[tableColumn identifier];
    NSLog(@"%s identifier=<%@>", __func__,identifier);
    id data =nil;
     
     if ([identifier isEqualToString:@"NAME"]) {
         data = [dataRow objectForKey:@"name"];
     } else if ([identifier isEqualToString:@"MAC"]) {
         data = [dataRow objectForKey:@"mac"];
     } else {
         data = [dataRow objectForKey:@"???"];
     }
    NSLog(@"%s data=<%@>", __func__,data);
    return data;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [_btStatus_ setStringValue:@""];
    deviceArray_ = [[NSMutableArray alloc] init];
    NSLog(@"%s: deviceArray_=<%@>",__func__,deviceArray_);
    
    NSLog(@"%s: btDevices_=<%@>",__func__,_btDevices_);
    [_btDevices_ setDataSource:self];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)findBT:(id)sender {
    NSLog(@"%s: sender=<%@>",__func__,sender);
    [_radioSerial_ setState:NO];
    NSLog(@"%s: sender=<%d>",__func__,[_radioBT_ intValue]);
    if (false == busy_) {
        busy_ = true;
        [self startInquiry ];
    }
}

- (IBAction)btSelect:(id)sender {
    NSLog(@"%s: sender=<%@>",__func__,sender);
    NSInteger selected = [sender selectedRow];
    NSLog(@"%s: selected=<%ld>",__func__,(long)selected);
    NSDictionary *dataRow = [deviceArray_ objectAtIndex:selected];
    NSString *mac = [dataRow objectForKey:@"mac"];
    NSLog(@"%s: mac=<%@>",__func__,mac);
    [self writeBTConfig:mac];
}

- (IBAction)selectSerial:(id)sender {
    NSLog(@"%s: sender=<%@>",__func__,sender);
    [_radioBT_ setState:NO];
    [self stopInquiry ];
    
    NSString *device =[_textSerial_ stringValue];
    NSLog(@"%s: device=<%@>",__func__,device);
    if (false == [[NSFileManager defaultManager] fileExistsAtPath:device]){
        NSString *msg = @"[";
        msg = [msg stringByAppendingString:device];
        msg = [msg stringByAppendingString:@"] "];
        msg = [msg stringByAppendingString:@" NOT exist!!"];
        [self showErrorMessage:msg];
    }
    else {
        [self writeSerialConfig:device];
    }
}







- (void) writeSerialConfig:(NSString*) device{
    NSLog(@"%s: device=<%@>",__func__,device);
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc] init];
    [mdic setObject:device forKey:@"port"];
    [mdic setObject:@"115200" forKey:@"baudrate"];
    [self writeConfig:mdic];
}
- (void) writeBTConfig:(NSString*) mac{
    NSLog(@"%s: mac=<%@>",__func__,mac);
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc] init];
    mac = [mac stringByReplacingOccurrencesOfString:@"-" withString:@":" ];
    [mdic setObject:mac forKey:@"device"];
    [self writeConfig:mdic];
}

- (void ) writeConfig:(NSMutableDictionary*)config
{
    NSString *configStr = [NSString stringWithFormat:@"%@", config];
    
    NSString * path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByDeletingLastPathComponent ];
    NSLog(@"path=<%@>",  path);
    
    NSString *serialFilePath = [path stringByAppendingString:@"/usr/etc/serial"];
    
    if([NSJSONSerialization isValidJSONObject:config]){
        NSError *error;
        NSData *json = [NSJSONSerialization dataWithJSONObject:config    options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSString *msg = @"[";
            msg = [msg stringByAppendingString:configStr];
            msg = [msg stringByAppendingString:@"] "];
            msg = [msg stringByAppendingString:@" Internal Error!!"];
            [self showErrorMessage:msg];
            return;
        }
        NSString *jsonStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        NSLog(@"jsonStr=<%@>",  jsonStr);
        [jsonStr writeToFile:serialFilePath
                   atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSString *msg = @"can not write [";
            msg = [msg stringByAppendingString:configStr];
            msg = [msg stringByAppendingString:@"] "];
            msg = [msg stringByAppendingString:@" to file ["];
            msg = [msg stringByAppendingString:serialFilePath];
            msg = [msg stringByAppendingString:@"]!!"];
            [self showErrorMessage:msg];
            return;
        } else {
            NSString *msg = @"Save Setting Sucess";
            [self showErrorMessage:msg];
            
        }
    } else {
        NSString *msg = @"[";
        msg = [msg stringByAppendingString:configStr];
        msg = [msg stringByAppendingString:@"] "];
        msg = [msg stringByAppendingString:@" Internal Error!!"];
        [self showErrorMessage:msg];
    }
}
- (void) showErrorMessage:(NSString*)msg
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:msg];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

//===========================================================================================================================
// startInquiry
//===========================================================================================================================

-(IOReturn)startInquiry
{
    IOReturn	status;
    
    [self	stopInquiry];
    
    _inquiry = [IOBluetoothDeviceInquiry	inquiryWithDelegate:self];
    
    status = [_inquiry	start];
    if( status == kIOReturnSuccess )
    {
        NSLog(@"%s: _inquiry=<%@>",__func__,_inquiry);
    }
    else
    {
    }
    
    return( status );
}

//===========================================================================================================================
// stopInquiry
//===========================================================================================================================
- (IOReturn) stopInquiry
{
    IOReturn ret = kIOReturnNotOpen;
    
    if( _inquiry )
    {
        ret = [_inquiry stop];
        _inquiry = nil;
    }
    
    busy_ = false;
    return ret;
}

//===========================================================================================================================
// deviceInquiryStarted
//===========================================================================================================================

- (void)	deviceInquiryStarted:(IOBluetoothDeviceInquiry*)sender
{
    NSLog(@"%s: _inquiry=<%@>",__func__,@"Finding...");
    [_btStatus_ setStringValue:@"Finding..."];
    [deviceArray_ removeAllObjects];
    [_btDevices_ reloadData];
}

//===========================================================================================================================
// deviceInquiryDeviceFound
//===========================================================================================================================

- (void)	deviceInquiryDeviceFound:(IOBluetoothDeviceInquiry*)sender	device:(IOBluetoothDevice*)device
{
//    NSLog(@"%s: device=<%@>",__func__,device);
    NSString *name = device.name;
    NSString *mac = device.addressString;
    NSLog(@"%s: name=<%@>",__func__,name);
    NSLog(@"%s: mac=<%@>",__func__,mac);

    NSDictionary *data = @{@"name":name,@"mac":mac};
    [deviceArray_ addObject:data];
    [_btDevices_ reloadData];
}

//===========================================================================================================================
// deviceInquiryComplete
//===========================================================================================================================

- (void)	deviceInquiryComplete:(IOBluetoothDeviceInquiry*)sender	error:(IOReturn)error	aborted:(BOOL)aborted
{
    if( aborted )
    {
    }
    else
    {
    }
    [_btStatus_ setStringValue:@"Complete"];
    busy_ = FALSE;
}



@end
