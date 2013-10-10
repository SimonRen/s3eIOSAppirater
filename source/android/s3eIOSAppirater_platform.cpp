/*
 * android-specific implementation of the s3eIOSAppirater extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "s3eIOSAppirater_internal.h"

#include "s3eEdk.h"
#include "s3eEdk_android.h"
#include <jni.h>
#include "IwDebug.h"

static jobject g_Obj;
static jmethodID g_s3eIOSAppiraterParams;
static jmethodID g_s3eIOSAppiraterAppLaunched;
static jmethodID g_s3eIOSAppiraterAppEnteredForeground;
static jmethodID g_s3eIOSAppiraterUserDidSignificantEvent;
static jmethodID g_s3eIOSAppiraterRateApp;

s3eResult s3eIOSAppiraterInit_platform()
{
    // Get the environment from the pointer
    JNIEnv* env = s3eEdkJNIGetEnv();
    jobject obj = NULL;
    jmethodID cons = NULL;

    // Get the extension class
    jclass cls = s3eEdkAndroidFindClass("s3eIOSAppirater");
    if (!cls)
        goto fail;

    // Get its constructor
    cons = env->GetMethodID(cls, "<init>", "()V");
    if (!cons)
        goto fail;

    // Construct the java class
    obj = env->NewObject(cls, cons);
    if (!obj)
        goto fail;

    // Get all the extension methods
    g_s3eIOSAppiraterParams = env->GetMethodID(cls, "s3eIOSAppiraterParams", "(IIIIILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
    if (!g_s3eIOSAppiraterParams)
        goto fail;

    g_s3eIOSAppiraterAppLaunched = env->GetMethodID(cls, "s3eIOSAppiraterAppLaunched", "(Z)V");
    if (!g_s3eIOSAppiraterAppLaunched)
        goto fail;

    g_s3eIOSAppiraterAppEnteredForeground = env->GetMethodID(cls, "s3eIOSAppiraterAppEnteredForeground", "(Z)V");
    if (!g_s3eIOSAppiraterAppEnteredForeground)
        goto fail;

    g_s3eIOSAppiraterUserDidSignificantEvent = env->GetMethodID(cls, "s3eIOSAppiraterUserDidSignificantEvent", "(Z)V");
    if (!g_s3eIOSAppiraterUserDidSignificantEvent)
        goto fail;

    g_s3eIOSAppiraterRateApp = env->GetMethodID(cls, "s3eIOSAppiraterRateApp", "()V");
    if (!g_s3eIOSAppiraterRateApp)
        goto fail;



    IwTrace(IOSAPPIRATER, ("IOSAPPIRATER init success"));
    g_Obj = env->NewGlobalRef(obj);
    env->DeleteLocalRef(obj);
    env->DeleteGlobalRef(cls);

    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;

fail:
    jthrowable exc = env->ExceptionOccurred();
    if (exc)
    {
        env->ExceptionDescribe();
        env->ExceptionClear();
        IwTrace(s3eIOSAppirater, ("One or more java methods could not be found"));
    }
    return S3E_RESULT_ERROR;

}

void s3eIOSAppiraterTerminate_platform()
{
    // Add any platform-specific termination code here
}

void s3eIOSAppiraterParams_platform(int appId, int usesUntilPrompt, int daysUntilPrompt, int daysRemindLater, int numSignificantEvents, const char * rateNowTitle, const char * rateNowText, const char * rateNowYesButton, const char * rateNowNoButton, const char * remindTitle, const char * remindText, const char * remindYesButton, const char * remindNoButton)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring rateNowTitle_jstr = env->NewStringUTF(rateNowTitle);
    jstring rateNowText_jstr = env->NewStringUTF(rateNowText);
    jstring rateNowYesButton_jstr = env->NewStringUTF(rateNowYesButton);
    jstring rateNowNoButton_jstr = env->NewStringUTF(rateNowNoButton);
    jstring remindTitle_jstr = env->NewStringUTF(remindTitle);
    jstring remindText_jstr = env->NewStringUTF(remindText);
    jstring remindYesButton_jstr = env->NewStringUTF(remindYesButton);
    jstring remindNoButton_jstr = env->NewStringUTF(remindNoButton);
    env->CallVoidMethod(g_Obj, g_s3eIOSAppiraterParams, appId, usesUntilPrompt, daysUntilPrompt, daysRemindLater, numSignificantEvents, rateNowTitle_jstr, rateNowText_jstr, rateNowYesButton_jstr, rateNowNoButton_jstr, remindTitle_jstr, remindText_jstr, remindYesButton_jstr, remindNoButton_jstr);
}

void s3eIOSAppiraterAppLaunched_platform(bool canPromptForRating)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_s3eIOSAppiraterAppLaunched, canPromptForRating);
}

void s3eIOSAppiraterAppEnteredForeground_platform(bool canPromptForRating)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_s3eIOSAppiraterAppEnteredForeground, canPromptForRating);
}

void s3eIOSAppiraterUserDidSignificantEvent_platform(bool canPromptForRating)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_s3eIOSAppiraterUserDidSignificantEvent, canPromptForRating);
}

void s3eIOSAppiraterRateApp_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_s3eIOSAppiraterRateApp);
}
