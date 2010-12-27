//
//  GMRGameDetailController.m
//  Gamer
//
//  Created by Adam Venturella on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <dispatch/dispatch.h>
#import <QuartzCore/QuartzCore.h>
#import "GMRGameDetailController.h"
#import "GMRGameDetailController+PlayerList.h"
#import "GMRGameDetailController+Sharing.h"
#import "GMRButton.h"
#import "GMRGlobals.h"
#import "GMRClient.h"
#import "NSDate+JSON.h"
#import "GMRTypes.h"
#import "GMRAlertView.h"
#import "GMRMatch.h"
#import "GMRGame.h"
#import "GMRLabel.h"
#import "UIButton+GMRButtonTypes.h"
#import "OverviewController.h"
#import "GMRPlayer.h"

@implementation GMRGameDetailController
@synthesize playersTableView, playersForMatch, gameLabel, platformLabel, descriptionLabel, modeLabel, scheduleTimeLabel, howItWorksView, matchesDataSourceController;

-(id)initWithMatch:(GMRMatch *)value membership:(GMRMatchMembership)member
{
	self = [super initWithNibName:nil bundle:nil];
	if(self)
	{
		match = value;
		[match retain];
		
		membership = member;
	}
	
	return self;
}
- (void)viewDidLoad 
{
	self.navigationItem.titleView = [GMRLabel titleLabelWithString:@"Details"];
	[self.navigationItem setHidesBackButton:YES];
	
	UIButton * backButton = [UIButton buttonWithGMRButtonType:GMRButtonTypeBack];
	[backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	
	[self.navigationItem setLeftBarButtonItem:backItem animated:YES];
	[backItem release];
	
	toolbar              = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 323, 320, 44)];
	toolbar.transform    = CGAffineTransformMakeTranslation(0.0, 44);
	howItWorksView.transform = CGAffineTransformMakeTranslation(0.0, 100);
	
	CGFloat roundedColor = 246.0/255.0;
	UIView * roundedView = [[UIView alloc] initWithFrame:CGRectMake(4.0, 8.0, 312.0, 68.0)];
	
	
	roundedView.layer.cornerRadius    = 5.0;
	roundedView.layer.backgroundColor = [UIColor colorWithRed:roundedColor 
										            green:roundedColor 
										             blue:roundedColor 
										            alpha:1.0].CGColor;
	
	
	[howItWorksView insertSubview:roundedView atIndex:0];
	[roundedView release];
	howItWorksView.hidden = YES;
	
	
	[self.view addSubview:toolbar];
	
	
	
	gameLabel.text         = match.game.label;
	descriptionLabel.text  = match.label;
	modeLabel.text         = match.mode;
	scheduleTimeLabel.text = [NSDate relativeTime:match.scheduled_time];
	platformLabel.text     = [GMRClient displayNameForPlatform:match.platform];
	
	UIView * platformColors = [[UIView alloc] initWithFrame:CGRectMake(0, (descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height), 320, 6)];
	UIColor * patternColor;
	
	switch(match.platform)
	{
		case GMRPlatformBattleNet:
			patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlatformColorHorizontalBattleNet.png"]];
			break;
			
		case GMRPlatformPlaystation2:
			patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlatformColorHorizontalPlaystation2.png"]];
			break;
			
		case GMRPlatformPlaystation3:
			patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlatformColorHorizontalPlaystation3.png"]];
			break;
			
		case GMRPlatformSteam:
			patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlatformColorHorizontalSteam.png"]];
			break;
			
		case GMRPlatformWii:
			patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlatformColorHorizontalWii.png"]];
			break;
			
		case GMRPlatformXBox360:
			patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PlatformColorHorizontalXbox360.png"]];
			break;
			
	}
	
	platformColors.backgroundColor = patternColor;
	
	[self.view addSubview:platformColors];
	[platformColors release];
	
	
	[self playersTableRefresh];
	
	[super viewDidLoad];
	 
	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[updateTimer invalidate];
	/*
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	[UIView animateWithDuration:0.15
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 toolbar.transform    = CGAffineTransformMakeTranslation(0.0, 44);
						 howItWorksView.transform = CGAffineTransformMakeTranslation(0.0, 84 + 44);
					 } 
					 completion:NULL];
	 */
}

- (void)viewDidAppear:(BOOL)animated
{
	/*[UIView animateWithDuration:0.15
						  delay:0.15
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 
					 } 
					 completion:^(BOOL finished){
						 
					 }];
	 */
	
	[UIView animateWithDuration:0.25
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 
						 toolbar.transform  = CGAffineTransformIdentity; 
					 } 
					 completion:^(BOOL finished){
						 
						if(membership == GMRMatchMembershipMember)
							[self setupToolbar];
						 
						howItWorksView.hidden = NO;
						[UIView animateWithDuration:0.3
											   delay:0.0
											 options:UIViewAnimationOptionCurveEaseOut
										  animations:^{
											  howItWorksView.transform = CGAffineTransformIdentity;
										  } 
										 completion:^(BOOL finished){
											 updateTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 
																							target:self 
																						  selector:@selector(updateCountdown) 
																						  userInfo:nil 
																						   repeats:YES];
										 }];
					}];
}

- (void)setupToolbar
{
	NSString * currentUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	
	UIButton * actionButton;
	
	if([match.created_by isEqualToString:currentUser])
	{
		actionButton = [UIButton buttonWithGMRButtonType:GMRButtonTypeCancel];
		[actionButton addTarget:self action:@selector(cancelGame) forControlEvents:UIControlEventTouchUpInside];
	}
	else
	{
		// save us a loop if we can.
		if(membership == GMRMatchMembershipMember)
		{
			actionButton = [UIButton buttonWithGMRButtonType:GMRButtonTypeLeave];
			[actionButton addTarget:self action:@selector(leaveGame) forControlEvents:UIControlEventTouchUpInside];
		}
		else 
		{
			for(GMRPlayer * player in self.playersForMatch)
			{
				if([player.username isEqualToString:currentUser])
				{
					actionButton = [UIButton buttonWithGMRButtonType:GMRButtonTypeLeave];
					[actionButton addTarget:self action:@selector(leaveGame) forControlEvents:UIControlEventTouchUpInside];
					break;
				}
			}
			
			if(actionButton == nil)
			{
				actionButton = [UIButton buttonWithGMRButtonType:GMRButtonTypeJoin];
				[actionButton addTarget:self action:@selector(joinGame) forControlEvents:UIControlEventTouchUpInside];
			}
		}

	}
	
	
	UIButton* shareButton = [UIButton buttonWithGMRButtonType:GMRButtonTypeShare];
	[shareButton addTarget:self action:@selector(shareGame) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem * action = [[UIBarButtonItem alloc] initWithCustomView:actionButton];
	UIBarButtonItem * spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem * share = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
	
	NSArray * items = [NSArray arrayWithObjects:action, spacer, share, nil];
	
	[toolbar setItems:items animated:YES];
}

- (void)updateCountdown
{
	self.scheduleTimeLabel.text = [NSDate relativeTime:match.scheduled_time];
}


- (void)shareGame
{
	NSLog(@"%@", self.parentViewController);
	NSLog(@"%@", self.parentViewController.parentViewController);
	UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Sharing %@", match.game.label]
														delegate:self 
											   cancelButtonTitle:@"Cancel" 
										  destructiveButtonTitle:nil 
											   otherButtonTitles:@"Email", @"Facebook", @"Twitter", nil];
	
	[sheet showInView:self.parentViewController.parentViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) 
	{
		case 0: // email
			[self shareEmail];
			break;
		
		case 1: // Facebook
			[self shareFacebook];
			break;
			
		case 2: // Twitter
			[self shareTwitter];
			break;
			
	}
	
	[actionSheet release];
	
}

- (void)joinGame
{
	NSTimeInterval matchTime = [match.scheduled_time timeIntervalSinceNow];
	NSTimeInterval closestMatch = (double)INT_MAX;
	
	// get the scheduled match closest to now.
	for (GMRMatch * scheduledMatch in kScheduledMatches) 
	{
		NSTimeInterval scheduledInterval = [scheduledMatch.scheduled_time timeIntervalSinceNow];
		NSTimeInterval delta = ABS(matchTime - scheduledInterval);
		
		closestMatch = delta < closestMatch ? scheduledInterval : closestMatch;
	}
	
	
	// 30 min - Games are alloted a 30 min (1800 sec) play slot.  if the user wishes to join a game
	// they connot have any other game scheduled that start within 30 min from the game they wish to join.
	if(closestMatch < 1800) 
	{
		GMRAlertView * alert = [[GMRAlertView alloc] initWithStyle:GMRAlertViewStyleNotification 
															 title:@"Schedule Conflict" 
														   message:@"You are currently scheduled for a match that starts within 30 minutes of this match." 
														  callback:^(GMRAlertView * alertView){
															  [alertView release];
														  }];
		[alert show];
	}
	else
	{
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		[kGamerApi matchJoin:match.platform
					  gameId:match.game.id 
					 matchId:match.id 
				withCallback:^(BOOL ok, NSDictionary * response){
					dispatch_async(dispatch_get_main_queue(), ^{				 
						[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
						[self didJoinMatch];
					});
				}];
	}
}


- (void)cancelGame
{
	GMRAlertView * alert = [[GMRAlertView alloc] initWithStyle:GMRAlertViewStyleConfirmation
														 title:@"Cancel Game?" 
													   message:@"This is a serious moment. Are you sure you wish to cancel this game? All players will be removed and the game deleted." 
													  delegate:self];
	[alert show];
	
	
}

- (void)leaveGame
{
	GMRAlertView * alert = [[GMRAlertView alloc] initWithStyle:GMRAlertViewStyleConfirmation
														 title:@"Leave Game?" 
													   message:@"Are you sure you wish to leave this game?" 
													  delegate:self];
	[alert show];
}

- (void)alertViewDidDismiss:(GMRAlertView *)alertView
{
	if(alertView.selectedButtonIndex == 1)
	{
		NSString * gameId    = [[match.game.id componentsSeparatedByString:@"/"] objectAtIndex:1];
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
		[kGamerApi matchLeave:match.game.platform 
						gameId:gameId 
					   matchId:match.id 
				  withCallback:^(BOOL ok, NSDictionary * response){
					     dispatch_async(dispatch_get_main_queue(), ^{				 
							 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
							 [self didLeaveMatch];
			             });
		 }];
	}
	
	[alertView release];
}

- (void)didJoinMatch
{
	if(kScheduledMatchesViewController)
	{
		
		NSUInteger insertIndex = -1;
		
		for(GMRMatch * currentMatch in kScheduledMatches)
		{
			if([match.scheduled_time compare:currentMatch.scheduled_time] == NSOrderedDescending)
			{
				insertIndex = [kScheduledMatches indexOfObject:currentMatch];
			}
			
		}
		
		insertIndex = insertIndex == -1 ? 0 : insertIndex + 1;
		
		[kScheduledMatchesViewController willChange:NSKeyValueChangeInsertion 
								valuesAtIndexes:[NSIndexSet indexSetWithIndex:insertIndex] 
										 forKey:@"matches"];
		
		[kScheduledMatches insertObject:match 
								atIndex:insertIndex];
		
		
		[kScheduledMatchesViewController didChange:NSKeyValueChangeInsertion 
							   valuesAtIndexes:[NSIndexSet indexSetWithIndex:insertIndex] 
										forKey:@"matches"];
	}
}

- (void)didLeaveMatch
{
	// we may have gotten here from the OverviewController or the LobbyController.  
	// because of that we cannot use [indexOfObject:] since if we arrived from the LobbyController
	// the match objects will be differnt/new objects compared to the scheduled matches objects.
	
	NSUInteger removeIndex = [kScheduledMatches indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop){
		GMRMatch * currentMatch = (GMRMatch *)obj;
		if([currentMatch.id isEqualToString:match.id])
		{
			*stop = YES;
			return YES;
		}
		
		return NO;
	}];
	
	// notify the overview controller we changed the matches
	if(removeIndex != NSNotFound)
	{
		if(kScheduledMatchesViewController)
		{
		
			[kScheduledMatchesViewController willChange:NSKeyValueChangeRemoval
									valuesAtIndexes:[NSIndexSet indexSetWithIndex:removeIndex] 
											 forKey:@"matches"];
			
			[kScheduledMatches removeObjectAtIndex:removeIndex];
			
			[kScheduledMatchesViewController didChange:NSKeyValueChangeRemoval 
								   valuesAtIndexes:[NSIndexSet indexSetWithIndex:removeIndex] 
											forKey:@"matches"];
		}
	}
	
	[self.navigationController popViewControllerAnimated:YES];
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
	
	self.playersTableView = nil;
	self.gameLabel = nil; 
	self.descriptionLabel = nil;
	self.modeLabel = nil;
	self.scheduleTimeLabel = nil;
	self.platformLabel = nil;
	self.howItWorksView = nil;
	
	[toolbar release];
}


- (void)dealloc {
	self.playersForMatch = nil;
	[match release];
    [super dealloc];
}


@end
