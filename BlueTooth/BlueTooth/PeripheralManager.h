//
//  PeripheralMangerVC.h
//  BlueTooth
//
//  Created by 1512共享 on 16/2/23.
//  Copyright (c) 2016年 shishu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralManager : NSObject
+(id)sharedInstance;
-(void)createAndNotify;
//发送数据
-(void)sendString:(NSString *)string;

@end
