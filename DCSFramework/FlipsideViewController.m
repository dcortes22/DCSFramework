//
//  FlipsideViewController.m
//  DCSFramework
//
//  Created by David Cortés Sáenz on 30/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

- (void)awakeFromNib
{
    self.preferredContentSize = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
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

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

-(IBAction)share:(id)sender{
    ShareManager *share = [[ShareManager alloc]initWithDelegate:self];
    [share shareText:@"Hola" withItems:[NSArray arrayWithObjects:[NSURL URLWithString:@"http://www.facebook.com"], nil]];
}

@end
