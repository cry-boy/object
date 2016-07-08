//
//  ViewController.m
//  BlueTooth
//
//  Created by 1512共享 on 16/2/23.
//  Copyright (c) 2016年 shishu. All rights reserved.
//
/*
 外围设备和中央设备在CoreBluetooth中使用CBPeripheralManager和CBCentralManager表示。
 
 CBPeripheralManager：外围设备通常用于发布服务、生成数据、保存数据。外围设备发布并广播服务，告诉周围的中央设备它的可用服务和特征。
 
 CBCentralManager：中央设备使用外围设备的数据。中央设备扫描到外围设备后会就会试图建立连接，一旦连接成功就可以使用这些服务和特征。
 
 外围设备和中央设备之间交互的桥梁是服务(CBService)和特征(CBCharacteristic)，二者都有一个唯一的标识UUID（CBUUID类型）来唯一确定一个服务或者特征，每个服务可以拥有多个特征.
 
 每个蓝牙4.0的设备都是通过服务和特征来展示自己的，一个设备必然包含一个或多个服务，每个服务下面又包含若干个特征。特征是与外界交互的最小单位。比如说，一台蓝牙4.0设备，用特征A来描述自己的出厂信息，用特征B来与收发数据等。
 
 一台iOS设备（注意iPhone4以下设备不支持BLE，另外iOS7.0、8.0模拟器也无法模拟BLE）既可以作为外围设备又可以作为中央设备，但是不能同时即是外围设备又是中央设备，同时注意建立连接的过程不需要用户手动选择允许，这一点和前面两个框架是不同的，这主要是因为BLE应用场景不再局限于两台设备之间资源共享了。
 
 A.外围设备
 创建一个外围设备通常分为以下几个步骤：

 创建外围设备CBPeripheralManager对象并指定代理。
 创建特征CBCharacteristic、服务CBSerivce并添加到外围设备
 外围设备开始广播服务（startAdvertisting:）。
 和中央设备CBCentral进行交互。
 
 B.中央设备
 
 中央设备的创建一般可以分为如下几个步骤：
 
 创建中央设备管理对象CBCentralManager并指定代理。
 扫描外围设备，一般发现可用外围设备则连接并保存外围设备。
 查找外围设备服务和特征，查找到可用特征则读取特征数据。
 */

#import "ViewController.h"
#import "CentralManager.h"
#import "PeripheralManager.h"
#import "BlockButton.h"

@interface ViewController ()
{
    
    NSTimer *connectTimer;
    PeripheralManager *peripheralManager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton *button = [UIButton systemButtonWithFrame:CGRectMake(100, 100, 100, 30) title:@"扫描" action:^(UIButton *button)
                        {
                            CentralManager *manager = [CentralManager sharedInstance];
                            //启动设备，并且扫描
                            [manager startCreateAndScan];
                            
                            manager.recivData = ^(NSData * data){
                                //这里的data就是接受到的数据。
                                NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            };
                        }];
    
    [self.view addSubview:button];
    
    
    //启动外设----服务设置, 一般为被控制设备
    UIButton *perButton = [UIButton systemButtonWithFrame:CGRectMake(100, 150, 100, 30) title:@"启动外设" action:^(UIButton *button)
                           
                           {
                               peripheralManager = [PeripheralManager sharedInstance];
                               //启动设备
                               [peripheralManager createAndNotify];
                               
                           }];
    [self.view addSubview:perButton];
    
    
    
    UIButton *sendButton = [UIButton systemButtonWithFrame:CGRectMake(100, 200, 100, 30) title:@"发送" action:^(UIButton *button)
                            {
                                //发送
                                [peripheralManager sendString:@"hahahaha"];
                                
                            }];
    [self.view addSubview:sendButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
