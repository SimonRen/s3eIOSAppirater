/*
 * (C) 2001-2012 Marmalade. All Rights Reserved.
 *
 * This document is protected by copyright, and contains information
 * proprietary to Marmalade.
 *
 * This file consists of source code released by Marmalade under
 * the terms of the accompanying End User License Agreement (EULA).
 * Please do not use this program/source code before you have read the
 * EULA and have agreed to be bound by its terms.
 */
/*
 * WARNING: this is an autogenerated file and will be overwritten by
 * the extension interface script.
 */
#ifndef S3E_EXT_IOSAPPIRATER_H
#define S3E_EXT_IOSAPPIRATER_H

#include "s3eTypes.h"
// \cond HIDDEN_DEFINES
S3E_BEGIN_C_DECL
// \endcond

/**
 * Returns S3E_TRUE if the IOSAppirater extension is available.
 */
s3eBool s3eIOSAppiraterAvailable();

void s3eIOSAppiraterParams(int appId, int usesUntilPrompt, int daysUntilPrompt, int daysRemindLater, int numSignificantEvents, const char * rateNowTitle, const char * rateNowText, const char * rateNowYesButton, const char * rateNowNoButton, const char * remindTitle, const char * remindText, const char * remindYesButton, const char * remindNoButton);

void s3eIOSAppiraterAppLaunched(bool canPromptForRating);

void s3eIOSAppiraterAppEnteredForeground(bool canPromptForRating);

void s3eIOSAppiraterUserDidSignificantEvent(bool canPromptForRating);

void s3eIOSAppiraterRateApp();

S3E_END_C_DECL

#endif /* !S3E_EXT_IOSAPPIRATER_H */
