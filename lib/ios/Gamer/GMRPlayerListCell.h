//
//  GMRPlayerListCell.h
//  Gamer
//
//  Created by Adam Venturella on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GMRPlayerListCell : UITableViewCell {
	UILabel * player;
}
@property(nonatomic, retain) IBOutlet UILabel * player;
@end
