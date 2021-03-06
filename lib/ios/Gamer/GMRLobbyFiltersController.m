//
//  GMRLobbyFiltersController.m
//  Gamer
//
//  Created by Adam Venturella on 12/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GMRLobbyFiltersController.h"
#import "GMRLobbyFiltersController+Navigation.h"
#import "GMRGameLobbyGlobals.h"
#import "UIButton+GMRButtonTypes.h"
#import "GMRLabel.h"
#import "GMRFilter.h"
#import "GMRGame.h"
#import "GMRClient.h"

GMRFilter * kFilters = nil;

@implementation GMRLobbyFiltersController
@synthesize owner, platform, game, timeInterval;


- (void)viewDidLoad 
{
	UIButton * doneButton = [UIButton buttonWithGMRButtonType:GMRButtonTypeDone];
	[doneButton addTarget:self action:@selector(applyFilter) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem * done   = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
	
	
	self.navigationItem.titleView = [GMRLabel titleLabelWithString:@"Lobby Filters"];
	self.navigationItem.rightBarButtonItem = done;
	
	[done release];
	
	if(!kFilters)
		kFilters = [[GMRFilter alloc] init];
	
	[kFilters addObserver:self 
			   forKeyPath:@"platform" 
				  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 
				  context:nil];
	
	[kFilters addObserver:self 
			   forKeyPath:@"game" 
				  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 
				  context:nil];
	
	[kFilters addObserver:self 
			   forKeyPath:@"timeInterval" 
				  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 
				  context:nil];
	
	[super viewDidLoad];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting)
	{
		if([keyPath isEqualToString:@"platform"])
		{
			if([[change objectForKey:NSKeyValueChangeNewKey] intValue] != [[change objectForKey:NSKeyValueChangeOldKey] intValue])
			{
				NSString * displayString = [GMRClient formalDisplayNameForPlatform:kFilters.platform];
				
				if(self.platform.selected == NO)
				{
					self.platform.selected = YES;
				}
				
				self.platform.label.text = displayString;
				
				if(kFilters.game)
				{
					kFilters.game = nil;
				}
			}
		}
		
		else if([keyPath isEqualToString:@"game"])
		{
			if([change objectForKey:NSKeyValueChangeNewKey] != [change objectForKey:NSKeyValueChangeOldKey])
			{
				if ([change objectForKey:NSKeyValueChangeNewKey] == [NSNull null])
				{
					self.game.selected      = NO;
					self.game.label.text    = @"Game";
				}
				else 
				{
					if(self.game.selected == NO)
					{
						self.game.selected   = YES;
						self.game.label.text = kFilters.game.label;
					}
				}
			}
		}
		else if([keyPath isEqualToString:@"timeInterval"])
		{
			if([change objectForKey:NSKeyValueChangeNewKey] != [change objectForKey:NSKeyValueChangeOldKey])
			{
				NSString * displayString;
				
				switch(kFilters.timeInterval)
				{
					case GMRTimeInterval15Min:
						displayString = @"Starting Within 15 min";
						break;
						
					case GMRTimeInterval30Min:
						displayString = @"Starting Within 30 min";
						break;
						
					case GMRTimeIntervalHour:
						displayString = @"Starting Within 1 hour";
						break;
				}
				
				if(self.timeInterval.selected == NO)
				{
					self.timeInterval.selected = YES;
				}
				
				self.timeInterval.label.text = displayString;
				
			}
		}
	}
}

- (void)applyFilter
{
	[self.owner performSelector:@selector(applyFilter:) withObject:kFilters];
	[self dismissModalViewController];
}

- (void)dismissModalViewController
{
	[self.owner dismissModalViewControllerAnimated:YES];
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
	self.platform = nil;
	self.game = nil;
	self.timeInterval = nil;
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	self.platform = nil;
	self.game = nil;
	self.timeInterval = nil;
	
	[kFilters removeObserver:self 
				  forKeyPath:@"platform"];
	
	[kFilters removeObserver:self 
				  forKeyPath:@"game"];
	
	[kFilters removeObserver:self 
				  forKeyPath:@"timeInterval"];
	
	[kFilters release];
	kFilters = nil;
	
    [super dealloc];
}


@end
