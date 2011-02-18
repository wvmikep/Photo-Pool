//
//  Photo_PoolViewController.m
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

#import "Photo_PoolViewController.h"
#import "FlickrGroupPickerController.h"

@implementation Photo_PoolViewController

@synthesize PPimageView, powerPointsView;
@synthesize ppphotoPickerPopover;
//@synthesize PPgroupPickerPopover;
@synthesize plistDictionary;
@synthesize photoDictionary;
@synthesize flickrRequest;
@synthesize context;
@synthesize photoPopover;
@synthesize groupPopover, badgePopover;
@synthesize powerPointImageView, powerPointMirrorView;
@synthesize flickrGroupView;
//@synthesize powerPointsView;
@synthesize flickrPhotoPickerView;
@synthesize exifViewView;
@synthesize exifPopover;
@synthesize externalDisplay;
@synthesize mirrorImage;
@synthesize aboutView;
@synthesize badgeOne,badgeTwo,badgeThree,badgeFour,badgeFive,badgeSix,badgeSeven,badgeEight,badgeNine,badgeTen;
@synthesize badgeMirrorOne,badgeMirrorTwo,badgeMirrorThree,badgeMirrorFour,badgeMirrorFive,badgeMirrorSix,badgeMirrorSeven,badgeMirrorEight,badgeMirrorNine,badgeMirrorTen;
@synthesize badgeOneButton, badgeTwoButton, badgeThreeButton, badgeFourButton, badgeFiveButton, badgeSixButton, badgeSevenButton, badgeEightButton, badgeNineButton, badgeTenButton;
@synthesize infoCardPopover, photoInfoCardView, mirrorInfoCardView;
//@synthesize badgeInFront;
//, mirrorView;
//@synthesize photoURL;
//@synthesize photoData;
//@synthesize photoArray;

// Group Selection Objects
@synthesize externalWindow;
@synthesize settingsView, settingsPopover;

// NEW!!!!  release these!!!
@synthesize groupSearchPopover;
@synthesize flickrGroupSearchView;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}


-(void) setPpphotoPickerPopover:(UIPopoverController *)newPopover {
	
	[newPopover retain];
	[ppphotoPickerPopover release];
	ppphotoPickerPopover = newPopover;
	
}
-(void) setFlickrPhotoPickerView:(FlickrPhotoPickerController *)newPhotoPicker {
	
	[newPhotoPicker retain];
	[flickrPhotoPickerView release];
	flickrPhotoPickerView = newPhotoPicker;
	
}*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//Group state
	sharedGroupState = [SingletonFlickrGroup sharedGroupStateInstance];

	// Load the data from the settings bundle
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *sliderStringValue = [defaults objectForKey:@"photoCount"];
	float sliderValue = [sliderStringValue floatValue];
	sliderValue += 0.5;
	[sharedGroupState setGroupPhotoCountAsInt:(int)sliderValue];
	[sharedGroupState setGroupPhotoCountAsIntStored:[sharedGroupState groupPhotoCountAsInt]];
	if ([sharedGroupState groupPhotoCountAsInt] == 0) {
		[sharedGroupState setGroupPhotoCountAsInt:10];
	}
	
	if ([sharedGroupState groupID] == nil) {
		//NSMutableString *tempGroupID = [[NSString alloc] initWithString:@"904732@N20"];
		[sharedGroupState setValidGroupName:0];
	}
	
	mirrorState = NO;
	powerPointsView.hidden = YES;
	
	//Now, if there's an external screen, we need to find its modes, itereate through them and find the highest one. Once we have that mode, break out, and set the UIWindow.
	
	// Check for external screen.
	if ([[UIScreen screens] count] > 1) {
		//[self log:@"Found an external screen."];
		
		// Internal display is 0, external is 1.
		externalScreen = [[[UIScreen screens] objectAtIndex:1] retain];
		//[self log:[NSString stringWithFormat:@"External screen: %@", externalScreen]];
		
		screenModes = [externalScreen.availableModes retain];
		//[self log:[NSString stringWithFormat:@"Available modes: %@", screenModes]];
		
		// Allow user to choose from available screen-modes (pixel-sizes).
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"External Display Size" 
														 message:@"Choose a size for the external display." 
														delegate:self 
											   cancelButtonTitle:nil 
											   otherButtonTitles:nil] autorelease];
		for (UIScreenMode *mode in screenModes) {
			CGSize modeScreenSize = mode.size;
			[alert addButtonWithTitle:[NSString stringWithFormat:@"%.0f x %.0f pixels", modeScreenSize.width, modeScreenSize.height]];
		}
		[alert show];
		
	} else {
		//[self log:@"External screen not found."];
	}
	
	//Notification center for the movement of badges
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncBadges) name:@"littleBadgeMoved" object:nil];
	//Notification center for the removal of the mirror info card
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeInfoCard) name:@"projectorInfoCardDone" object:nil];

	// end 2nd screen
	
	
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:@"flickr.plist"];
	plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
	NSString *flickrKey = [plistDictionary objectForKey:@"flickr_key"];
	NSString *flickrSecret = [plistDictionary objectForKey:@"flickr_secret"];
	
	context = [[OFFlickrAPIContext alloc] initWithAPIKey:flickrKey sharedSecret:flickrSecret];
	
	flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];
	
	
	// playing around to get a feel for the flickr api
	// get a list of the most recent photos
	[flickrRequest setDelegate:self];
	
	[flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent"  arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"per_page", nil]];
	NSLog(@"Asked Flickr for the most recent photos data");
	
	badgeOneInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeTwoInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeThreeInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeFourInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeFiveInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeSixInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeSevenInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeEightInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeNineInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	badgeTenInFront = [[NSMutableString alloc] initWithFormat:@"0"];
	
//	[[sharedGroupState badgeInFront] insertObject:@"0" atIndex:0];
	/* badgeInFront = [NSArray arrayWithObjects:badgeOneInFront, 
					badgeTwoInFront, 
					badgeThreeInFront, 
					badgeFourInFront, 
					badgeFiveInFront, 
					badgeSixInFront, 
					badgeSevenInFront, 
					badgeEightInFront, 
					badgeNineInFront, 
					badgeTenInFront, nil];
 	*/
	[super viewDidLoad];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIScreenMode *desiredMode = [screenModes objectAtIndex:buttonIndex];
	//	[self log:[NSString stringWithFormat:@"Setting mode: %@", desiredMode]];
	externalScreen.currentMode = desiredMode;
	
	//	[self log:@"Assigning externalWindow to externalScreen."];
	externalWindow.screen = externalScreen;
	
	[screenModes release];
	[externalScreen release];
	
	CGRect rect = CGRectZero;
	rect.size = desiredMode.size;
	externalWidth = rect.size.width;
	externalHeight = rect.size.height;
	externalWindow.frame = rect;
	externalWindow.clipsToBounds = YES;
	
	//[self log:@"Displaying externalWindow on externalScreen."];
	//UIWindow   *mainWindow = [[[UIApplication sharedApplication] delegate] window];

	/*ExternalMonitor *newMirrorView = [[ExternalMonitor alloc] initWithNibName:@"ExternalMonitor" bundle:nil];
	[self setMirrorView:newMirrorView];
	[newMirrorView release], newMirrorView = nil;
	
	UIImageView *newMirror = [[UIImageView alloc] initWithFrame:rect];
	[self setMirrorImage:newMirror];
	[newMirror release], newMirror = nil;
	
	[externalWindow addSubview:mirrorView.view];
	*/
	externalWindow.hidden = NO;
	mirrorState = YES;
	[externalWindow makeKeyAndVisible];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
		if (powerPointImageView != nil) {
			[self sizePowerPoints];
		}
	[self shiftBadges];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.ppphotoPickerPopover = nil;
	self.plistDictionary = nil;
	self.photoDictionary = nil;
	self.flickrRequest = nil;
	self.context = nil;
	self.photoPopover = nil;
	self.powerPointsView = nil;
	self.flickrPhotoPickerView = nil;
	self.exifViewView = nil;
	self.exifPopover = nil;
	self.externalDisplay = nil;
	self.mirrorImage = nil;
	//self.mirrorView = nil;
	self.externalWindow = nil;
	self.PPimageView = nil;
	self.flickrGroupView = nil;
	self.aboutView = nil;
	self.groupPopover = nil;
	self.powerPointImageView = nil;
	self.badgeOne = nil;
	self.badgeTwo = nil;
	self.badgeThree = nil;
	self.badgeFour = nil;
	self.badgeFive = nil;
	self.badgeSix = nil;
	self.badgeSeven = nil;
	self.badgeEight = nil;
	self.badgeNine = nil;
	self.badgeTen = nil;
	self.badgeMirrorOne = nil;
	self.badgeMirrorTwo = nil;
	self.badgeMirrorThree = nil;
	self.badgeMirrorFour = nil;
	self.badgeMirrorFive = nil;
	self.badgeMirrorSix = nil;
	self.badgeMirrorSeven = nil;
	self.badgeMirrorEight = nil;
	self.badgeMirrorNine = nil;
	self.badgeMirrorTen = nil;
	
	self.badgeOneButton = nil;
	self.badgeTwoButton = nil;
	self.badgeThreeButton = nil;
	self.badgeFourButton = nil;
	self.badgeFiveButton = nil;
	self.badgeSixButton = nil;
	self.badgeSevenButton = nil;
	self.badgeEightButton = nil;
	self.badgeNineButton = nil;
	self.badgeTenButton = nil;
	
	self.infoCardPopover = nil;
	self.photoInfoCardView = nil;
	self.mirrorInfoCardView = nil;
	
	self.settingsPopover = nil;
	self.settingsView = nil;
}


- (void)dealloc {
	[groupPopover release];
	[aboutView release];
	[flickrGroupView release];
	[PPimageView release];
	[ppphotoPickerPopover release];
	[plistDictionary release];
	[photoDictionary release];
	[flickrRequest release];
	[context release];
	[photoPopover release];
	[powerPointsView release];
	[flickrPhotoPickerView release];
	[exifViewView release];
	[exifPopover release];
	[externalDisplay release];
	[mirrorImage release];
	//[mirrorView release];
	[externalWindow release];
	[powerPointImageView release];
//	[photoURL release];
//	[photoData release];
//	[photoArray release];
//	[finalPath release];
//	[plistDictionary release];
//	[flickrKey release];
//	[flickrSecret release];
//	[path release];
	[badgeOne release];
	[badgeTwo release];
	[badgeThree release];
	[badgeFour release];
	[badgeFive release];
	[badgeSix release];
	[badgeSeven release];
	[badgeEight release];
	[badgeNine release];
	[badgeTen release];
	[badgeMirrorOne release];
	[badgeMirrorTwo release];
	[badgeMirrorThree release];
	[badgeMirrorFour release];
	[badgeMirrorFive release];
	[badgeMirrorSix release];
	[badgeMirrorSeven release];
	[badgeMirrorEight release];
	[badgeMirrorNine release];
	[badgeMirrorTen release];
	
	[badgeOneButton release];
	[badgeTwoButton release];
	[badgeThreeButton release];
	[badgeFourButton release];
	[badgeFiveButton release];
	[badgeSixButton release];
	[badgeSevenButton release];
	[badgeEightButton release];
	[badgeNineButton release];
	[badgeTenButton release];
	[infoCardPopover release];
	[photoInfoCardView release];
	[mirrorInfoCardView release];
	
	[settingsPopover release];
	[settingsView release];
	
    [super dealloc];
}
#pragma mark -

-(IBAction) showInfoView:(id)sender {
	AboutViewController *newAboutView = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	[self setAboutView:newAboutView];
	[newAboutView release], newAboutView = nil;
	
	[aboutView setModalPresentationStyle:UIModalPresentationFormSheet];
	[self presentModalViewController:aboutView animated:YES];
	 
}
/*
-(IBAction) groupPickerButtonTapped:(id)sender {
	// Method called when the group picker button is pressed.
	// if the popover is visible, dismiss it.
	if ([ppphotoPickerPopover isPopoverVisible]) {
		[ppphotoPickerPopover dismissPopoverAnimated:YES];
	}
	if ([infoCardPopover isPopoverVisible]) {
		[infoCardPopover dismissPopoverAnimated:YES];
	}
	
	if ([groupPopover isPopoverVisible]) {
		NSLog(@"Yep, visible!");
		[groupPopover dismissPopoverAnimated:YES];
	} else {
		FlickrGroupPickerController *newFlickrGroupPickerView = [[FlickrGroupPickerController alloc] initWithNibName:@"FlickrGroupPickerController" bundle:nil];
		[self setFlickrGroupView:newFlickrGroupPickerView];
		[newFlickrGroupPickerView release], newFlickrGroupPickerView = nil;
	
		UIPopoverController *newGroupPopover = [[UIPopoverController alloc] initWithContentViewController:flickrGroupView];
		[self setGroupPopover:newGroupPopover];
		[newGroupPopover release], newGroupPopover = nil;
	
		[groupPopover setDelegate:self];
		[flickrGroupView setGroupPop:groupPopover];
		[groupPopover setPopoverContentSize:CGSizeMake(400.0, 130.0)];
		[groupPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

	}
	//[flickrGroupPickerView release];
}*/

-(IBAction) settingsButtonTapped:(id)sender {
	if ([ppphotoPickerPopover isPopoverVisible]) {
		[ppphotoPickerPopover dismissPopoverAnimated:YES];
	} else if ([infoCardPopover isPopoverVisible]) {
		[infoCardPopover dismissPopoverAnimated:YES];
	} else if ([groupSearchPopover isPopoverVisible]) {
		[groupSearchPopover dismissPopoverAnimated:YES];
	} else if ([exifPopover isPopoverVisible]) {
		[exifPopover dismissPopoverAnimated:YES];
	} else if ([infoCardPopover isPopoverVisible]) {
		[infoCardPopover dismissPopoverAnimated:YES];
	} else if ([settingsPopover isPopoverVisible]) {
		[settingsPopover dismissPopoverAnimated:YES];
	} else {
		SettingsViewController *newSettingsView = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
		[self setSettingsView:newSettingsView];
		[newSettingsView release], newSettingsView = nil;
		
		UIPopoverController *newSettingsPopover = [[UIPopoverController alloc] initWithContentViewController:settingsView];
		[self setSettingsPopover:newSettingsPopover];
		[newSettingsPopover release], newSettingsPopover = nil;
		
		[settingsPopover setDelegate:self];
		[settingsView setPopover:settingsPopover];
		[settingsPopover setPopoverContentSize:CGSizeMake(320.0, 100.0)];
		[settingsPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
	}

	
}

-(IBAction) groupSearchButtonTapped:(id)sender {
	// if the popover is visible, dismiss it.
	if ([ppphotoPickerPopover isPopoverVisible]) {
		[ppphotoPickerPopover dismissPopoverAnimated:YES];
	} else if ([infoCardPopover isPopoverVisible]) {
		[infoCardPopover dismissPopoverAnimated:YES];
	} else if ([infoCardPopover isPopoverVisible]) {
		[infoCardPopover dismissPopoverAnimated:YES];
	} else if ([settingsPopover isPopoverVisible]) {
		[settingsPopover dismissPopoverAnimated:YES];
	} else if ([exifPopover isPopoverVisible]) {
		[exifPopover dismissPopoverAnimated:YES];
	} else if ([groupSearchPopover isPopoverVisible]) {
		NSLog(@"Yep, visible!");
		[groupSearchPopover dismissPopoverAnimated:YES];
	} else {
		FlickrGroupSearchController *newFlickrGroupSearchView = [[FlickrGroupSearchController alloc] initWithNibName:@"FlickrGroupSearchController" bundle:nil];
		[self setFlickrGroupSearchView:newFlickrGroupSearchView];
		[newFlickrGroupSearchView release], newFlickrGroupSearchView = nil;
		
		UIPopoverController *newGroupPopover = [[UIPopoverController alloc] initWithContentViewController:flickrGroupSearchView];
		[self setGroupSearchPopover:newGroupPopover];
		[newGroupPopover release], newGroupPopover = nil;
		
		[groupSearchPopover setDelegate:self];
		[flickrGroupSearchView setGroupPop:groupSearchPopover];
		//[groupSearchPopover setPopoverContentSize:CGSizeMake(400.0, 130.0)];
		[groupSearchPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
	}
}

-(void)infoCardButtonTapped:(id)sender {
	if ([sharedGroupState photoSelected] == 1) {
		if ([ppphotoPickerPopover isPopoverVisible]) {
			[ppphotoPickerPopover dismissPopoverAnimated:YES];
		} else if ([groupSearchPopover isPopoverVisible]) {
			[groupSearchPopover dismissPopoverAnimated:YES];
		} else if ([settingsPopover isPopoverVisible]) {
			[settingsPopover dismissPopoverAnimated:YES];
		} else if ([exifPopover isPopoverVisible]) {
			[exifPopover dismissPopoverAnimated:YES];
		} else if ([infoCardPopover isPopoverVisible]) {
			[infoCardPopover dismissPopoverAnimated:YES];
		} else if ([settingsPopover isPopoverVisible]) {
			[settingsPopover dismissPopoverAnimated:YES];
		} else {
			NSLog(@"Trying to create the popover!");
			PhotoInfoCard *newInfoCardView = [[PhotoInfoCard alloc] initWithNibName:@"PhotoInfoCard" bundle:nil];
			[self setPhotoInfoCardView:newInfoCardView];
			[newInfoCardView release], newInfoCardView = nil;
			
			UIPopoverController *newInfoCardPopover = [[UIPopoverController alloc] initWithContentViewController:photoInfoCardView];
			[self setInfoCardPopover:newInfoCardPopover];
			[newInfoCardPopover release], newInfoCardPopover = nil;
			
			[infoCardPopover setDelegate:self];
			[photoInfoCardView setPopover:infoCardPopover];
			[infoCardPopover setPopoverContentSize:CGSizeMake(320.0, 480.0)];
			[infoCardPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			
			if (mirrorState) {
				ExternalPhotoInfoCard *newMirrorCardView = [[ExternalPhotoInfoCard alloc] initWithNibName:@"ExternalPhotoInfoCard" bundle:nil];
				[self setMirrorInfoCardView:newMirrorCardView];
				[newMirrorCardView release], newMirrorCardView = nil;
				
				[[mirrorInfoCardView view] setFrame:CGRectMake(20.0, 20.0, 320.0, 480.0)];
				[[[mirrorInfoCardView view] layer] setBorderColor: [[UIColor blackColor] CGColor]];
				[[[mirrorInfoCardView view] layer] setBorderWidth: 2.0];
				[[mirrorInfoCardView view] setHidden:NO];
				[externalWindow addSubview:[mirrorInfoCardView view]];
			}
		}
	} else {
		NSString *exifAlertMessage = [[NSString alloc] initWithString:@"You need to select a photo first."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"Missing Photo" message:exifAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[exifAlertMessage release];
		
	}
	
}

-(void)getPhotoListFromFlickr:(id)sender {

	// if a valid flickr group has been selected from the modal presentation form sheet...
	if ([sharedGroupState validGroupName] == 1) {
		
		// Set flag to note that photos haven't been pulled in from flickr yet
		// in the hopes of being able to display "Loading..." and an Activity Monitor
		//[sharedGroupState setLoadingPhotos:YES];
		
		// if the popover is visible, dismiss it.
		if ([groupSearchPopover isPopoverVisible]) {
			[groupSearchPopover dismissPopoverAnimated:YES];
		} else if ([exifPopover isPopoverVisible]) {
			[exifPopover dismissPopoverAnimated:YES];
		} else if ([exifPopover isPopoverVisible]) {
			[exifPopover dismissPopoverAnimated:YES];
		} else if ([ppphotoPickerPopover isPopoverVisible]) {
			[ppphotoPickerPopover dismissPopoverAnimated:YES];
		} else if ([infoCardPopover isPopoverVisible]) {
			[infoCardPopover dismissPopoverAnimated:YES];
		} else if ([settingsPopover isPopoverVisible]) {
			[settingsPopover dismissPopoverAnimated:YES];
		} else {
			FlickrPhotoSearchController *newPhotoPicker = [[FlickrPhotoSearchController alloc] initWithNibName:@"FlickrPhotoSearchController" bundle:nil];
			[self setFlickrPhotoPickerView:newPhotoPicker];
			[newPhotoPicker release], newPhotoPicker = nil;
			
			UIPopoverController *newPopover = [[UIPopoverController alloc] initWithContentViewController:flickrPhotoPickerView];
			[self setPpphotoPickerPopover:newPopover];
			[newPopover release], newPopover = nil;
			
			[ppphotoPickerPopover setDelegate:self];
			
			// Give FlickrPhotoPickerController what it needs to dismiss its popover
			//and to display the selected image in the main view 
			[flickrPhotoPickerView setPopover:ppphotoPickerPopover];
			[flickrPhotoPickerView setMainImage:PPimageView];
			[flickrPhotoPickerView setMirrorImage:mirrorImage];
			[flickrPhotoPickerView setMirrorState:mirrorState];

			// display the popover
			NSLog(@"Nope, not visible!");
			[ppphotoPickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
	
		//[flickrPhotoPickerView release];
	} else {
		// Since a group is necessary for this app, display alert and take the user to the settings sheet
		NSString *groupAlertMessage = [[NSString alloc] initWithString:@"You need to select a valid flickr group first."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"Missing flickr Group" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[groupAlertMessage release];
		
	/*	FlickrGroupPickerController *flickrGroupPickerView = [[FlickrGroupPickerController alloc] initWithNibName:@"FlickrGroupPickerController" bundle:nil];
		[flickrGroupPickerView setModalPresentationStyle:UIModalPresentationFormSheet];
		[self presentModalViewController:flickrGroupPickerView animated:YES];
		
		[flickrGroupPickerView release]; */
	}

}

-(void)getPhotoEXIFFromFlickr:(id)sender {
	if ([sharedGroupState photoSelected] == 1) {
		// if the popover is visible, dismiss it.
		if ([ppphotoPickerPopover isPopoverVisible]) {
			[ppphotoPickerPopover dismissPopoverAnimated:YES];
		} else if ([infoCardPopover isPopoverVisible]) {
			[infoCardPopover dismissPopoverAnimated:YES];
		} else if ([groupSearchPopover isPopoverVisible]) {
			[groupSearchPopover dismissPopoverAnimated:YES];
		} else if ([exifPopover isPopoverVisible]) {
			[exifPopover dismissPopoverAnimated:YES];
		} else if ([infoCardPopover isPopoverVisible]) {
			[infoCardPopover dismissPopoverAnimated:YES];
		} else if ([settingsPopover isPopoverVisible]) {
			[settingsPopover dismissPopoverAnimated:YES];
		} else {

		ExifViewController *newExifView = [[ExifViewController alloc] initWithStyle:UITableViewStyleGrouped];
		[self setExifViewView:newExifView];
		[newExifView release], newExifView = nil;
		
		UIPopoverController *newExifPopover = [[UIPopoverController alloc] initWithContentViewController:exifViewView];
		[self setExifPopover:newExifPopover];
		[newExifPopover release], newExifPopover = nil;
		
		[exifPopover setDelegate:self];
		[exifPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
//		[exifViewView release];
		}
	} else {
		NSString *exifAlertMessage = [[NSString alloc] initWithString:@"You need to select a photo first."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"Missing Photo" message:exifAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[exifAlertMessage release];
		
	}
}

-(void)showPowerPoints:(id)sender {
	if ([sharedGroupState photoSelected] == 1) {

		if (powerPointImageView != nil) {
			if (powerPointImageViewInFront) {
				NSLog(@"The powerpoints were not hidden.  Hiding now.");
				[[self view] sendSubviewToBack:powerPointImageView];
				//powerPointImageView.hidden = YES;
				powerPointImageViewInFront = NO;
				
				//External monitor
				if (powerPointMirrorView != nil) {
					[externalWindow sendSubviewToBack:powerPointMirrorView];
					powerPointMirrorViewInFront = NO;
				}
				
				return;
			} else {
				NSLog(@"The powerpoints were hidden.  Unhiding now.");
				[[self view] bringSubviewToFront:powerPointImageView];

				//External monitor
				if (powerPointMirrorView != nil) {
					[externalWindow bringSubviewToFront:powerPointMirrorView];
					powerPointMirrorViewInFront = YES;
				}
				
				 [self sizePowerPoints];
				 powerPointImageViewInFront = YES;
					 
				 NSLog(@"Subviews: %@", [[self view] subviews]);
					 
				 powerPointImageViewIndex = [[[self view] subviews] indexOfObject:powerPointImageView];
				if (powerPointMirrorView != nil) {
					powerPointMirrorViewIndex = [[externalWindow subviews] indexOfObject:powerPointMirrorView];
				}	 
				
				 NSLog(@"Index of subview: %i", powerPointImageViewIndex);

				 return;
			}

		} else {
			NSLog(@"The powerpoints were not created.");

			UIImageView	*tempPowerPointImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powerpointslightportrait.png"]];
			[self setPowerPointImageView:tempPowerPointImageView];
			[tempPowerPointImageView release], tempPowerPointImageView = nil;
			
			if (mirrorState) {
				UIImageView *tempPowerPointMirrorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powerpointslightportrait.png"]];
				[self setPowerPointMirrorView:tempPowerPointMirrorView];
				[tempPowerPointMirrorView release], tempPowerPointMirrorView = nil;
			}
			
			[self sizePowerPoints];
			[[self view] addSubview:powerPointImageView];
			powerPointImageViewInFront = YES;
			if (mirrorState) {
				[externalWindow addSubview:powerPointMirrorView];
				powerPointMirrorViewInFront = YES;
			}
		}


		
		NSLog(@"Subviews: %@", [[self view] subviews]);

		powerPointImageViewIndex = [[[self view] subviews] indexOfObject:powerPointImageView];
		if (mirrorState) {
			powerPointMirrorViewIndex = [[externalWindow subviews] indexOfObject:powerPointMirrorView];
		}
		
		NSLog(@"Index of subview: %i", powerPointImageViewIndex);
	} else {
		NSString *exifAlertMessage = [[NSString alloc] initWithString:@"You need to select a photo first."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"Missing Photo" message:exifAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[exifAlertMessage release];
		
	}
	
}

-(void) sizePowerPoints {
	
	UIImage *tempPhoto = [PPimageView image];
	CGSize tempPhotoImageSize = tempPhoto.size;
	
	CGFloat photoHeight = tempPhotoImageSize.height;
	CGFloat photoWidth = tempPhotoImageSize.width;
	
	CGFloat mirrorHeight = tempPhotoImageSize.height;
	CGFloat mirrorWidth = tempPhotoImageSize.width;
	
	NSLog(@"Height:  %f, Width:  %f", photoHeight, photoWidth);
	
	CGFloat deviceWidth = 0.0;
	CGFloat deviceHeight = 0.0;
	
	//figure out which orientation the image is.  Then, determine the scaled size.
	CGFloat imageScaleFactor = 1.0;
	CGFloat mirrorScaleFactor = 1.0;
	
	if (self.interfaceOrientation == UIDeviceOrientationPortrait) {
		deviceWidth = 768.0;
		deviceHeight = 916.0;
	} else {
		deviceWidth = 1024.0;
		deviceHeight = 660.0;
	}
	

	if (deviceWidth < photoWidth) {
		// landscape image while in portrait mode
		imageScaleFactor = photoWidth / deviceWidth;
	} else if (deviceHeight < photoHeight) {
		// portrait image while in landscape mode
		imageScaleFactor = photoHeight / deviceHeight;
	} else {
		//image is smaller than an iPad's screen (e.g. profile image)
		CGFloat xScaleFactor = photoWidth / deviceWidth;
		CGFloat yScaleFactor = photoHeight / deviceHeight;
		if (xScaleFactor > yScaleFactor) {
			imageScaleFactor = xScaleFactor;
		} else {
			imageScaleFactor = yScaleFactor;
		}

	}

	photoWidth /= imageScaleFactor;
	photoHeight /= imageScaleFactor;
	
	NSLog(@"Scaling factor: %f", imageScaleFactor);
	
	NSLog(@"New Height:  %f, New Width:  %f", photoHeight, photoWidth);
	
	CGFloat topLeftX = (deviceWidth - photoWidth) / 2;
	CGFloat topLeftY = ((deviceHeight - photoHeight) /2)+44;
	NSLog(@"Top Left X:  %f, Top Left Y:  %f", topLeftX, topLeftY);
	
//
	
	[powerPointImageView setFrame:CGRectMake(topLeftX, topLeftY, photoWidth, photoHeight)];

	// ++++++++++ External Monitor +++++++++++++++
	if (mirrorState) {
		
		CGFloat xMirrorFactor = mirrorImage.image.size.width / externalWidth;
		CGFloat yMirrorFactor = mirrorImage.image.size.height / externalHeight;
		if (xMirrorFactor > yMirrorFactor) {
			mirrorScaleFactor = xMirrorFactor;
		} else {
			mirrorScaleFactor = yMirrorFactor;
		}

	//	mirrorWidth = (mirrorWidth / mirrorScaleFactor) /2;
	//	mirrorHeight = (mirrorHeight / mirrorScaleFactor) /2;
		
		mirrorWidth = mirrorImage.image.size.width / mirrorScaleFactor;
		mirrorHeight = mirrorImage.image.size.height / mirrorScaleFactor;
		
		CGFloat topLeftMirrorX = (externalWidth - mirrorWidth) / 2;
		CGFloat topLeftMirrorY = (externalHeight - mirrorHeight) / 2;
		
		
		[powerPointMirrorView setFrame:CGRectMake(topLeftMirrorX, topLeftMirrorY, mirrorWidth, mirrorHeight)];
	}
	
	// ++++++++++ External Monitor +++++++++++++++
	
	return;
}

-(void) shiftBadges {
	CGFloat deviceWidth = 0.0;
	CGFloat deviceHeight = 0.0;

	if (self.interfaceOrientation == UIDeviceOrientationPortrait) {
		deviceWidth = 768.0;
		deviceHeight = 916.0;
	} else {
		deviceWidth = 1024.0;
		deviceHeight = 660.0;
	}
	

	//if (badgeOne != nil) {
	if (badgeOne.frame.origin.x > deviceWidth || badgeOne.frame.origin.y > deviceHeight) {
		[badgeOne setFrame:CGRectMake(0.0, 44.0, 44.0, 44.0)];
	}
	if (badgeTwo.frame.origin.x > deviceWidth || badgeTwo.frame.origin.y > deviceHeight) {
		[badgeTwo setFrame:CGRectMake(44.0, 44.0, 44.0, 44.0)];
	}
	if (badgeThree.frame.origin.x > deviceWidth || badgeThree.frame.origin.y > deviceHeight) {
		[badgeThree setFrame:CGRectMake(88.0, 44.0, 44.0, 44.0)];
	}
	if (badgeFour.frame.origin.x > deviceWidth || badgeFour.frame.origin.y > deviceHeight) {
		[badgeFour setFrame:CGRectMake(0.0, 88.0, 44.0, 44.0)];
	}
	if (badgeFive.frame.origin.x > deviceWidth || badgeFive.frame.origin.y > deviceHeight) {
		[badgeFive setFrame:CGRectMake(44.0, 88.0, 44.0, 44.0)];
	}
	if (badgeSix.frame.origin.x > deviceWidth || badgeSix.frame.origin.y > deviceHeight) {
		[badgeSix setFrame:CGRectMake(88.0, 88.0, 44.0, 44.0)];
	}
	if (badgeSeven.frame.origin.x > deviceWidth || badgeSeven.frame.origin.y > deviceHeight) {
		[badgeSeven setFrame:CGRectMake(0.0, 132.0, 44.0, 44.0)];
	}
	if (badgeEight.frame.origin.x > deviceWidth || badgeEight.frame.origin.y > deviceHeight) {
		[badgeEight setFrame:CGRectMake(44.0, 132.0, 44.0, 44.0)];
	}
	if (badgeNine.frame.origin.x > deviceWidth || badgeNine.frame.origin.y > deviceHeight) {
		[badgeNine setFrame:CGRectMake(88.0, 132.0, 44.0, 44.0)];
	}
	if (badgeTen.frame.origin.x > deviceWidth || badgeTen.frame.origin.y > deviceHeight) {
		[badgeTen setFrame:CGRectMake(0.0, 176.0, 44.0, 44.0)];
	}
		
	//}
	
}

-(void) syncBadges {
// do stuff	
	NSLog(@"Time to sync the badges!");
	// ++++++++++ External Monitor +++++++++++++++
	if (mirrorState) {
		for (int i=1; i <= 10; i++) {
			if (i == 1) {
				[self syncSingleBadge:badgeOne andProjectorBadge:badgeMirrorOne];
			} else if (i == 2) {
				[self syncSingleBadge:badgeTwo andProjectorBadge:badgeMirrorTwo];
			} else if (i == 3) {
				[self syncSingleBadge:badgeThree andProjectorBadge:badgeMirrorThree];
			} else if (i == 4) {
				[self syncSingleBadge:badgeFour andProjectorBadge:badgeMirrorFour];
			} else if (i == 5) {
				[self syncSingleBadge:badgeFive andProjectorBadge:badgeMirrorFive];
			} else if (i == 6) {
				[self syncSingleBadge:badgeSix andProjectorBadge:badgeMirrorSix];
			} else if (i == 7) {
				[self syncSingleBadge:badgeSeven andProjectorBadge:badgeMirrorSeven];
			} else if (i == 8) {
				[self syncSingleBadge:badgeEight andProjectorBadge:badgeMirrorEight];
			} else if (i == 9) {
				[self syncSingleBadge:badgeNine andProjectorBadge:badgeMirrorNine];
			} else {
				[self syncSingleBadge:badgeTen andProjectorBadge:badgeMirrorTen];
			}

		}
	}
	
	// ++++++++++ External Monitor +++++++++++++++
	
}

-(void) syncSingleBadge:(MKNumberBadgeView *)iPadBadge andProjectorBadge:(MKNumberBadgeView *)projectorBadge {
	CGFloat deviceWidth = 0.0;
	CGFloat deviceHeight = 0.0;
	if (self.interfaceOrientation == UIDeviceOrientationPortrait) {
		deviceWidth = 768.0;
		deviceHeight = 1024.0;
	} else {
		deviceWidth = 1024.0;
		deviceHeight = 768.0;
	}
	
	
	CGFloat deviceMidY = deviceHeight / 2;
	CGFloat externalMidY = externalHeight / 2;
	
	CGFloat deviceMidX = deviceWidth / 2;
	CGFloat externalMidX = externalWidth / 2;
	
	CGFloat deviceDiffY = deviceMidY - iPadBadge.frame.origin.y;
	CGFloat deviceScaleY = deviceDiffY / (PPimageView.image.size.height / 2);
	
	CGFloat deviceDiffX = deviceMidX - iPadBadge.frame.origin.x;
	CGFloat deviceScaleX = deviceDiffX / (PPimageView.image.size.width / 2);
	
	CGFloat externalDiffY = deviceScaleY * (mirrorImage.image.size.height / 2);
	
	CGFloat externalDiffX = deviceScaleX * (mirrorImage.image.size.width / 2);
	
	CGFloat newY = externalMidY - externalDiffY + 11;
	
	CGFloat newX = externalMidX - externalDiffX;
	
	
	[projectorBadge setFrame:CGRectMake(newX, newY, 44.0, 44.0)];
	
}

#pragma mark -
#pragma mark Scale and crop image



/*
-(IBAction) getPhotoFromLibrary:(id)sender {
	// Create the image picker
	UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
	photoPicker.delegate = self;
	photoPicker.allowsEditing = NO;
	photoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	
	// Put the photo picker in the popover and display it
	self.PPphotoPickerPopover = [[[UIPopoverController alloc] initWithContentViewController:photoPicker] autorelease];
	[self.PPphotoPickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	
}

#pragma mark -
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	PPimageView.image = image;
	PPimageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.PPphotoPickerPopover dismissPopoverAnimated:YES];
}
*/
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
	
    NSLog(@"popover about to be dismissed");
	[flickrGroupView validateAndCloseButtonTapped:(id)popoverController];
    return YES;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	NSLog(@"popover dismissed!");
	
	// Save the user defaults
	if ([sharedGroupState groupPhotoCountAsInt] != [sharedGroupState groupPhotoCountAsIntStored]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *newCount = [NSString stringWithFormat:@"%i",[sharedGroupState groupPhotoCountAsInt]];
		[defaults setObject:newCount forKey:@"photoCount"];
		[sharedGroupState setGroupPhotoCountAsIntStored:[sharedGroupState groupPhotoCountAsInt]];
	}
	
	// See if the external info card exists and remove it
	[self removeInfoCard];
}

-(void)removeInfoCard {
	if (mirrorInfoCardView != nil) {
		[[mirrorInfoCardView view] setHidden:YES];
		mirrorInfoCardView = nil;
	}
}

-(void)searchFlickrGroups:(id)sender {
	NSLog(@"Sending getRecent request to flickr...");
	//[flickrRequest callAPIMethodWithGET:@"flickr.groups.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[FlickrGroupPickerController groupName.text], nil]];
	
}

-(void)flickrRequest:(OFFlickrAPIContext *)inRequest didFailWithError:(NSError *)inError; {
	NSLog(@"Error Encountered with flickr!");
	NSString *echoAlertMessage = [[NSString alloc] initWithString:@"Unable to connect to flickr.  Please ensure you are connected to the Internet."];
	UIAlertView *echoAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:echoAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[echoAlert show];
	[echoAlert release];
	[echoAlertMessage release];
}

-(void)getPhotoFromFlickr:(id)sender {
	
}
#pragma mark -
#pragma mark flickr Methods
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	//NSDictionary *flickrTestDict = [[NSDictionary alloc] initWithDictionary:inResponseDictionary];

	if ([[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:0] != nil) {
		NSLog(@"A-OK");
	} else {
	/*	NSString *echoAlertMessage = [[NSString alloc] initWithString:@"Unable to connect to flickr.  Please ensure you are connected to the Internet."];
		UIAlertView *echoAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:echoAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[echoAlert show];
		[echoAlert release];
		[echoAlertMessage release];
	*/	
	}

}	
/*
- (BOOL)isDataSourceAvailable
{
    static BOOL checkNetwork = YES;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
		
        Boolean success;    
        const char *host_name = "flickr.com"; // your data source host name
		
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    return _isDataSourceAvailable;
} */

-(void)addMirrorBadge:(int)badgeNumber {
	MKNumberBadgeView *mirrorBadge = [[MKNumberBadgeView alloc] init];
	if (badgeNumber == 1) {
		[self setBadgeMirrorOne:mirrorBadge];
		[badgeMirrorOne setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorOne];
	} else if (badgeNumber == 2) {
		[self setBadgeMirrorTwo:mirrorBadge];
		[badgeMirrorTwo setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorTwo];
	} else if (badgeNumber == 3) {
		[self setBadgeMirrorThree:mirrorBadge];
		[badgeMirrorThree setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorThree];
	} else if (badgeNumber == 4) {
		[self setBadgeMirrorFour:mirrorBadge];
		[badgeMirrorFour setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorFour];
	} else if (badgeNumber == 5) {
		[self setBadgeMirrorFive:mirrorBadge];
		[badgeMirrorFive setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorFive];
	} else if (badgeNumber == 6) {
		[self setBadgeMirrorSix:mirrorBadge];
		[badgeMirrorSix setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorSix];
	} else if (badgeNumber == 7) {
		[self setBadgeMirrorSeven:mirrorBadge];
		[badgeMirrorSeven setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorSeven];
	} else if (badgeNumber == 8) {
		[self setBadgeMirrorEight:mirrorBadge];
		[badgeMirrorEight setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorEight];
	} else if (badgeNumber == 9) {
		[self setBadgeMirrorNine:mirrorBadge];
		[badgeMirrorNine setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorNine];
	} else if (badgeNumber == 10) {
		[self setBadgeMirrorTen:mirrorBadge];
		[badgeMirrorTen setValue:badgeNumber];
		[externalWindow addSubview:badgeMirrorTen];
	}
	[mirrorBadge release], mirrorBadge = nil;
	[self syncBadges];
}

-(void)addBadge:(int)badgeNumber {
	MKNumberBadgeView *newBadge = [[MKNumberBadgeView alloc] init];
	if (badgeNumber == 1) {
		[self setBadgeOne:newBadge];
		[badgeOne setValue:badgeNumber];
		[badgeOne setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeOne];
		[badgeOneInFront setString:@"1"];
	} else if (badgeNumber == 2) {
		[self setBadgeTwo:newBadge];
		[badgeTwo setValue:badgeNumber];
		[badgeTwo setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeTwo];
		[badgeTwoInFront setString:@"1"];
	} else if (badgeNumber == 3) {
		[self setBadgeThree:newBadge];
		[badgeThree setValue:badgeNumber];
		[badgeThree setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeThree];
		[badgeThreeInFront setString:@"1"];
	} else if (badgeNumber == 4) {
		[self setBadgeFour:newBadge];
		[badgeFour setValue:badgeNumber];
		[badgeFour setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeFour];
		[badgeFourInFront setString:@"1"];
	} else if (badgeNumber == 5) {
		[self setBadgeFive:newBadge];
		[badgeFive setValue:badgeNumber];
		[badgeFive setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeFive];
		[badgeFiveInFront setString:@"1"];
	} else if (badgeNumber == 6) {
		[self setBadgeSix:newBadge];
		[badgeSix setValue:badgeNumber];
		[badgeSix setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeSix];
		[badgeSixInFront setString:@"1"];
	} else if (badgeNumber == 7) {
		[self setBadgeSeven:newBadge];
		[badgeSeven setValue:badgeNumber];
		[badgeSeven setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeSeven];
		[badgeSevenInFront setString:@"1"];
	} else if (badgeNumber == 8) {
		[self setBadgeEight:newBadge];
		[badgeEight setValue:badgeNumber];
		[badgeEight setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeEight];
		[badgeEightInFront setString:@"1"];
	} else if (badgeNumber == 9) {
		[self setBadgeNine:newBadge];
		[badgeNine setValue:badgeNumber];
		[badgeNine setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeNine];
		[badgeNineInFront setString:@"1"];
	} else if (badgeNumber == 10) {
		[self setBadgeTen:newBadge];
		[badgeTen setValue:badgeNumber];
		[badgeTen setFrame:CGRectMake(110, 180, 44, 44)];
		[[self view] addSubview:badgeTen];
		[badgeTenInFront setString:@"1"];
	}
	[newBadge release], newBadge = nil;
}

-(IBAction)changeBadgeState:(id)sender {
	
	// First, determine the badge name
	if ([sender tag] == 1) {
		if ((badgeOne != nil) && ([badgeOneInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeOne];
			[badgeOneInFront setString:@"0"];
		} else if (badgeOne != nil) {
			[[self view] bringSubviewToFront:badgeOne];
			[badgeOneInFront setString:@"1"];
		} else {
			[self addBadge:1];
			if (mirrorState) {
				[self addMirrorBadge:1];
			}
		}
	}else if ([sender tag] == 2) {
		if ((badgeTwo != nil) && ([badgeTwoInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeTwo];
			[badgeTwoInFront setString:@"0"];
		} else if (badgeTwo != nil) {
			[[self view] bringSubviewToFront:badgeTwo];
			[badgeTwoInFront setString:@"1"];
		} else {
			[self addBadge:2];
			if (mirrorState) {
				[self addMirrorBadge:2];
			}
		}
	}else if ([sender tag] == 3) {
		if ((badgeThree != nil) && ([badgeThreeInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeThree];
			[badgeThreeInFront setString:@"0"];
		} else if (badgeThree != nil) {
			[[self view] bringSubviewToFront:badgeThree];
			[badgeThreeInFront setString:@"1"];
		} else {
			[self addBadge:3];
			if (mirrorState) {
				[self addMirrorBadge:3];
			}
		}
	}	
	else if ([sender tag] == 4) {
		if ((badgeFour != nil) && ([badgeFourInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeFour];
			[badgeFourInFront setString:@"0"];
		} else if (badgeFour != nil) {
			[[self view] bringSubviewToFront:badgeFour];
			[badgeFourInFront setString:@"1"];
		} else {
			[self addBadge:4];
			if (mirrorState) {
				[self addMirrorBadge:4];
			}
		}
	}	
	else if ([sender tag] == 5) {
		if ((badgeFive != nil) && ([badgeFiveInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeFive];
			[badgeFiveInFront setString:@"0"];
		} else if (badgeFive != nil) {
			[[self view] bringSubviewToFront:badgeFive];
			[badgeFiveInFront setString:@"1"];
		} else {
			[self addBadge:5];
			if (mirrorState) {
				[self addMirrorBadge:5];
			}
		}
	}	
	else if ([sender tag] == 6) {
		if ((badgeSix != nil) && ([badgeSixInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeSix];
			[badgeSixInFront setString:@"0"];
		} else if (badgeSix != nil) {
			[[self view] bringSubviewToFront:badgeSix];
			[badgeSixInFront setString:@"1"];
		} else {
			[self addBadge:6];
			if (mirrorState) {
				[self addMirrorBadge:6];
			}
		}
	}	
	else if ([sender tag] == 7) {
		if ((badgeSeven != nil) && ([badgeSevenInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeSeven];
			[badgeSevenInFront setString:@"0"];
		} else if (badgeSeven != nil) {
			[[self view] bringSubviewToFront:badgeSeven];
			[badgeSevenInFront setString:@"1"];
		} else {
			[self addBadge:7];
			if (mirrorState) {
				[self addMirrorBadge:7];
			}
		}
	}	
	else if ([sender tag] == 8) {
		if ((badgeEight != nil) && ([badgeEightInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeEight];
			[badgeEightInFront setString:@"0"];
		} else if (badgeEight != nil) {
			[[self view] bringSubviewToFront:badgeEight];
			[badgeEightInFront setString:@"1"];
		} else {
			[self addBadge:8];
			if (mirrorState) {
				[self addMirrorBadge:8];
			}
		}
	}	
	else if ([sender tag] == 9) {
		if ((badgeNine != nil) && ([badgeNineInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeNine];
			[badgeNineInFront setString:@"0"];
		} else if (badgeNine != nil) {
			[[self view] bringSubviewToFront:badgeNine];
			[badgeNineInFront setString:@"1"];
		} else {
			[self addBadge:9];
			if (mirrorState) {
				[self addMirrorBadge:9];
			}
		}
	}	
	else if ([sender tag] == 10) {
		if ((badgeTen != nil) && ([badgeTenInFront isEqualToString:@"1"])) {
			[[self view]sendSubviewToBack:badgeTen];
			[badgeTenInFront setString:@"0"];
		} else if (badgeTen != nil) {
			[[self view] bringSubviewToFront:badgeTen];
			[badgeTenInFront setString:@"1"];
		} else {
			[self addBadge:10];
			if (mirrorState) {
				[self addMirrorBadge:10];
			}
		}
	}	
	else {
		NSLog(@"Tag did not match");
		NSLog(@"Tag: %@", [sender tag]);
		
	}
	
	
	/*	
	 MKNumberBadgeView *newBadge = [[MKNumberBadgeView alloc] init];
	 [newBadge setValue:69];
	 [newBadge setFrame:CGRectMake(110, 180, 44, 44)];
	 //NSLog(@"Badge size: %@ ", [newBadge badgeSize]);
	 [[self view] addSubview:newBadge]; */
	//[newBadge release];
}


@end
