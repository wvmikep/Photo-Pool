    //
//  FlickrGroupPickerController.m
//  Photo Pool
//
//  Created by Michael Pulsifer on 7/5/10.

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

#import "FlickrGroupPickerController.h"


@implementation FlickrGroupPickerController
@synthesize groupPhotoCountSliderLabel;
@synthesize groupName; //, groupTag;
@synthesize groupPhotoCountSlider;
@synthesize plistDictionary, context, flickrRequest;
//@synthesize validateAndCloseButton;
//@synthesize sharedGroupState;

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
	
	NSLog(@"viewDidLoad");

	//Group state
	sharedGroupState = [SingletonFlickrGroup sharedGroupStateInstance];
	NSLog(@"sharedGroupState");
	
	
	// Set form defaults
	if ([sharedGroupState groupPhotoCountAsInt] != 0) {
		groupPhotoCountSlider.value = (float)[sharedGroupState groupPhotoCountAsInt];
		int groupPhotoCountAsInt = (int)(groupPhotoCountSlider.value + 0.5f);
		NSString *newGroupPhotoCountSliderText = [[NSString alloc] initWithFormat:@"%d", groupPhotoCountAsInt];
		groupPhotoCountSliderLabel.text = newGroupPhotoCountSliderText;
	}
	if ([sharedGroupState groupName] != nil) {
		groupName.text = [sharedGroupState groupName];
	}
/*	if ([sharedGroupState groupTag] != nil) {
		groupTag.text = [sharedGroupState groupTag];
	} */
	
    [super viewDidLoad];
}
/**/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.groupPhotoCountSliderLabel = nil;
	self.groupName = nil;
//	self.groupTag = nil;
	self.groupPhotoCountSlider = nil;
	self.plistDictionary = nil;
	self.context = nil;
	self.flickrRequest = nil;
}


- (void)dealloc {
	[groupPhotoCountSliderLabel release];
	[groupName release];
//	[groupTag release];
	[groupPhotoCountSlider release];
	[plistDictionary release];
	[context release];
	[flickrRequest release];
    [super dealloc];
}

#pragma mark -
#pragma mark Flickr Methods


-(IBAction) groupSelected:(id)sender;
{
	NSLog(@"button clicked!");
	NSMutableString *tempGroupName = [[NSString alloc] initWithString:groupName.text];
	[sharedGroupState setGroupName:tempGroupName];
	NSLog(@"%@", [sharedGroupState groupName]);
}

-(void)setGroupPop:(UIPopoverController *)aPopover
{
	popover = aPopover;
}


/*
-(IBAction) groupTagSelected:(id)sender;
{
	NSMutableString *tempTagName = [[NSString alloc] initWithString:groupTag.text];
	[sharedGroupState setGroupTag:tempTagName];
}*/

-(IBAction)groupPhotoCountSliderChanged:(id)sender {
	[groupName resignFirstResponder];
//	UISlider *groupPhotoCountSlider = (UISlider *)sender;
	int groupPhotoCountAsInt = (int)(groupPhotoCountSlider.value + 0.5f);
	NSString *newGroupPhotoCountSliderText = [[NSString alloc] initWithFormat:@"%d", groupPhotoCountAsInt];
	groupPhotoCountSliderLabel.text = newGroupPhotoCountSliderText;
	NSMutableString *tempSliderValue = [[NSString alloc] initWithString:newGroupPhotoCountSliderText];
	[sharedGroupState setGroupPhotoCount:tempSliderValue];
	[sharedGroupState setGroupPhotoCountAsInt:groupPhotoCountAsInt];
	[newGroupPhotoCountSliderText release];
}

-(IBAction)validateAndCloseButtonTapped:(id)sender {

		// Read the flickr API Key and Shared Secret from flickr.plist
	
	NSMutableString *mutString = [NSMutableString stringWithString:groupName.text];
	mutString = (NSMutableString *)[mutString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	[groupName setText:mutString];
		
	if ([groupName.text isEqualToString:@""]) {
		NSString *groupAlertMessage = [[NSString alloc] initWithString:@"No group name was entered and none was selected."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No Results" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[groupAlertMessage release];
		if (popover != nil) {
			[popover dismissPopoverAnimated:YES];
			
		} else {
			NSLog(@"Nothing to dismiss");
		}
		
	} else {
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"flickr.plist"];
		plistDictionary = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
		NSString *flickrKey = [plistDictionary objectForKey:@"flickr_key"];
		NSString *flickrSecret = [plistDictionary objectForKey:@"flickr_secret"];
		
		context = [[OFFlickrAPIContext alloc] initWithAPIKey:flickrKey sharedSecret:flickrSecret];
		
		flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];
		[flickrRequest setDelegate:self];
		[flickrRequest callAPIMethodWithGET:@"flickr.groups.search" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[sharedGroupState groupName], @"text", @"1", @"per_page", nil]];
	}
	
	// dismiss the view
//	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	NSLog(@"Sucessful response");
	NSDictionary *groupSearchResult = [[inResponseDictionary valueForKeyPath:@"groups.group"] objectAtIndex:0];
	if ([groupSearchResult objectForKey:@"nsid"] != nil) {
		NSData *groupSearchResultBuffer = [NSKeyedArchiver archivedDataWithRootObject:groupSearchResult];
		[sharedGroupState setGroupID:[[NSKeyedUnarchiver unarchiveObjectWithData:groupSearchResultBuffer] objectForKey:@"nsid"]];
//		[sharedGroupState setGroupName:[[NSKeyedUnarchiver unarchiveObjectWithData:groupSearchResultBuffer] objectForKey:@"name"]];
		[sharedGroupState setValidGroupName:1];
		if (popover != nil) {
			[popover dismissPopoverAnimated:YES];
			
		} else {
			NSLog(@"Nothing to dismiss");
		}
	} else {
		[sharedGroupState setValidGroupName:0];
		NSString *groupAlertMessage = [[NSString alloc] initWithString:@"The group you were looking for was not found.  Please try again."];
		UIAlertView *groupAlert = [[UIAlertView alloc] initWithTitle:@"No Results" message:groupAlertMessage delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[groupAlert show];
		[groupAlert release];
		[groupAlertMessage release];
	}


	
}

-(IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

-(IBAction)backgroundTap:(id)sender {
	[groupName resignFirstResponder];
}
@end
