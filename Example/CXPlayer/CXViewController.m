//
//  CXViewController.m
//  CXPlayer
//
//  Created by caixiang305621856 on 05/11/2019.
//  Copyright (c) 2019 caixiang305621856. All rights reserved.
//

#import "CXViewController.h"
#import "CXPlayerViewController.h"

#define VideoURL @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"

@interface CXViewController ()
@property (nonatomic ,strong) UIView *videoPlayBGView;

@end

@implementation CXViewController

- (IBAction)playClick:(id)sender {
    CXPlayerViewController *playerViewController = [CXPlayerViewController new];
    playerViewController.disMissBlcok = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
        
    [playerViewController seekToTimePlay:13];
    [playerViewController playWithUrl:VideoURL];

    
    UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:playerViewController];
    [self.navigationController presentViewController:na animated:YES completion:^{
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
