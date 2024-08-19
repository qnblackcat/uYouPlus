#import "uYouPlusThemes.h"

#define IS_DARK_APPEARANCE_ENABLED ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1)
#define IS_OLD_DARK_THEME_SELECTED (APP_THEME_IDX == 1)
#define IS_OLED_DARK_THEME_SELECTED (APP_THEME_IDX == 2)

# pragma mark - Old dark theme (lighter grey)

%group gOldDarkTheme
%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteTextColorForNative { return NO; }
- (BOOL)enableCinematicContainerOnClient { return NO; }
%end

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor clearColor]; }
    if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor clearColor]; }
}
%end

%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;
    self.superview.backgroundColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
}
%end

%hook YTFullscreenEngagementOverlayView
- (void)didMoveToWindow {
    %orig;
    self.subviews[0].backgroundColor = [UIColor clearColor];
}
%end

%hook YTRelatedVideosView
- (void)didMoveToWindow {
    %orig;
    self.subviews[0].backgroundColor = [UIColor clearColor];
}
%end
%end

# pragma mark - OLED dark mode by BandarHL

UIColor* raisedColor = [UIColor colorWithRed:0.035 green:0.035 blue:0.035 alpha:1.0];

%group gOLED
%hook YTCommonColorPalette
- (UIColor *)baseBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundSolid {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundPrimary {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundSecondary {
    return self.pageStyle == 1 ? [[UIColor blackColor] colorWithAlphaComponent:0.9] : %orig;
}
- (UIColor *)raisedBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)staticBrandBlack {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)generalBackgroundA {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

// uYou settings
%hook UITableViewCell
- (void)_layoutSystemBackgroundView {
    %orig;
    UIView *systemBackgroundView = [self valueForKey:@"_systemBackgroundView"];
    NSString *backgroundViewKey = class_getInstanceVariable(systemBackgroundView.class, "_colorView") ? @"_colorView" : @"_backgroundView";
    ((UIView *)[systemBackgroundView valueForKey:backgroundViewKey]).backgroundColor = [UIColor blackColor];
}
- (void)_layoutSystemBackgroundView:(BOOL)arg1 {
    %orig;
    ((UIView *)[[self valueForKey:@"_systemBackgroundView"] valueForKey:@"_colorView"]).backgroundColor = [UIColor blackColor];
}
%end

%hook settingsReorderTable
- (void)viewDidLayoutSubviews {
    %orig;
    self.tableView.backgroundColor = [UIColor blackColor];
}
%end

%hook FRPSelectListTable
- (void)viewDidLayoutSubviews {
    %orig;
    self.tableView.backgroundColor = [UIColor blackColor];
}
%end

%hook FRPreferences
- (void)viewDidLayoutSubviews {
    %orig;
    self.tableView.backgroundColor = [UIColor blackColor];
}
%end

%hook YTInnerTubeCollectionViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

// Explore
%hook ASScrollView 
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

// Download sort
%hook GOODialogView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
%end

// Playlist sort
%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED && [self.nextResponder isKindOfClass:%c(_ASDisplayView)]) {
        self.superview.backgroundColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

// iSponsorBlock
%hook SponsorBlockSettingsController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.tableView.backgroundColor = [UIColor blackColor];
    } else { return %orig; }
}
%end

%hook SponsorBlockViewController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.view.backgroundColor = [UIColor blackColor];
    } else { return %orig; }
}
%end

// Others
%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        
        //
        UIResponder *responder = self.nextResponder;
        UIViewController *closestViewController = nil;
    
        while (responder != nil) {
            if ([responder isKindOfClass:[UIViewController class]]) {
                closestViewController = (UIViewController *)responder;
                break;
            }
            responder = responder.nextResponder;
        }

        if ([NSStringFromClass([closestViewController class]) isEqualToString:@"YTActionSheetDialogViewController"] && 
            (([NSStringFromClass([self.superview class]) isEqualToString:@"YTELMView"]) || 
            [NSStringFromClass([self.superview class]) isEqualToString:@"_ASDisplayView"] || 
            [NSStringFromClass([self.superview class]) isEqualToString:@"ELMView"])) {
            
            self.backgroundColor = [UIColor clearColor];
        }

        // Save video bottom
        if ([NSStringFromClass([closestViewController class]) isEqualToString:@"YTBottomSheetController"]) { self.backgroundColor = [UIColor clearColor]; } 

        //  Subcriptions header
        if ([NSStringFromClass([closestViewController class]) isEqualToString:@"YTMySubsFilterHeaderViewController"] && 
            ([NSStringFromClass([self.superview class]) isEqualToString:@"YTELMView"])) { 
            self.backgroundColor = [UIColor clearColor]; 
        } 

        if ([self.accessibilityIdentifier isEqualToString:@"eml.live_chat_text_message"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.comment_group_detail_container"]) { self.backgroundColor = [UIColor clearColor]; }
    }
}
%end

// Open link with...
%hook ASWAppSwitchingSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig(raisedColor) : %orig;
}
%end

%hook ASWAppSwitchingSheetFooterView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig(raisedColor) : %orig;
}
%end

%hook ASWAppSwitcherCollectionViewCell
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        self.backgroundColor = raisedColor;
        self.superview.backgroundColor = raisedColor;
    }
}
%end

// Incompatibility with the new YT Dark theme
%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
%end
%end

# pragma mark - OLED keyboard by @ichitaso <3 - http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e

%group gOLEDKB 
%hook TUIEmojiSearchView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIPredictionViewController
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UICandidateViewController
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UIKeyboardDockView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKeyboardLayoutStar 
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKBRenderConfig // Prediction text color
- (void)setLightKeyboard:(BOOL)arg1 { %orig(NO); }
%end
%end

%ctor {
    if (IS_OLED_DARK_THEME_SELECTED) {
        %init(gOLED);
    }
    if (IS_OLD_DARK_THEME_SELECTED) {
        %init(gOldDarkTheme)
    }
    if (IS_ENABLED(kOLEDKeyboard)) {
        %init(gOLEDKB);
    }
}
