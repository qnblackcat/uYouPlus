#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTSearchableSettingsViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTUIUtils.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import "uYouPlus.h"

NSString *UYOUPLUS_RELEASES_URL = @"https://github.com/qnblackcat/uYouPlus/releases";
NSString *UYOUPLUS_NEW_ISSUE_URL = @"https://github.com/qnblackcat/uYouPlus/issues/new?assignees=&labels=bug&projects=&template=bug.yaml&title=[v%@] %@";

// For displaying snackbars
@interface YTHUDMessage : NSObject
+ (id)messageWithText:(id)text;
- (void)setAction:(id)action;
@end

@interface GOOHUDMessageAction : NSObject
- (void)setTitle:(NSString *)title;
- (void)setHandler:(void (^)(id))handler;
@end

@interface GOOHUDManagerInternal : NSObject
- (void)showMessageMainThread:(id)message;
+ (id)sharedInstance;
@end