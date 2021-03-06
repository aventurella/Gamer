//
//  GMRClient.h
//  Gamer
//
//  Created by Adam Venturella on 11/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define GAMER_TESTING 1

#import <Foundation/Foundation.h>
#import "GMRTypes.h"


@class GMRRequest;
@interface GMRClient : NSObject
{
	GMRRequest * apiRequest;
	NSString * username;
}

@property(nonatomic, copy) NSString * username;
@property(nonatomic, assign) NSString * apiKey;

+ (NSString *)stringForPlatform:(GMRPlatform)platform;
+ (GMRPlatform)platformForString:(NSString *)string;
+ (NSString *)displayNameForPlatform:(GMRPlatform)platform;
+ (NSString *)formalDisplayNameForPlatform:(GMRPlatform)platform;


- (GMRClient *)initWithKey:(NSString *)key andName:(NSString *)name;

- (void)version:(GMRCallback)callback;
- (void)authenticateUser:(NSString *)username password:(NSString *)password withCallback:(GMRCallback)callback;
- (void)registerUser:(NSString *)email username:(NSString *)name password:(NSString *)password passwordVerify:(NSString *)passwordVerify withCallback:(GMRCallback)callback;

- (void)registerAlias:(NSString*)alias platform:(GMRPlatform)platform withCallback:(GMRCallback)callback;
- (void)registerForPushNotifictions:(NSString *)token payload:(NSDictionary *)payload withCallback:(GMRCallback)callback;
- (void)aliases:(GMRCallback)callback;

- (void)playersForMatch:(GMRPlatform)platform gameId:(NSString *)gameId matchId:(NSString *)matchId callback:(GMRCallback)callback;

- (void)searchPlatform:(GMRPlatform)platform forGame:(NSString *)query withCallback:(GMRCallback)callback;
- (void)gamesForPlatform:(GMRPlatform)platform withCallback:(GMRCallback)callback;
- (void)matchesScheduled:(GMRCallback)callback;

- (void)matchesScheduledForPlatform:(GMRPlatform)platform andTimeInterval:(GMRTimeInterval)timeInterval withCallback:(GMRCallback)callback;
- (void)matchesScheduledForPlatform:(GMRPlatform)platform andGame:(NSString *)gameId andTimeInterval:(GMRTimeInterval)timeInterval withCallback:(GMRCallback)callback;
- (void)matchCreate:(NSDate *)scheduledTime gameId:(NSString *)gameId gameMode:(NSString *)gameMode platform:(GMRPlatform)platform availability:(GMRMatchAvailablilty)availability maxPlayers:(NSUInteger)maxPlayers invitedPlayers:(NSArray *)invitedPlayers label:(NSString *)label withCallback:(GMRCallback)callback;
- (void)matchJoin:(GMRPlatform)platform gameId:(NSString *)gameId matchId:(NSString *)matchId withCallback:(GMRCallback)callback;
- (void)matchLeave:(GMRPlatform)platform gameId:(NSString *)gameId matchId:(NSString *)matchId withCallback:(GMRCallback)callback;

@end
