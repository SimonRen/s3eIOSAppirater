/*
 This file is part of Appirater.
 
 Copyright (c) 2012, Arash Payan
 All rights reserved.
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */
/*
 * Appirater.m
 * appirater
 *
 * Created by Arash Payan on 9/5/09.
 * http://arashpayan.com
 * Copyright 2012 Arash Payan. All rights reserved.
 */

#import "Appirater.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>

NSString *const kAppiraterFirstUseDate				= @"kAppiraterFirstUseDate";
NSString *const kAppiraterUseCount					= @"kAppiraterUseCount";
NSString *const kAppiraterSignificantEventCount		= @"kAppiraterSignificantEventCount";
NSString *const kAppiraterCurrentVersion			= @"kAppiraterCurrentVersion";
NSString *const kAppiraterRatedCurrentVersion		= @"kAppiraterRatedCurrentVersion";
NSString *const kAppiraterDeclinedToRate			= @"kAppiraterDeclinedToRate";
NSString *const kAppiraterReminderRequestDate		= @"kAppiraterReminderRequestDate";

NSString *templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
NSString *templateReviewURLiOS7 = @"itms-apps://itunes.apple.com/app/idAPP_ID";

@interface Appirater ()
- (BOOL)connectedToNetwork;
- (void)showRatingAlert;
- (void)showRemindLaterAlert;
- (BOOL)ratingConditionsHaveBeenMet;
- (void)incrementUseCount;
- (void)hideRatingAlert;
@end

@implementation Appirater 

@synthesize ratingAlert;

// Guy - params set for Appirater
int mAppId;
int mUsesUntilPrompt;
int mDaysUntilPrompt;
int mDaysRemindLater;
int mNumSignificantEvents;
NSString *mRateNowTitle;
NSString *mRateNowText;
NSString *mRateNowYesButton;
NSString *mRateNowNoButton;
NSString *mRemindTitle;
NSString *mRemindText;
NSString *mRemindYesButton;
NSString *mRemindNoButton;

RateUIViewSelector mAlertSelect;

- (id) init {
    self = [super init];
    if (self != nil) {
        mAppId = 0;
        mUsesUntilPrompt = 0;
        mDaysUntilPrompt = 0;
        mDaysRemindLater = 0;
        mNumSignificantEvents = 0;
        mRateNowTitle = nil;
        mRateNowText = nil;
        mRateNowYesButton = nil;
        mRateNowNoButton = nil;
        mRemindTitle = nil;
        mRemindText = nil;
        mRemindYesButton = nil;
        mRemindNoButton = nil;
    }
    return self;
}

- (void)dealloc {
    if (mRateNowTitle) [mRateNowTitle release];
    if (mRateNowText) [mRateNowText release];
    if (mRateNowYesButton) [mRateNowYesButton release];
    if (mRateNowNoButton) [mRateNowNoButton release];
    if (mRemindTitle) [mRemindTitle release];
    if (mRemindText) [mRemindText release];
    if (mRemindYesButton) [mRemindYesButton release];
    if (mRemindNoButton) [mRemindNoButton release];
    [super dealloc];
}

- (void)setParams:(int)appId :(int)usesUntilPrompt :(int)daysUntilPrompt :(int)daysRemindLater :(int)numSignificantEvents :(NSString *)rateNowTitle :(NSString *)rateNowText :(NSString *)rateNowYesButton :(NSString *)rateNowNoButton :(NSString *)remindTitle :(NSString *)remindText :(NSString *)remindYesButton :(NSString *)remindNoButton {
    
    // Set params instead of using defines
    mAppId = appId;
    mUsesUntilPrompt = usesUntilPrompt;
    mDaysUntilPrompt = daysUntilPrompt;
    mDaysRemindLater = daysRemindLater;
    mNumSignificantEvents = numSignificantEvents;
    
    mRateNowTitle = rateNowTitle;
    mRateNowText = rateNowText;
    mRateNowYesButton = rateNowYesButton;
    mRateNowNoButton = rateNowNoButton;
    
    mRemindTitle = remindTitle;
    mRemindText = remindText;
    mRemindYesButton = remindYesButton;
    mRemindNoButton = remindNoButton;
    
    [mRateNowTitle retain];
    [mRateNowText retain];
    [mRateNowYesButton retain];
    [mRateNowNoButton retain];
    
    [mRemindTitle retain];
    [mRemindText retain];
    [mRemindYesButton retain];
    [mRemindNoButton retain];
    
    mAlertSelect = RateShowRateWindow;
}

- (BOOL)connectedToNetwork {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	NSURL *testURL = [NSURL URLWithString:@"http://www.apple.com/"];
	NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
	NSURLConnection *testConnection = [[[NSURLConnection alloc] initWithRequest:testRequest delegate:self] autorelease];
	
    return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
}


- (void)showRatingAlert {    
    mAlertSelect = RateShowRateWindow;
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:mRateNowTitle
														 message:mRateNowText
														delegate:self
											   cancelButtonTitle:mRateNowNoButton
											   otherButtonTitles:mRateNowYesButton, nil]	 autorelease];
    self.ratingAlert = alertView;
	[alertView show];
}


- (BOOL)ratingConditionsHaveBeenMet {
	if (APPIRATER_DEBUG)
		return YES;

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSDate *dateOfFirstLaunch = [NSDate dateWithTimeIntervalSince1970:[userDefaults doubleForKey:kAppiraterFirstUseDate]];
	NSTimeInterval timeSinceFirstLaunch = [[NSDate date] timeIntervalSinceDate:dateOfFirstLaunch];
	NSTimeInterval timeUntilRate = 60 * 60 * 24 * mDaysUntilPrompt;
	if (timeSinceFirstLaunch < timeUntilRate)
		return NO;
	
	// check if the app has been used enough
	int useCount = [userDefaults integerForKey:kAppiraterUseCount];
	if (useCount <= mUsesUntilPrompt)
		return NO;
	
	// check if the user has done enough significant events
	int sigEventCount = [userDefaults integerForKey:kAppiraterSignificantEventCount];
	if (sigEventCount <= mNumSignificantEvents)
		return NO;
	
	// has the user previously declined to rate this version of the app?
	if ([userDefaults boolForKey:kAppiraterDeclinedToRate])
		return NO;
	
	// has the user already rated the app?
	if ([userDefaults boolForKey:kAppiraterRatedCurrentVersion])
		return NO;
	
	// if the user wanted to be reminded later, has enough time passed?
	NSDate *reminderRequestDate = [NSDate dateWithTimeIntervalSince1970:[userDefaults doubleForKey:kAppiraterReminderRequestDate]];
	NSTimeInterval timeSinceReminderRequest = [[NSDate date] timeIntervalSinceDate:reminderRequestDate];
	NSTimeInterval timeUntilReminder = 60 * 60 * 24 * mDaysRemindLater;
	if (timeSinceReminderRequest < timeUntilReminder)
		return NO;
	
	return YES;
}

- (void)incrementUseCount {
	// get the app's version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	
	// get the version number that we've been tracking
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *trackingVersion = [userDefaults stringForKey:kAppiraterCurrentVersion];
	if (trackingVersion == nil)
	{
		trackingVersion = version;
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
	}
	
	if (APPIRATER_DEBUG)
		NSLog(@"APPIRATER Tracking version: %@", trackingVersion);
	
	if ([trackingVersion isEqualToString:version])
	{
		// check if the first use date has been set. if not, set it.
		NSTimeInterval timeInterval = [userDefaults doubleForKey:kAppiraterFirstUseDate];
		if (timeInterval == 0)
		{
			timeInterval = [[NSDate date] timeIntervalSince1970];
			[userDefaults setDouble:timeInterval forKey:kAppiraterFirstUseDate];
		}
		
		// increment the use count
		int useCount = [userDefaults integerForKey:kAppiraterUseCount];
		useCount++;
		[userDefaults setInteger:useCount forKey:kAppiraterUseCount];
		if (APPIRATER_DEBUG)
			NSLog(@"APPIRATER Use count: %d", useCount);
	}
	else
	{
		// it's a new version of the app, so restart tracking
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
		[userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kAppiraterFirstUseDate];
		[userDefaults setInteger:1 forKey:kAppiraterUseCount];
		[userDefaults setInteger:0 forKey:kAppiraterSignificantEventCount];
		[userDefaults setBool:NO forKey:kAppiraterRatedCurrentVersion];
		[userDefaults setBool:NO forKey:kAppiraterDeclinedToRate];
		[userDefaults setDouble:0 forKey:kAppiraterReminderRequestDate];
	}
	
	[userDefaults synchronize];
}

- (void)incrementSignificantEventCount {
	// get the app's version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	
	// get the version number that we've been tracking
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *trackingVersion = [userDefaults stringForKey:kAppiraterCurrentVersion];
	if (trackingVersion == nil)
	{
		trackingVersion = version;
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
	}
	
	if (APPIRATER_DEBUG)
		NSLog(@"APPIRATER Tracking version: %@", trackingVersion);
	
	if ([trackingVersion isEqualToString:version])
	{
		// check if the first use date has been set. if not, set it.
		NSTimeInterval timeInterval = [userDefaults doubleForKey:kAppiraterFirstUseDate];
		if (timeInterval == 0)
		{
			timeInterval = [[NSDate date] timeIntervalSince1970];
			[userDefaults setDouble:timeInterval forKey:kAppiraterFirstUseDate];
		}
		
		// increment the significant event count
		int sigEventCount = [userDefaults integerForKey:kAppiraterSignificantEventCount];
		sigEventCount++;
		[userDefaults setInteger:sigEventCount forKey:kAppiraterSignificantEventCount];
		if (APPIRATER_DEBUG)
			NSLog(@"APPIRATER Significant event count: %d", sigEventCount);
	}
	else
	{
		// it's a new version of the app, so restart tracking
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
		[userDefaults setDouble:0 forKey:kAppiraterFirstUseDate];
		[userDefaults setInteger:0 forKey:kAppiraterUseCount];
		[userDefaults setInteger:1 forKey:kAppiraterSignificantEventCount];
		[userDefaults setBool:NO forKey:kAppiraterRatedCurrentVersion];
		[userDefaults setBool:NO forKey:kAppiraterDeclinedToRate];
		[userDefaults setDouble:0 forKey:kAppiraterReminderRequestDate];
	}
	
	[userDefaults synchronize];
}

- (void)incrementAndRate:(BOOL)canPromptForRating {
	[self incrementUseCount];
	
	if (canPromptForRating &&
		[self ratingConditionsHaveBeenMet] &&
		[self connectedToNetwork])
	{
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self showRatingAlert];
                       });
	}
}

- (void)incrementSignificantEventAndRate:(BOOL)canPromptForRating {
	[self incrementSignificantEventCount];
	
	if (canPromptForRating &&
		[self ratingConditionsHaveBeenMet] &&
		[self connectedToNetwork])
	{
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self showRatingAlert];
                       });
	}
}

- (void)appLaunched {
	[self appLaunched:YES];
}

- (void)appLaunched:(BOOL)canPromptForRating {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       [self incrementAndRate:canPromptForRating];
                   });
}

- (void)hideRatingAlert {
	if (self.ratingAlert.visible) {
		if (APPIRATER_DEBUG)
			NSLog(@"APPIRATER Hiding Alert");
		[self.ratingAlert dismissWithClickedButtonIndex:-1 animated:NO];
	}	
}

- (void)appWillResignActive {
	if (APPIRATER_DEBUG)
		NSLog(@"APPIRATER appWillResignActive");
	[self hideRatingAlert];
}

- (void)appEnteredForeground:(BOOL)canPromptForRating {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       [self incrementAndRate:canPromptForRating];
                   });
}

- (void)userDidSignificantEvent:(BOOL)canPromptForRating {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       [self incrementSignificantEventAndRate:canPromptForRating];
                   });
}

- (void)rateApp {
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"APPIRATER NOTE: iTunes App Store is not supported on the iOS simulator. Unable to open App Store page.");
#else
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:[NSString stringWithFormat:@"%d", mAppId]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        reviewURL = [templateReviewURLiOS7 stringByReplacingOccurrencesOfString:@"APP_ID" withString:[NSString stringWithFormat:@"%d", mAppId]];
    }
    
	[userDefaults setBool:YES forKey:kAppiraterRatedCurrentVersion];
	[userDefaults synchronize];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
#endif
}

- (void)showRemindLaterAlert {
    mAlertSelect = RateShowRemindLaterWindow;
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:mRemindTitle
														 message:mRemindText
														delegate:self
											   cancelButtonTitle:mRemindNoButton
											   otherButtonTitles:mRemindYesButton, nil]	 autorelease];
    
    self.ratingAlert = alertView;
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
    /////////////////
    // Ask To Rate //
    /////////////////
    
    if (mAlertSelect == RateShowRateWindow) {
        switch (buttonIndex) {
            case 0:
            {
                // Show a confirm alert
                [self showRemindLaterAlert];
                break;

            }
            case 1:
            {
                // they want to rate it
                [self rateApp];
                break;
            }
        }
        
    /////////////////////////
    // Ask To Remind Later //
    /////////////////////////
        
    } else if (mAlertSelect == RateShowRemindLaterWindow) {
        
        switch (buttonIndex) {
            case 0:
            {
                // they don't want to rate it
                //[userDefaults setBool:YES forKey:kAppiraterDeclinedToRate];
                [userDefaults synchronize];
                break;

            }
            case 1:
            {
                // remind them later
                // SIMONREN ::: reset significant event count, for YIUGAME use ONLY
                [userDefaults setInteger:0 forKey:kAppiraterSignificantEventCount];
                [userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kAppiraterReminderRequestDate];
                [userDefaults synchronize];
                break;
                
            }
        }


    }
}

@end
