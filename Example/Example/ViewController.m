//
//  ViewController.m
//  Example
//
//  Created by lzn on 16/3/19.
//  Copyright © 2016年 go. All rights reserved.
//

#import "ViewController.h"
#import "ZNPlayerView.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet ZNPlayerView *playerView;

@property(nonatomic,strong) ZNPlayerView *codeCreate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZNPlayerView *codeCreate = [[ZNPlayerView alloc] init];
    codeCreate.frame = CGRectMake(20, 400, 300, 200);
    [self.view addSubview:codeCreate];
    codeCreate.backgroundColor = [UIColor yellowColor];
    self.codeCreate = codeCreate;
    
    
}
- (IBAction)playLocalUrl:(id)sender {
    self.playerView.playUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"local" ofType:@"mov"]];
    self.codeCreate.playUrl = self.playerView.playUrl;
}
- (IBAction)playNetUrl:(id)sender {
    //
    //self.playerView.playUrl = [NSURL URLWithString:@"网络 urlString"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"亲,请自己找一个网络 url 替换在代码中!" delegate:nil cancelButtonTitle:@"辛苦您了" otherButtonTitles: nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
