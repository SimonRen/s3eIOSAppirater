/*
 * iphone-specific implementation of the s3eIOSAppirater extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "s3eIOSAppirater_internal.h"
#include "../../appirater/Appirater.h"

#import <UIKit/UIKit.h>

static Appirater *g_appirater;

s3eResult s3eIOSAppiraterInit_platform()
{
    g_appirater = [[Appirater alloc] init];
    
    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;
}

void s3eIOSAppiraterTerminate_platform()
{
    // Add any platform-specific termination code here
    [g_appirater release];
}

void s3eIOSAppiraterParams_platform(int appId, int usesUntilPrompt, int daysUntilPrompt, int daysRemindLater, int numSignificantEvents, const char * rateNowTitle, const char * rateNowText, const char * rateNowYesButton, const char * rateNowNoButton, const char * remindTitle, const char * remindText, const char * remindYesButton, const char * remindNoButton)
{
    // Rate window
    NSString *nsRateNowTitle = [NSString stringWithUTF8String:rateNowTitle];
    NSString *nsRateNowText = [NSString stringWithUTF8String:rateNowText];
    NSString *nsRateNowYesButton = [NSString stringWithUTF8String:rateNowYesButton];
    NSString *nsRateNowNoButton = [NSString stringWithUTF8String:rateNowNoButton];
    
    // Remind later window
    NSString *nsRemindTitle = [NSString stringWithUTF8String:remindTitle];
    NSString *nsRemindText = [NSString stringWithUTF8String:remindText];
    NSString *nsRemindYesButton = [NSString stringWithUTF8String:remindYesButton];
    NSString *nsRemindNoButton = @"不再提醒";
    
    [g_appirater setParams
        :appId
        :usesUntilPrompt
        :daysUntilPrompt
        :daysRemindLater
        :numSignificantEvents
        :nsRateNowTitle
        :nsRateNowText
        :nsRateNowYesButton
        :nsRateNowNoButton
        :nsRemindTitle
        :nsRemindText
        :nsRemindYesButton
        :nsRemindNoButton];
}

void s3eIOSAppiraterAppLaunched_platform(bool canPromptForRating)
{
    [g_appirater appLaunched: canPromptForRating];
}

void s3eIOSAppiraterAppEnteredForeground_platform(bool canPromptForRating)
{
    [g_appirater appEnteredForeground: canPromptForRating];
}

void s3eIOSAppiraterUserDidSignificantEvent_platform(bool canPromptForRating)
{
    [g_appirater userDidSignificantEvent: canPromptForRating];
}

void s3eIOSAppiraterRateApp_platform()
{
    [g_appirater rateApp];
}
