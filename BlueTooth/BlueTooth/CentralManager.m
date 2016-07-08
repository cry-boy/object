//
//  CentralManagerVC.m
//  BlueTooth
//
//  Created by 1512共享 on 16/2/23.
//  Copyright (c) 2016年 shishu. All rights reserved.
//

#import "CentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define TRANSFER_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"

//对方的账号
#define TRANSFER_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"

@interface CentralManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *manager;
    NSMutableArray *_dicoveredPeripherals;
    CBPeripheral *_testPeripheral;
}

@end

@implementation CentralManager

//1.建立中心角色
//2.扫描外设（discover)
//3.连接外设(connect)
//4.扫描外设中的服务和特征(discover)
//5.与外设做数据交互(explore and interact)
//6.断开连接(disconnect)。

+(id)sharedInstance
{
    static id instance = nil;
    if(instance == nil)
    {
        instance = [[self alloc] init];
        
    }
    return instance;
}

//
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // CBCentralManagerStatePoweredOn = 5
    NSLog(@"state = %ld",central.state);
}

#pragma mark - 扫描和扫描事件处理

-(void)startCreateAndScan
{
    //创建中心设备对象
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    //开始扫描外设
    //options中的意思是否允许中央设备多次收到曾经监听到的设备的消息，这样来监听外围设备联接的信号强度，以决定是否增大广播强度，为YES时会多耗电
    _dicoveredPeripherals = [[NSMutableArray alloc] init];
    
    //扫描
    [manager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
    
    NSLog(@"开始扫描");
}

//发现周边设备时执行
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if(![_dicoveredPeripherals containsObject:peripheral])
        [_dicoveredPeripherals addObject:peripheral];
    
    NSLog(@"dicoveredPeripherals:%@", _dicoveredPeripherals);
    //<CBPeripheral: 0x1780ad800 identifier = 20B955DC-119F-CD1E-3458-2563E9496F54, Name = \"(null)\", state = disconnected>"
    
    //选择需要的设备，发起链接
    [self connect:peripheral];
    
}

#pragma mark - 连接操作
//连接指定的设备
-(BOOL)connect:(CBPeripheral *)peripheral
{
    NSLog(@"开始连接");
    
    [manager connectPeripheral:peripheral
                       options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    
    return YES;
}

//连接上外围设备后我们就要找到外围设备的服务特性
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"已经连接");
    
    //连接完成后，就停止检测
    [manager stopScan];
    
    //[self.data setLength:0];
    //确保我们收到的外围设备连接后的回调代理函数
    
    
    NSLog(@"开始发现服务");
    
    peripheral.delegate=self;
    //告诉外围设备，谁与外围设备连接
    //[peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
    [peripheral discoverServices:nil];
    
}

//断开链接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"disconnected");
}

#pragma mark - 发现服务操作和处理

//相当于对方的账号
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    NSLog(@"已经发现服务");
    if (error) {
        NSLog(@"Errordiscover:%@",error.localizedDescription);
        //[self clearUp];
        return;
    }
    //找到我们想要的特性
    //遍历外围设备的服务
    for (CBService*server in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:server];
    }
    
}

#pragma mark - 发现特性后的处理, 添加订阅

//当发现传送服务特性后我们要订阅他 来告诉外围设备我们想要这个特性所持有的数据
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    
    if (error) {
        NSLog(@"error  %@",[error localizedDescription]);
        //[self clearUp];
        return;
    }
    //检查特性
    for (CBCharacteristic*characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            NSLog(@"找到所需特性");
            
            //有来自外围的特性，找到了，就订阅他
            // 如果第一个参数是yes的话，就是允许代理方法peripheral:didUpdateValueForCharacteristic:error: 来监听 第二个参数 特性是否发生变化
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            //完成后，等待数据传进来
            NSLog(@"订阅成功");
            
        }
    }
    
}

//外围设备让我们知道，我们订阅和取消订阅是否发生
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"error  %@",error.localizedDescription);
    }
    //如果不是我们要特性就退出
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    if (characteristic.isNotifying) {
        NSLog(@"外围特性通知开始");
    }else{
        NSLog(@"外围设备特性通知结束，也就是用户要下线或者离开%@",characteristic);
        //断开连接
        [manager cancelPeripheralConnection:peripheral];
        
    }
}



#pragma mark - 特征上数据更新事件处理

//这个函数类似网络请求时候只需收到数据的那个函数
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"error~~%@",error.localizedDescription);
        return;
    }
    //characteristic.value 是特性中所包含的数据
    NSString*stringFromData=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"接收到得数据: %@",stringFromData);
    
    //回传了数据
    self.recivData(characteristic.value);
    
    /*
     if ([stringFromData isEqualToString:BluetoothEnd]) {
     //完成发送，调用代理进行传递self.data
     NSString*str=[[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
     //取消订阅
     [peripheral setNotifyValue:NO forCharacteristic:characteristic];
     [self.centralManager cancelPeripheralConnection:peripheral];
     self.blockValue(str);
     
     }else{
     //数据没有传递完成，继续传递数据
     [self.data appendData:characteristic.value];
     
     }
     */
}

@end
