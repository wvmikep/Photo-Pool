//
//  ExternalPhotoInfoCard.m
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

#import "ExternalPhotoInfoCard.h"


@implementation ExternalPhotoInfoCard
@synthesize flickrRequest, context, plistDictionary, activityView, artistInfoCardView;
@synthesize photoTitle, photoDate, photoISO, photoShutterSpeed, photoAperture, photoFocalLength, photoCamera, photoLens;

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
	
	[[self photoTitle] setText:[sharedGroupState selectedPhotoTitle]];
	
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
	
	PersonInfoCard *newArtistInfoCardView = [[PersonInfoCard alloc] initWithNibName:@"PersonInfoCard" bundle:nil];
	[self setArtistInfoCardView:newArtistInfoCardView];
	[newArtistInfoCardView release], newArtistInfoCardView = nil;
	
	[artistInfoCardView.view setFrame:CGRectMake(0.0, 44.0, 320.0, 60.0)];
	[[self view] addSubview:artistInfoCardView.view];
	
	NSString *flickrPhotoID = [[NSString alloc] initWithFormat: @"%@", [sharedGroupState selectedPhotoID]];
	[flickrRequest callAPIMethodWithGET:@"flickr.photos.getExif" arguments:[NSDictionary dictionaryWithObjectsAndKeys:flickrPhotoID, @"photo_id", nil]];
	NSLog(@"Asked Flickr for the EXIF data");
	
	UIActivityIndicatorView *newActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self setActivityView:newActivity];
	[newActivity release], newActivity = nil;
	[activityView retain];
	
	[activityView setFrame:CGRectMake(5.0, 5.0, 33.0, 33.0)];
	
	[activityView startAnimating];
	[[self view] addSubview:activityView];
	
	
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

/*-(void)setPopover:(UIPopoverController *)aPopover
{
	popover = aPopover;
}*/

/* -(IBAction)doneButtonTapped:(id)sender {
	if (popover != nil) {
		[popover dismissPopoverAnimated:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"projectorInfoCardDone" object:self];
		
	} else {
		NSLog(@"Nothing to dismiss");
	}
}	*/

/*-(void)noExifAlertMethod:(NSTimer *)theTimer {
	if (loadingEXIF) {
		NSString *groupAlertMessage = [[NSString alloc] initWithString:@"flickr did not respond with any EXIF data. The photographer may not have enabled sharing of it."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No EXIF Data" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[groupAlertMessage release];
	}
	
}	*/

- (void)viewDidUnload {
	self.flickrRequest = nil;
	self.context = nil;
	self.plistDictionary = nil;
	self.activityView = nil;
	
	self.artistInfoCardView = nil;
	
	//self.popover = nil;
	
	self.photoTitle = nil;
	self.photoDate = nil;
	self.photoShutterSpeed = nil;
	self.photoISO = nil;
	self.photoAperture = nil;
	self.photoFocalLength = nil;
	self.photoCamera = nil;
	self.photoLens = nil;
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[flickrRequest release];
	[context release];
	[plistDictionary release];
	[activityView release];
	[artistInfoCardView release];
	
	//[popover release];
	
	[photoTitle release];
	[photoDate release];
	[photoShutterSpeed release];
	[photoISO release];
	[photoAperture release];
	[photoFocalLength release];
	[photoCamera release];
	[photoLens release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark flickr Methods
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	NSLog(@"Sucessful response");
	if ([[inResponseDictionary valueForKeyPath:@"photo.exif"] objectAtIndex:0] != nil)
	{
		//	NSArray *exifTagspaces = [[NSArray alloc] initWithObjects:@"Summary", @"ExifIFD", @"Composite", @"XMP-exif", @"XMP-aux", @"XMP-crs", nil];
		
		// loop through all of the EXIF data and pick out the most relevant as defined in exifTagspaces
		NSArray *allEXIF = [[NSArray alloc] initWithArray:[inResponseDictionary valueForKeyPath:@"photo.exif"]];
		NSLog(@"Array count: %i", [allEXIF count]);
		//		NSMutableArray *exififdArray = [[NSMutableArray alloc] init];
		//		NSMutableArray *xmpexifArray = [[NSMutableArray alloc] init];
		//		NSMutableArray *xmpauxArray = [[NSMutableArray alloc] init];
		//		NSMutableArray *xmpcrsdArray = [[NSMutableArray alloc] init];
		//		NSMutableArray *compositeArray = [[NSMutableArray alloc] init];
		//		NSMutableArray *summaryArray = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < [allEXIF count]; i++) {
			NSDictionary *singleEXIF = [allEXIF objectAtIndex:i];
			if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Aperture"]) {
				if ([singleEXIF objectForKey:@"clean"] != nil) {
					NSDictionary *cleanExif = [singleEXIF objectForKey:@"clean"]; 
					[[self photoAperture] setText:[cleanExif objectForKey:@"_text"]];
					cleanExif = nil;
				} else {
					NSDictionary *rawExif = [singleEXIF objectForKey:@"raw"];
					[[self photoAperture] setText:[rawExif objectForKey:@"_text"]];
					rawExif = nil;
				}
			} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"ShutterSpeedValue"]) {
				if ([singleEXIF objectForKey:@"clean"] != nil) {
					NSDictionary *cleanExif = [singleEXIF objectForKey:@"clean"]; 
					[[self photoShutterSpeed] setText:[cleanExif objectForKey:@"_text"]];
					cleanExif = nil;
				} else {
					NSDictionary *rawExif = [singleEXIF objectForKey:@"raw"];
					[[self photoShutterSpeed] setText:[rawExif objectForKey:@"_text"]];
					rawExif = nil;
				}
			} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"ISO Speed"]) {
				if ([singleEXIF objectForKey:@"clean"] != nil) {
					NSDictionary *cleanExif = [singleEXIF objectForKey:@"clean"]; 
					[[self photoISO] setText:[cleanExif objectForKey:@"_text"]];
					cleanExif = nil;
				} else {
					NSDictionary *rawExif = [singleEXIF objectForKey:@"raw"];
					[[self photoISO] setText:[rawExif objectForKey:@"_text"]];
					rawExif = nil;
				}
			} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Focal Length"]) {
				if ([singleEXIF objectForKey:@"clean"] != nil) {
					NSDictionary *cleanExif = [singleEXIF objectForKey:@"clean"]; 
					[[self photoFocalLength] setText:[cleanExif objectForKey:@"_text"]];
					cleanExif = nil;
				} else {
					NSDictionary *rawExif = [singleEXIF objectForKey:@"raw"];
					[[self photoFocalLength] setText:[rawExif objectForKey:@"_text"]];
					rawExif = nil;
				}
			} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Model"]) {
				if ([singleEXIF objectForKey:@"clean"] != nil) {
					NSDictionary *cleanExif = [singleEXIF objectForKey:@"clean"]; 
					[[self photoCamera] setText:[cleanExif objectForKey:@"_text"]];
					cleanExif = nil;
				} else {
					NSDictionary *rawExif = [singleEXIF objectForKey:@"raw"];
					[[self photoCamera] setText:[rawExif objectForKey:@"_text"]];
					rawExif = nil;
				}
			} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Lens"]) {
				if ([singleEXIF objectForKey:@"clean"] != nil) {
					NSDictionary *cleanExif = [singleEXIF objectForKey:@"clean"]; 
					[[self photoLens] setText:[cleanExif objectForKey:@"_text"]];
					cleanExif = nil;
				} else {
					NSDictionary *rawExif = [singleEXIF objectForKey:@"raw"];
					[[self photoLens] setText:[rawExif objectForKey:@"_text"]];
					rawExif = nil;
				}
			} else if ([[singleEXIF objectForKey:@"label"] isEqualToString:@"Date and Time (Original)"]) {
				if ([singleEXIF objectForKey:@"raw"] != nil) {
					NSDictionary *rawExif = [singleEXIF objectForKey:@"raw"];
					[[self photoDate] setText:[rawExif objectForKey:@"_text"]];
					rawExif = nil;
				} else {
					NSDictionary *cleanExif = [singleEXIF objectForKey:@"clean"]; 
					[[self photoDate] setText:[cleanExif objectForKey:@"_text"]];
					cleanExif = nil;
				}
			}
			
		}
		
		[allEXIF release], allEXIF = nil;
		
	}/* else if ([[inResponseDictionary valueForKeyPath:@"person.realname"] objectAtIndex:0] != nil) {
	  NSLog(@"Person info: %@", [[inResponseDictionary valueForKeyPath:@"person.realname"] objectAtIndex:0]);
	  [[self photoArtist] setText:[[inResponseDictionary valueForKeyPath:@"person.realname"] objectForKey:@"_text"]];
	  }*/
	NSLog(@"Processed XML");
	
	loadingEXIF = NO;
	[activityView stopAnimating];
	[activityView release];
	
}

-(void)flickrRequest:(OFFlickrAPIContext *)inRequest didFailWithError:(NSError *)inError; {
	NSLog(@"Error Encountered with flickr!");
}


@end
