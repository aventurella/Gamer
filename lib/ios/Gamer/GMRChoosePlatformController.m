//
//  GMRChoosePlatformController.m
//  Gamer
//
//  Created by Adam Venturella on 11/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GMRChoosePlatformController.h"
#import "GMRMatch.h"
#import "GMRTypes.h"
#import "GMRCreateGameGlobals.h"

@implementation GMRChoosePlatformController

- (void)viewDidLoad 
{
    self.navigationItem.title = @"Platform";
	[super viewDidLoad];
}

- (IBAction)selectBattleNet
{
	kCreateMatchProgress.platform = GMRPlatformBattleNet;
	[self cancelSheet];
}

- (IBAction)selectPlaystation2
{
	kCreateMatchProgress.platform = GMRPlatformPlaystation2;
	[self cancelSheet];
}

- (IBAction)selectPlaystation3
{
	kCreateMatchProgress.platform = GMRPlatformPlaystation3;
	[self cancelSheet];
}
- (IBAction)selectWii
{
	kCreateMatchProgress.platform = GMRPlatformWii;
	[self cancelSheet];
}

- (IBAction)selectXbox360
{
	kCreateMatchProgress.platform = GMRPlatformXBox360;
	[self cancelSheet];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
