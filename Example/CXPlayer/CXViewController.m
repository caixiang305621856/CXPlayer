//
//  CXViewController.m
//  CXPlayer
//
//  Created by caixiang305621856 on 05/11/2019.
//  Copyright (c) 2019 caixiang305621856. All rights reserved.
//

#import "CXViewController.h"
#import "CXPlayViewController.h"

@interface CXViewController ()

@end

@implementation CXViewController

- (IBAction)playClick:(id)sender {
    CXPlayViewController *playViewController = [CXPlayViewController new];
    playViewController.disMissBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    playViewController.shareBlock = ^{
        NSLog(@"分享");
    };
    playViewController.playerStatusBlock = ^(CXAVPlayerStatus playerStatus) {
    };
    UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:playViewController];
    [self.navigationController presentViewController:na animated:YES completion:^{
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
