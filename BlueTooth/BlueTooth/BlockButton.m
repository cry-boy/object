//
//  BlockButton.m
//  BlueTooth
//
//  Created by 1512共享 on 16/2/23.
//  Copyright (c) 2016年 shishu. All rights reserved.
//

#import "BlockButton.h"

@implementation UIButton (BlockButton)

+(UIButton *)systemButtonWithFrame:(CGRect)frame
                             title:(NSString *)title
                            action:( void (^)(UIButton *button) )action
{
    BlockButton *button = [BlockButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    button.action = action;
    return button;
}

@end



@implementation BlockButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)btnClick:(UIButton *)button
{
    //一旦按钮被点击了, 执行传入的block
    //检查有没有传入block
    //细节: 如果block为空, 执行的时候崩溃
    if(self.action)
    {
        //调用block
        self.action(button);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
