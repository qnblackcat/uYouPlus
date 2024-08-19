#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <sys/utsname.h>
#import <substrate.h>
#import <rootless.h>

#import "uYouPlusThemes.h" // Hide "Buy Super Thanks" banner (_ASDisplayView)
#import <YouTubeHeader/YTAppDelegate.h> // Activate FLEX
#import <YouTubeHeader/YTIMenuConditionalServiceItemRenderer.h>
#import <YouTubeHeader/YTIPlayerBarDecorationModel.h>
#import <YouTubeHeader/YTPlayerBarRectangleDecorationView.h>

// Hide buttons under the video player by @PoomSmart
#import <YouTubeHeader/ASCollectionElement.h>
#import <YouTubeHeader/ASCollectionView.h>
#import <YouTubeHeader/ELMNodeController.h>

// #import <YouTubeHeader/YTISectionListRenderer.h> // Hide search ads by @PoomSmart - https://github.com/PoomSmart/YouTube-X

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
#define IS_ENABLED(k) [[NSUserDefaults standardUserDefaults] boolForKey:k]
#define APP_THEME_IDX [[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"]

// Keys
// App appearance
static NSString *const kAppTheme = @"appTheme";
static NSString *const kOLEDKeyboard = @"oledKeyBoard_enabled";
// Video player
static NSString *const kSlideToSeek = @"slideToSeek_enabled";
static NSString *const kSnapToChapter = @"snapToChapter_enabled";
static NSString *const kPinchToZoom = @"pinchToZoom_enabled";
static NSString *const kYTMiniPlayer = @"ytMiniPlayer_enabled";
static NSString *const kHideRemixButton = @"hideRemixButton_enabled";
static NSString *const kHideClipButton = @"hideClipButton_enabled";
static NSString *const kHideDownloadButton = @"hideDownloadButton_enabled";
static NSString *const kStockVolumeHUD = @"stockVolumeHUD_enabled";
// Video controls overlay
static NSString *const kHideAutoplaySwitch = @"hideAutoplaySwitch_enabled";
static NSString *const kHideCC = @"hideCC_enabled";
static NSString *const kHideHUD = @"hideHUD_enabled";
static NSString *const kHidePaidPromotionCard = @"hidePaidPromotionCard_enabled";
static NSString *const kHideChannelWatermark = @"hideChannelWatermark_enabled";
static NSString *const kRedProgressBar = @"redProgressBar_enabled";
static NSString *const kHideHoverCards = @"hideHoverCards_enabled";
static NSString *const kHideRightPanel = @"hideRightPanel_enabled";
// Shorts control overlay
static NSString *const kHideBuySuperThanks = @"hideBuySuperThanks_enabled";
static NSString *const kHideSubscriptions = @"hideSubscriptions_enabled";
// Miscellaneous
static NSString *const kHideiSponsorBlockButton = @"hideiSponsorBlockButton_enabled";
static NSString *const kDisableHints = @"disableHints_enabled";
static NSString *const kYTStartupAnimation = @"ytStartupAnimation_enabled";
static NSString *const kHideChipBar = @"hideChipBar_enabled";
static NSString *const kHidePlayNextInQueue = @"hidePlayNextInQueue_enabled";
static NSString *const kiPhoneLayout = @"iPhoneLayout_enabled";
static NSString *const kBigYTMiniPlayer = @"bigYTMiniPlayer_enabled";
static NSString *const kReExplore = @"reExplore_enabled";
static NSString *const kGoogleSigninFix = @"googleSigninFix_enabled";
static NSString *const kFlex = @"flex_enabled";

// Disable snap to chapter
@interface YTSegmentableInlinePlayerBarView
@property (nonatomic, assign, readwrite) BOOL enableSnapToChapter;
@end

// Hide autoplay switch / CC button
@interface YTMainAppControlsOverlayView : UIView
@end

// Skips content warning before playing *some videos - @PoomSmart
@interface YTPlayabilityResolutionUserActionUIController : NSObject
- (void)confirmAlertDidPressConfirm;
@end

// Hide iSponsorBlock
@interface YTRightNavigationButtons : UIView
@property (nonatomic, readwrite, strong) UIView *sponsorBlockButton;
@end

// Hide YouTube annoying banner in Home page? - @MiRO92 - YTNoShorts: https://github.com/MiRO92/YTNoShorts
@interface _ASCollectionViewCell : UICollectionViewCell
- (id)node;
@end
@interface YTAsyncCollectionView : UICollectionView
- (void)removeShortsAndFeaturesAdsAtIndexPath:(NSIndexPath *)indexPath;
@end