#import "uYouPlus.h"

// Tweak's bundle for Localizations support - @PoomSmart - https://github.com/PoomSmart/YouPiP/commit/aea2473f64c75d73cab713e1e2d5d0a77675024f
NSBundle *uYouPlusBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"uYouPlus" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/uYouPlus.bundle")];
    });
    return bundle;
}
NSBundle *tweakBundle = uYouPlusBundle();

# pragma mark - App appearance
// See uYouPlusThemes.xm

# pragma mark - Video player options
// Bring back Slide to seek - https://github.com/PoomSmart/YTABConfig/discussions/95#discussioncomment-8166019
%hook YTColdConfig
- (BOOL)speedMasterArm2FastForwardWithoutSeekBySliding {
    return IS_ENABLED(kSlideToSeek) ? NO : %orig;
}
%end

// Disable snap to chapter
%hook YTSegmentableInlinePlayerBarView
- (void)didMoveToWindow {
    %orig;
    if (IS_ENABLED(kSnapToChapter)) {
        self.enableSnapToChapter = NO;
    }
}
%end

// Disable pinch to zoom
%hook YTColdConfig
- (BOOL)videoZoomFreeZoomEnabledGlobalConfig {
    return IS_ENABLED(kPinchToZoom) ? NO : %orig;
}
%end

// Enable miniplayer for all videos
// See YTMiniPlayerEnabler.x

// Hide useless buttons under the video player by @PoomSmart
static BOOL findCell(ASNodeController *nodeController, NSArray <NSString *> *identifiers) {
    for (id child in [nodeController children]) {
        if ([child isKindOfClass:%c(ELMNodeController)]) {
            NSArray <ELMComponent *> *elmChildren = [(ELMNodeController *)child children];
            for (ELMComponent *elmChild in elmChildren) {
                for (NSString *identifier in identifiers) {
                    if ([[elmChild description] containsString:identifier])
                        return YES;
                }
            }
        }

        if ([child isKindOfClass:%c(ASNodeController)]) {
            ASDisplayNode *childNode = ((ASNodeController *)child).node; // ELMContainerNode
            NSArray *yogaChildren = childNode.yogaChildren;
            for (ASDisplayNode *displayNode in yogaChildren) {
                if ([identifiers containsObject:displayNode.accessibilityIdentifier])
                    return YES;
            }

            return findCell(child, identifiers);
        }

        return NO;
    }
    return NO;
}

%hook ASCollectionView

- (CGSize)sizeForElement:(ASCollectionElement *)element {
    if ([self.accessibilityIdentifier isEqualToString:@"id.video.scrollable_action_bar"]) {
        ASCellNode *node = [element node];
        ASNodeController *nodeController = [node controller];
        if (IS_ENABLED(kHideRemixButton) && findCell(nodeController, @[@"id.video.remix.button"])) {
            return CGSizeZero;
        }
        
        if (IS_ENABLED(kHideClipButton) && findCell(nodeController, @[@"clip_button.eml"])) {
            return CGSizeZero;
        }
        
        if (IS_ENABLED(kHideDownloadButton) && findCell(nodeController, @[@"id.ui.add_to.offline.button"])) {
            return CGSizeZero;
        }
    }
    return %orig;
}

%end

// Use stock iOS volume HUD
// Use YTColdConfig's method instead of YTStockVolumeHUD.xm, see https://x.com/PoomSmart/status/1756904290445332653
%hook YTColdConfig
- (BOOL)iosUseSystemVolumeControlInFullscreen {
    return IS_ENABLED(kStockVolumeHUD) ? YES : %orig;
}
%end

# pragma mark - Video control overlay options

%hook YTMainAppControlsOverlayView
// Hide autoplay switch
- (void)setAutoplaySwitchButtonRenderer:(id)arg1 { // hide Autoplay
    if (IS_ENABLED(kHideAutoplaySwitch)) {}
    else { return %orig; }
}
// Hide CC button
- (void)setClosedCaptionsOrSubtitlesButtonAvailable:(BOOL)arg1 {
    return IS_ENABLED(kHideCC) ? %orig(NO) : %orig;
}
%end

// Hide HUD Messages
%hook YTHUDMessageView
- (id)initWithMessage:(id)arg1 dismissHandler:(id)arg2 {
    return IS_ENABLED(kHideHUD) ? nil : %orig;
}
%end

// Hide paid promotion banner
// See YTNoPaidPromo.x

// Hide channel watermark
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark {
    if (IS_ENABLED(kHideChannelWatermark)) {}
    else { return %orig; }
}
%end
%hook YTColdConfig
- (BOOL)iosEnableFeaturedChannelWatermarkOverlayFix {
    return IS_ENABLED(kHideChannelWatermark) ? NO : %orig;
}
%end

// Bring back the red progress bar - old versions
%hook YTInlinePlayerBarContainerView
- (id)quietProgressBarColor {
    return IS_ENABLED(kRedProgressBar) ? [UIColor redColor] : %orig;
}
%end

// Bring back the red progress bar - new versions
%hook YTPlayerBarRectangleDecorationView
- (void)drawRectangleDecorationWithSideMasks:(CGRect)rect {
    if (IS_ENABLED(kRedProgressBar)) {
        YTIPlayerBarDecorationModel *model = [self valueForKey:@"_model"];
        int overlayMode = model.playingState.overlayMode;
        model.playingState.overlayMode = 1;
        %orig;
        model.playingState.overlayMode = overlayMode;
    } else
        %orig;
}
%end

// Hide videos' end screens
// See YTNoHoverCards.x

// Hide engagement panels in full screen
%hook YTColdConfig
- (BOOL)isLandscapeEngagementPanelEnabled {
    return IS_ENABLED(kHideRightPanel) ? NO : %orig;
}
%end

// Skips content warning before playing *some videos - @PoomSmart
%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert { [self confirmAlertDidPressConfirm]; }
%end

# pragma mark - Shorts controls overlay options

// Hide "Buy Super Thanks" banner
%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if ((IS_ENABLED(kHideBuySuperThanks)) && ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.suggested_action"])) { 
        self.hidden = YES; 
    }
}
%end

// Hide subscriptions button
%hook YTReelWatchRootViewController
- (void)setPausedStateCarouselView {
    if (IS_ENABLED(kHideSubscriptions)) {}
    else { return %orig; }
}
%end

# pragma mark - Miscellaneous

// Hide iSponsorBlock
%hook YTRightNavigationButtons
- (void)didMoveToWindow {
    %orig;
    if (IS_ENABLED(kHideiSponsorBlockButton)) {
        self.sponsorBlockButton.hidden = YES;
        self.sponsorBlockButton.frame = CGRectZero;
    }
}
%end

// Disable hints - https://github.com/LillieH001/YouTube-Reborn/blob/v4/
%group gDisableHints
%hook YTSettings
- (BOOL)areHintsDisabled {
	return YES;
}
- (void)setHintsDisabled:(BOOL)arg1 {
    %orig(YES);
}
%end
%hook YTUserDefaults
- (BOOL)areHintsDisabled {
	return YES;
}
- (void)setHintsDisabled:(BOOL)arg1 {
    %orig(YES);
}
%end
%end

// Enable YouTube startup animation
%hook YTColdConfig
- (BOOL)mainAppCoreClientIosEnableStartupAnimation {
    return IS_ENABLED(kYTStartupAnimation) ? YES : NO;
}
%end

// Hide upper bar
%group gHideChipBar
%hook YTMySubsFilterHeaderView 
- (void)setChipFilterView:(id)arg1 {}
%end

%hook YTHeaderContentComboView
- (void)enableSubheaderBarWithView:(id)arg1 {}
%end

%hook YTHeaderContentComboView
- (void)setFeedHeaderScrollMode:(int)arg1 { %orig(0); }
%end
%end

// Hide "Play next in queue" - qnblackcat/uYouPlus#1138
%hook YTMenuItemVisibilityHandler
- (BOOL)shouldShowServiceItemRenderer:(YTIMenuConditionalServiceItemRenderer *)renderer {
    return IS_ENABLED(kHidePlayNextInQueue) && renderer.icon.iconType == 251 && renderer.secondaryIcon.iconType == 741 ? NO : %orig;
}
%end

// Force iPhone layout
%group giPhoneLayout
%hook UIDevice
- (long long)userInterfaceIdiom {
    return NO;
} 
%end
%hook UIStatusBarStyleAttributes
- (long long)idiom {
    return YES;
} 
%end
%hook UIKBTree
- (long long)nativeIdiom {
    return YES;
} 
%end
%hook UIKBRenderer
- (long long)assetIdiom {
    return YES;
} 
%end
%end

# pragma mark - Other hooks

// Activate FLEX
%hook YTAppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    BOOL didFinishLaunching = %orig;
    if (IS_ENABLED(kFlex)) {
        [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
    }
    return didFinishLaunching;
}
- (void)appWillResignActive:(id)arg1 {
    %orig;
    if (IS_ENABLED(kFlex)) {
        [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
    }
}
%end

// Hide YouTube annoying banner in Home page? - @MiRO92 - YTNoShorts: https://github.com/MiRO92/YTNoShorts
%hook YTAsyncCollectionView
- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = %orig;
    if ([cell isKindOfClass:NSClassFromString(@"_ASCollectionViewCell")]) {
        _ASCollectionViewCell *cell = %orig;
        if ([cell respondsToSelector:@selector(node)]) {
            if ([[[cell node] accessibilityIdentifier] isEqualToString:@"statement_banner.view"]) { [self removeShortsAndFeaturesAdsAtIndexPath:indexPath]; }
            if ([[[cell node] accessibilityIdentifier] isEqualToString:@"compact.view"]) { [self removeShortsAndFeaturesAdsAtIndexPath:indexPath]; }
            // if ([[[cell node] accessibilityIdentifier] isEqualToString:@"id.ui.video_metadata_carousel"]) { [self removeShortsAndFeaturesAdsAtIndexPath:indexPath]; }
        }
    }
    return %orig;
}
%new
- (void)removeShortsAndFeaturesAdsAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}
%end

// Fixes uYou crash when trying to play video (#1422)
@interface YTVarispeedSwitchController : NSObject
@end

@interface YTPlayerOverlayManager : NSObject
@property (nonatomic, assign) float currentPlaybackRate;
@property (nonatomic, strong, readonly) YTVarispeedSwitchController *varispeedController;

- (void)varispeedSwitchController:(YTVarispeedSwitchController *)varispeed didSelectRate:(float)rate;
- (void)setCurrentPlaybackRate:(float)rate;
- (void)setPlaybackRate:(float)rate;
@end

%hook YTPlayerOverlayManager
%property (nonatomic, assign) float currentPlaybackRate;

%new
- (void)setCurrentPlaybackRate:(float)rate {
    [self varispeedSwitchController:self.varispeedController didSelectRate:rate];
}

%new
- (void)setPlaybackRate:(float)rate {
    [self varispeedSwitchController:self.varispeedController didSelectRate:rate];
}
%end

// Hide search ads by @PoomSmart - https://github.com/PoomSmart/YouTube-X
// %hook YTIElementRenderer
// - (NSData *)elementData {
//     if (self.hasCompatibilityOptions && self.compatibilityOptions.hasAdLoggingData)
//         return nil;
//     return %orig;
// }
// %end

// %hook YTSectionListViewController
// - (void)loadWithModel:(YTISectionListRenderer *)model {
//     NSMutableArray <YTISectionListSupportedRenderers *> *contentsArray = model.contentsArray;
//     NSIndexSet *removeIndexes = [contentsArray indexesOfObjectsPassingTest:^BOOL(YTISectionListSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
//         YTIItemSectionRenderer *sectionRenderer = renderers.itemSectionRenderer;
//         YTIItemSectionSupportedRenderers *firstObject = [sectionRenderer.contentsArray firstObject];
//         return firstObject.hasPromotedVideoRenderer || firstObject.hasCompactPromotedVideoRenderer || firstObject.hasPromotedVideoInlineMutedRenderer;
//     }];
//     [contentsArray removeObjectsAtIndexes:removeIndexes];
//     %orig;
// }
// %end

// A/B flags
%hook YTColdConfig 
// YouRememberCaption: https://poomsmart.github.io/repo/depictions/youremembercaption.html
- (BOOL)respectDeviceCaptionSetting { return NO; }
// Swipe right to dismiss the right panel in fullscreen mode
- (BOOL)isLandscapeEngagementPanelSwipeRightToDismissEnabled { return YES; }
// Don't use new YT settings layout (Cairo Settings)
- (BOOL)mainAppCoreClientEnableCairoSettings { return NO; }
%end

# pragma mark - Constructor

%ctor {
    // Load uYou first so its functions are available for hooks.
    // dlopen([[NSString stringWithFormat:@"%@/Frameworks/uYou.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_LAZY);

    %init;
    if (IS_ENABLED(kDisableHints)) {
        %init(gDisableHints);
    }
    if (IS_ENABLED(kHideChipBar)) {
        %init(gHideChipBar);
    }
    if (IS_ENABLED(kiPhoneLayout) && (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
        %init(giPhoneLayout);
    }
    
    // Change the default value of some options
    NSArray *allKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    if (![allKeys containsObject:kHidePlayNextInQueue]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHidePlayNextInQueue];
    }
    if (![allKeys containsObject:@"relatedVideosAtTheEndOfYTVideos"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"relatedVideosAtTheEndOfYTVideos"]; 
    }
    if (![allKeys containsObject:@"shortsProgressBar"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shortsProgressBar"]; 
    }
    if (![allKeys containsObject:@"RYD-ENABLED"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RYD-ENABLED"]; 
    }
    if (![allKeys containsObject:@"YouPiPEnabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"YouPiPEnabled"]; 
    }
    if (![allKeys containsObject:kGoogleSigninFix]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kGoogleSigninFix];
    }
}
