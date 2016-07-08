//
//  CentralManagerVC.h
//  BlueTooth
//
//  Created by 1512共享 on 16/2/23.
//  Copyright (c) 2016年 shishu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CentralManager : NSObject
+(id)sharedInstance;
//开始创建对象和扫描
-(void)startCreateAndScan;

@property (nonatomic, copy) void (^recivData)(NSData * data);
@end
