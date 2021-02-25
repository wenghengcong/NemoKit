//
//  NMViewController.m
//  NMCore
//
//  Created by wenghengcong on 06/16/2020.
//  Copyright (c) 2020 wenghengcong. All rights reserved.
//

#import "NMViewController.h"
#import <NMCore.h>

@interface NMViewController ()

@end

@implementation NMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *hexStr = @"xy72ff63 cea198b3";
    NSData *data = [NSData dataWithHexString: hexStr];
    NSLog(@"%@", data);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
