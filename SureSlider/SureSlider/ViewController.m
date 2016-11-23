//
//  ViewController.m
//  SureSlider
//
//  Created by 刘硕 on 2016/10/24.
//  Copyright © 2016年 刘硕. All rights reserved.
//

#import "ViewController.h"
#import "SureServiceSlider.h"
@interface ViewController ()

@property (nonatomic, strong) SureServiceSlider *slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSlider];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)createSlider {
    _slider = [[SureServiceSlider alloc]initWithFrame:CGRectMake(15, 100, self.view.bounds.size.width - 30, 50)];
    [self.view addSubview:_slider];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
