    //
//  AboutViewController.m
//  Photo Pool
//
//  Created by Michael Pulsifer on 7/24/10.

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

#import "AboutViewController.h"


@implementation AboutViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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
}


- (void)dealloc {
    [super dealloc];
}

-(IBAction)doneButtonTapped:(id)sender {
	
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)gemmellButtonTapped:(id)sender {
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mattgemmell.com"]];
}

-(IBAction)flickrButtonTapped:(id)sender {
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.flickr.com/services/api/tos/"]];
}


-(IBAction)marcButtonTapped:(id)sender {
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.weatheredwondersphotography.com/"]];
}


-(IBAction)iconSourceButtonTapped:(id)sender {
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://glyphish.com/"]];
}

-(IBAction)claireWareButtonTapped:(id)sender {
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.claireware.com/blog_files/iphone_badge_view.html"]];
}

-(IBAction)facebookButtonTapped:(id)sender {
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/pages/Photo-Pool-for-iPad/147692301921097"]];
}


@end
