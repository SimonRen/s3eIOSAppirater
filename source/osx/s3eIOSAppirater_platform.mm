/*
 * osx-specific implementation of the s3eIOSAppirater extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "s3eIOSAppirater_internal.h"

s3eResult s3eIOSAppiraterInit_platform()
{
    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;
}

void s3eIOSAppiraterTerminate_platform()
{
    // Add any platform-specific termination code here
}

void s3eIOSAppiraterParams_platform(int appId, int usesUntilPrompt, int daysUntilPrompt, int daysRemindLater, int numSignificantEvents, const char * rateNowTitle, const char * rateNowText, const char * rateNowYesButton, const char * rateNowNoButton, const char * remindTitle, const char * remindText, const char * remindYesButton, const char * remindNoButton)
{
}

void s3eIOSAppiraterAppLaunched_platform(bool canPromptForRating)
{
}

void s3eIOSAppiraterAppEnteredForeground_platform(bool canPromptForRating)
{
}

void s3eIOSAppiraterUserDidSignificantEvent_platform(bool canPromptForRating)
{
}

void s3eIOSAppiraterRateApp_platform()
{
}
