//
//  MainViewController.m
//  DCSFramework
//
//  Created by David Cortés Sáenz on 30/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import "MainViewController.h"
#import "Author.h"
#import "CoreDataManager.h"
#import "YouTubeService.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSArray *array = [[CoreDataManager sharedInstance]getEntities:@"Author" withPredicate:nil withSortColumn:nil];
    Author *author = [array objectAtIndex:0];
    NSLog(@"%@", author.name);
    NSLog(@"%@", author.uri);
    YouTubeService *test = [[YouTubeService alloc]initWithDelegate:self];
    [test getVideos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

- (void)service:(BaseService *)service onServiceSuccess:(id)object {
    NSArray *objects = (NSArray *)object;
    
    NSMutableDictionary *dictionary = [[[objects objectAtIndex:0] objectForKey:@"author"] objectAtIndex:0];
    
    Author *objectsaved = [[CoreDataManager sharedInstance] addOrUpdateObjectFromJSONDictionary:dictionary entity:@"Author" idObjectName:@"author"];
    
    [[CoreDataManager sharedInstance] saveContext];
    
    
    NSLog(@"%@", objectsaved.name);
}

- (void)service:(BaseService *)service onServiceError:(NSError *)error {
    NSLog(@"onServiceError");
}

- (void)service:(BaseService *)service onConnectionError:(NSError *)error {
    NSLog(@"onConnectionError");
}

@end
