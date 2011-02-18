//
//  ExternalPersonInfoCard.m
//  Photo Pool
//
//  Created by Michael Pulsifer on 9/26/10.

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

#import "ExternalPersonInfoCard.h"


@implementation ExternalPersonInfoCard
@synthesize flickrRequest, context, plistDictionary;
@synthesize photoArtist, artistIcon, photoBy, iconURL, iconData;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//Group state
	sharedGroupState = [SingletonFlickrGroup sharedGroupStateInstance];
	
	loadingEXIF = YES;
	/*
	 // Add the subview for the artist's icon
	 UIImageView *newArtistIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"42-photos.png"]];
	 [self setArtistIcon:newArtistIcon];
	 [newArtistIcon release], newArtistIcon = nil;
	 
	 [artistIcon setFrame:CGRectMake(10.0, 10.0, 48.0, 48.0)];
	 [self addSubview:artistIcon];
	 
	 // Add the static "By: " text label
	 UILabel *newPhotoBy = [[UILabel alloc] init];
	 [self setPhotoBy:newPhotoBy];
	 [newPhotoBy release], newPhotoBy = nil;
	 
	 [photoBy setText:@"By: "];
	 [photoBy setFont:[UIFont systemFontOfSize:12.0]];
	 [photoBy setFrame:CGRectMake(68.0, 68.0, 45.0, 15.0)];
	 [self addSubview:photoBy];
	 
	 // Add the dynamic artist name text label
	 UILabel *newPhotoArtist = [[UILabel alloc] init];
	 [self setPhotoArtist:newPhotoArtist];
	 [newPhotoArtist release], newPhotoArtist = nil;
	 
	 [photoArtist setText:@" "];
	 //[photoArtist setFont:[UIFont systemFontOfSize:12.0]];
	 [photoArtist setFrame:CGRectMake(93.0, 68.0, 207.0, 20.0)];
	 [self addSubview:photoArtist];
	 */	
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
	
	[flickrRequest callAPIMethodWithGET:@"flickr.people.getInfo" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState selectedPhotoArtistID], @"user_id", nil]];
	
	//	[self setIconURL:[NSURL URLWithString:@"http://www.flickr.com/images/buddyicon.jpg"]]; 
	
	
//	exifTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(noExifAlertMethod:) userInfo:nil repeats:NO];
	[super viewDidLoad];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)noExifAlertMethod:(NSTimer *)theTimer {
	/*	if (loadingEXIF) {
	 NSString *groupAlertMessage = [[NSString alloc] initWithString:@"flickr did not respond with any EXIF data. The photographer may not have enabled sharing of it."];
	 UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No EXIF Data" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	 [groupAlert show];
	 [groupAlert release];
	 [groupAlertMessage release];
	 }
	 */	
}	

- (void)viewDidUnload {
	self.flickrRequest = nil;
	self.context = nil;
	self.plistDictionary= nil;
	self.photoArtist = nil;
	self.artistIcon = nil;
	self.photoBy = nil;
	self.iconURL = nil;
	self.iconData = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[flickrRequest release];
	[context release];
	[plistDictionary release];
	[photoArtist release];
	[artistIcon release];
	[photoBy release];
	[iconURL release];
	[iconData release];
    [super dealloc];
}

#pragma mark -
#pragma mark flickr Methods
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	NSLog(@"Sucessful response");
	NSLog(@"Person response was: %@", inResponseDictionary);
	if ([inResponseDictionary valueForKeyPath:@"person.realname"] != nil) {
		NSLog(@"Person info: %@", [inResponseDictionary valueForKeyPath:@"person.realname"]);
		[[self photoArtist] setText:[[inResponseDictionary valueForKeyPath:@"person.realname"] objectForKey:@"_text"]];
		NSString *iconURLText = [[[NSString alloc] initWithFormat:@"http://farm%@.static.flickr.com/%@/buddyicons/%@.jpg",
								 [inResponseDictionary valueForKeyPath:@"person.iconfarm"], 
								 [inResponseDictionary valueForKeyPath:@"person.iconserver"], 
								 [sharedGroupState selectedPhotoArtistID]] autorelease];
		[self setIconURL:[NSURL URLWithString:iconURLText]]; 
		[self setIconData:[NSData dataWithContentsOfURL:iconURL]];
		UIImage *tempIconPhoto = [[UIImage alloc] initWithData:iconData];
		[artistIcon setImage:tempIconPhoto];
	}
	NSLog(@"Processed XML");
	
	loadingEXIF = NO;
	
}

-(void)flickrRequest:(OFFlickrAPIContext *)inRequest didFailWithError:(NSError *)inError; {
	NSLog(@"Error Encountered with flickr!");
}

@end
