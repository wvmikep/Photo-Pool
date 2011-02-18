//
//  main.m
//  Photo Pool
//
//  Created by Michael Pulsifer on 7/4/10.
//  Copyright Mike Pulsifer 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
