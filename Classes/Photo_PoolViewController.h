//
//  Photo_PoolViewController.h
//  Photo Pool
//
//  Created by Michael Pulsifer on 7/4/10.

//  The following copyright notice and license applies to all code within the PhotoPool application except where noted in specific
//    source files and/or the About View.  
//    
//  Copyright (c) 2010, Mike Pulsifer
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//  
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following 
//    disclaimer in the documentation and/or other materials provided with the distribution.
//  * Neither the name of the Mike Pulsifer nor the names of its contributors may be used to endorse or promote products derived 
//    from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
//  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ObjectiveFlickr.h"
#import "FlickrGroupPickerController.h"
#import "FlickrGroupSearchController.h"
#import "FlickrPhotoSearchController.h"
#import "SingletonFlickrGroup.h"
#import "ExifViewController.h"
//#import "PowerPoints.h"
#import "AboutViewController.h"
#import "UIImage+Extras.h"
#import "MKNumberBadgeView.h"
#import "PhotoInfoCard.h"
#import "ExternalPhotoInfoCard.h"
#import "SettingsViewController.h"

@interface Photo_PoolViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, OFFlickrAPIRequestDelegate, UIPopoverControllerDelegate> {
	
	UIImageView *PPimageView;
	UIImageView *powerPointsView;
	UIPopoverController *ppphotoPickerPopover;
	NSDictionary *plistDictionary;
	NSDictionary *photoDictionary;
	OFFlickrAPIContext *context;
	OFFlickrAPIRequest *flickrRequest;
	SingletonFlickrGroup *sharedGroupState;
	//PowerPoints *powerPointsView;
	UIPopoverController *photoPopover;
	UIPopoverController *groupPopover;
	UIPopoverController *groupSearchPopover;
	UIPopoverController *infoCardPopover;
	UIPopoverController *settingsPopover;
//	NSURL *photoURL;
//	NSData *photoData;
//	NSMutableArray *photoArray;
//	ExternalMonitor *mirrorView;

	UIImageView *mirrorImage;
	
	FlickrPhotoSearchController *flickrPhotoPickerView;
	FlickrGroupPickerController *flickrGroupView;
	FlickrGroupSearchController *flickrGroupSearchView;
	PhotoInfoCard *photoInfoCardView;
	ExternalPhotoInfoCard *mirrorInfoCardView;
	SettingsViewController *settingsView;
	
	AboutViewController *aboutView;

	UIPopoverController *exifPopover;
	ExifViewController *exifViewView;

	//Group Selection objects
	//UIPopoverController *PPgroupPickerPopover;
	//exifviewview exifpopover
	UIWindow *externalWindow;
	NSArray *screenModes;
	UIScreen *externalScreen;
	BOOL mirrorState;
	CGFloat externalWidth;
	CGFloat externalHeight;
	
	UIImageView	*powerPointImageView;
	int powerPointImageViewIndex;
	BOOL powerPointImageViewInFront;
	
	UIImageView *powerPointMirrorView;
	int powerPointMirrorViewIndex;
	BOOL powerPointMirrorViewInFront;
	
	UIButton *badgeOneButton;
	UIButton *badgeTwoButton;
	UIButton *badgeThreeButton;
	UIButton *badgeFourButton;
	UIButton *badgeFiveButton;
	UIButton *badgeSixButton;
	UIButton *badgeSevenButton;
	UIButton *badgeEightButton;
	UIButton *badgeNineButton;
	UIButton *badgeTenButton;
	
	NSMutableString *badgeOneInFront;
	NSMutableString *badgeTwoInFront;
	NSMutableString *badgeThreeInFront;
	NSMutableString *badgeFourInFront;
	NSMutableString *badgeFiveInFront;
	NSMutableString *badgeSixInFront;
	NSMutableString *badgeSevenInFront;
	NSMutableString *badgeEightInFront;
	NSMutableString *badgeNineInFront;
	NSMutableString *badgeTenInFront;
	
	MKNumberBadgeView *badgeOne;
	MKNumberBadgeView *badgeTwo;
	MKNumberBadgeView *badgeThree;
	MKNumberBadgeView *badgeFour;
	MKNumberBadgeView *badgeFive;
	MKNumberBadgeView *badgeSix;
	MKNumberBadgeView *badgeSeven;
	MKNumberBadgeView *badgeEight;
	MKNumberBadgeView *badgeNine;
	MKNumberBadgeView *badgeTen;
	
	MKNumberBadgeView *badgeMirrorOne;
	MKNumberBadgeView *badgeMirrorTwo;
	MKNumberBadgeView *badgeMirrorThree;
	MKNumberBadgeView *badgeMirrorFour;
	MKNumberBadgeView *badgeMirrorFive;
	MKNumberBadgeView *badgeMirrorSix;
	MKNumberBadgeView *badgeMirrorSeven;
	MKNumberBadgeView *badgeMirrorEight;
	MKNumberBadgeView *badgeMirrorNine;
	MKNumberBadgeView *badgeMirrorTen;
	
	
	//NSArray *badgeInFront;
	
	//Reachability* hostReach;
//	Reachability* internetReach;
//	Reachability* wifiReach;
	
}

@property (nonatomic, retain) AboutViewController *aboutView;
@property (nonatomic, retain) IBOutlet UIImageView *PPimageView;
@property (nonatomic, retain) IBOutlet UIImageView *powerPointsView;
@property (nonatomic, retain) UIPopoverController *ppphotoPickerPopover;
//@property (nonatomic, retain) UIPopoverController *PPgroupPickerPopover;
@property (nonatomic, retain) NSDictionary *plistDictionary;
@property (nonatomic, retain) NSDictionary *photoDictionary;
@property (nonatomic, retain) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic, retain) OFFlickrAPIContext *context;
//@property (nonatomic, retain) PowerPoints *powerPointsView;
@property (nonatomic, retain) UIPopoverController *photoPopover;
@property (nonatomic, retain) UIPopoverController *groupSearchPopover;
@property (nonatomic, retain) UIPopoverController *badgePopover;
@property (nonatomic, retain) UIPopoverController *infoCardPopover;
@property (nonatomic, retain) UIPopoverController *settingsPopover;
@property (nonatomic, retain) FlickrPhotoSearchController *flickrPhotoPickerView;
@property (nonatomic, retain) FlickrGroupPickerController *flickrGroupView;
@property (nonatomic, retain) FlickrGroupSearchController *flickrGroupSearchView;
@property (nonatomic, retain) SettingsViewController *settingsView;
@property (nonatomic, retain) PhotoInfoCard *photoInfoCardView;
@property (nonatomic, retain) ExternalPhotoInfoCard *mirrorInfoCardView;
@property (nonatomic, retain) UIPopoverController *exifPopover;
@property (nonatomic, retain) UIPopoverController *groupPopover;
@property (nonatomic, retain) ExifViewController *exifViewView;
@property (nonatomic, retain) UIWindow *externalDisplay;
@property (nonatomic, retain) IBOutlet UIWindow *externalWindow;
//@property (nonatomic, retain) ExternalMonitor *mirrorView;

@property (nonatomic, retain) IBOutlet UIImageView *mirrorImage;
@property (nonatomic, retain) UIImageView	*powerPointImageView;
@property (nonatomic, retain) UIImageView *powerPointMirrorView;

//@property (nonatomic, retain) NSArray *badgeInFront;
@property (nonatomic, retain) UIButton *badgeOneButton;
@property (nonatomic, retain) UIButton *badgeTwoButton;
@property (nonatomic, retain) UIButton *badgeThreeButton;
@property (nonatomic, retain) UIButton *badgeFourButton;
@property (nonatomic, retain) UIButton *badgeFiveButton;
@property (nonatomic, retain) UIButton *badgeSixButton;
@property (nonatomic, retain) UIButton *badgeSevenButton;
@property (nonatomic, retain) UIButton *badgeEightButton;
@property (nonatomic, retain) UIButton *badgeNineButton;
@property (nonatomic, retain) UIButton *badgeTenButton;

@property (nonatomic, retain) MKNumberBadgeView *badgeOne;
@property (nonatomic, retain) MKNumberBadgeView *badgeTwo;
@property (nonatomic, retain) MKNumberBadgeView *badgeThree;
@property (nonatomic, retain) MKNumberBadgeView *badgeFour;
@property (nonatomic, retain) MKNumberBadgeView *badgeFive;
@property (nonatomic, retain) MKNumberBadgeView *badgeSix;
@property (nonatomic, retain) MKNumberBadgeView *badgeSeven;
@property (nonatomic, retain) MKNumberBadgeView *badgeEight;
@property (nonatomic, retain) MKNumberBadgeView *badgeNine;
@property (nonatomic, retain) MKNumberBadgeView *badgeTen;

@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorOne;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorTwo;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorThree;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorFour;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorFive;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorSix;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorSeven;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorEight;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorNine;
@property (nonatomic, retain) MKNumberBadgeView *badgeMirrorTen;
//@property (nonatomic, retain) NSArray *badgeInFront;

//@property (nonatomic, retain) NSURL *photoURL;
//@property (nonatomic, retain) NSData *photoData;
//@property (nonatomic, retain) NSMutableArray *photoArray;
//Group Selection objects
//@property (nonatomic, retain) IBOutlet UILabel *groupPhotoCountSliderLabel;

//Group Selection actions
//-(IBAction) groupPickerButtonTapped:(id)sender;

//Settings Selection actions
-(IBAction) settingsButtonTapped:(id)sender;

//Group Search actions
-(IBAction) groupSearchButtonTapped:(id)sender;

//Photo Selection actions
-(IBAction) getPhotoListFromFlickr:(id)sender;

//Get the photo's EXIF data
-(IBAction) getPhotoEXIFFromFlickr:(id)sender;

//Power Points overlay
-(IBAction) showPowerPoints:(id)sender;
-(void) sizePowerPoints;
-(void) shiftBadges;
-(void) addMirrorBadge:(int)badgeNumber;
-(void) addBadge:(int)badgeNumber;
-(void) syncBadges;
-(void) syncSingleBadge:(MKNumberBadgeView *)iPadBadge andProjectorBadge:(MKNumberBadgeView *)projectorBadge;

//-(UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

-(IBAction) showInfoView:(id)sender;

-(IBAction) infoCardButtonTapped:(id)sender;

-(void) removeInfoCard;

-(IBAction) changeBadgeState:(id)sender;
@end

