//
//  ViewController.m
//  LC_Alarm
//
//  Created by 李成 on 2017/2/8.
//  简书地址: http://www.jianshu.com/p/e715d75da7b9
//  GitHub: 下载地址 https://github.com/smalirCar/LC_Alarm.git
//  百尺竿头，更进一步

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>


#define kW self.view.frame.size.width

#define kH self.view.frame.size.height

@interface ViewController ()
{
    NSTimer *_timer;  //定时器
    AVAudioPlayer *_player; // 本地音乐播放器
}
@property(nonatomic, weak) UIDatePicker *picker; // 日期选择器
@property(nonatomic,weak) UILabel *labelOfRemainingTime; // 距离闹钟响起剩余的时间
@property(nonatomic,assign) NSInteger remainingTime;
@property(nonatomic,weak) UIButton *button; // 确定设置闹钟按钮
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"闹钟";
    self.view.backgroundColor = [UIColor whiteColor];
    [self _loadView];
}

- (void)_loadView {
    // 创建时间选择器
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    picker.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.5 alpha:0.1];
    [self.view addSubview:picker];
    _picker = picker;
    // 创建确定设置闹钟 button
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    button.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.8 alpha:0.2];
    button.center = self.view.center;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(countTime:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"确定" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    _button=button;
    [self.view addSubview:button];
    // 创建显示距离闹钟响起剩余时间 Label
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 400, kW - 40, kH - 400 - 80)];
    label.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.6 alpha:0.2];
    label.text=@"00:00:00";
    label.textAlignment = NSTextAlignmentCenter;

    [label setFont:[UIFont systemFontOfSize:80]];
    _labelOfRemainingTime = label;
    [self.view addSubview:label];
    UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(25, 400, kW - 40, 40)];
    label1.text = @"闹钟还剩时间：";
    [self.view addSubview:label1];
}

- (void)countTime:(UIButton *) button {
    // 改变选中装填
    button.selected = !button.selected;
    NSLog(@"%d", button.selected);
    
    //求从现在到设置时间的时长秒数(有误差)
    /*
     //1970到picker的秒数
     NSTimeInterval seconds=[_picker.date timeIntervalSince1970];
     NSLog(@"%@",_picker.date);   //设置的时间
     NSLog(@"%.0f",seconds);
     
     //1970到现在的秒
     NSDate * date=[[NSDate alloc]init];
     NSLog(@"%@",date);
     NSTimeInterval seconds2=[date timeIntervalSince1970];
     NSLog(@"%.0f",seconds2);
     NSLog(@"时间差是：----%.0f 秒",seconds-seconds2);
     */
    
    //求从现在到设置时间的时长秒数（有误差）
    /*
     NSDate * date=[[NSDate alloc]init];
     NSLog(@"%@",date);
     NSTimeInterval seconds2=[_picker.date timeIntervalSinceDate:date];
     NSLog(@"%.0f",seconds2);
     NSLog(@"时间差是：----%.0f 秒",seconds2);
     */
    
   
    // picker 设置的时间
    
    // 格式
    NSDateFormatter * format1 = [[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"hh"];
    NSDateFormatter * format2 = [[NSDateFormatter alloc] init];
    [format2 setDateFormat:@"mm"];
    
    // 获取小时
    NSString *str1 = [format1 stringFromDate:_picker.date];
    NSInteger temp1 = [str1 integerValue];
    NSDate *date3 = [[NSDate alloc]init];
    NSString *str3 = [format1 stringFromDate:date3];
    NSInteger temp3 = [str3 integerValue];
    
    // 获取分钟
    NSString *str2 = [format2 stringFromDate:_picker.date];
    NSInteger temp2=[str2 integerValue];
    NSDate *date4 = [[NSDate alloc]init];
    NSString *str4 = [format2 stringFromDate:date4];
    NSInteger temp4 = [str4 integerValue];
    NSLog(@"闹钟时长：%li 秒",(temp1 - temp3) * 60 * 60 + (temp2 - temp4) * 60);
    
    // 计算出距离下一次闹钟响起的时间差
    NSInteger lt = (temp1 - temp3) * 60 * 60 + (temp2 - temp4) * 60;
    self.remainingTime = lt;
    
    // 做判断, 当 button 被选中, 并且设置的时间差大于零的时候作为一个条件, 给 label 赋值。否则就是 00:00:00
    if (self.remainingTime > 0 && _button.selected) {
        NSString * strT = [NSString stringWithFormat:@"%02i:%02i:%02i",(int)lt / 3600 % 60, (int)lt / 60 % 60, (int)lt % 60];
        self.labelOfRemainingTime.text = strT;
        
        [_button setTitle:@"确定" forState:UIControlStateSelected];
        [_button setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [self.view reloadInputViews];
        // 当没有定时器的时候, 创建定时器。倘若创建了定时器, 那么放弃定时器。
        if (_timer == nil) {
            //每隔0.01秒刷新一次页面
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(runAction) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        }
        NSLog(@"开始倒计时.....");
    } else {
        NSLog(@"请重新设置时间....");
        self.labelOfRemainingTime.text = @"00:00:00";
        self.button.selected = NO;
        return;
    }
}

- (void)runAction {
    self.remainingTime --;
    if(_remainingTime == 0) {
        [_timer invalidate];//让定时器失效
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"点击确定关掉闹钟" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [_player stop];
            _button.selected = NO;
        }]];
        [self presentViewController:alertController animated:YES completion:^{
            _timer = nil;
        }];
        //提示框弹出的同时，开始响闹钟
        NSString *path = [[NSBundle mainBundle]pathForResource:@"4948.MP3" ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *error;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        _player.numberOfLoops = -1;    // 无限循环  =0 一遍   =1 两遍    =2 三遍    =负数  单曲循环
        _player.volume = 2;          // 音量
        [_player prepareToPlay];    // 准备工作
        //[_player stop];       // 卡一下
        [_player play];    // 开始播放
        
        // 1 注册通知
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *array = [app scheduledLocalNotifications];
        NSLog(@"%ld", array.count);
        for (UILocalNotification *local in array) {
            NSDictionary *dic = local.userInfo;
            NSLog(@"dicdicdicdicdicdicdicdicdicdicdicdicdicdicdicdicdicdicdic%@", dic);
            if ([dic[@"name"] isEqual:@"zhangsan"]) {
                //删除指定的通知
                [app cancelLocalNotification:local];
            }
        }
        //删除所有通知
            [app cancelAllLocalNotifications];
        //
        
        //判断是否已经注册通知
        UIUserNotificationSettings *setting = [app currentUserNotificationSettings];
        
        // 如果setting.types == UIUserNotificationTypeNone 需要注册通知
        if(setting.types == UIUserNotificationTypeNone){
            UIUserNotificationSettings *newSetting = [UIUserNotificationSettings settingsForTypes:
                                                      UIUserNotificationTypeBadge|
                                                      UIUserNotificationTypeSound|
                                                      UIUserNotificationTypeAlert
                                                                                       categories:nil];
            [app registerUserNotificationSettings:newSetting];
        }else{
            // 如果已经有了通知把它加到本地通知里面
            [self addLocalNotification];
        }
    }
    NSString *str = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)(self.remainingTime) / 3600 % 24, (int)(self.remainingTime) / 60 % 60, (int)(self.remainingTime) % 60];
    self.labelOfRemainingTime.text = str;
//    _button.selected = NO;
}

#pragma mark - 增加本地通知
- (void)addLocalNotification {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    notification.alertBody = @"闹钟响了。。。。。。";
    notification.alertAction = @"打开闹钟";
    notification.repeatInterval = NSCalendarUnitSecond;
    notification.applicationIconBadgeNumber = 1;
    //notification.userInfo=@{@"name":@"zhangsan"};
    //notification.soundName=@"4195.mp3";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

//注册完成后调用
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [self addLocalNotification];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"+========我接受到通知了");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [_player stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
