#import "uYouPlusSettings.h"

#define VERSION_STRING [[NSString stringWithFormat:@"%@", @(OS_STRINGIFY(TWEAK_VERSION))] stringByReplacingOccurrencesOfString:@"\"" withString:@""]
#define SHOW_RELAUNCH_YT_SNACKBAR [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:LOC(@"RESTART_YOUTUBE")]]

#define SECTION_HEADER(text) \
    [sectionItems addObject:[%c(YTSettingsSectionItem) \
        itemWithTitle:@"\t" \
        titleDescription:[text uppercaseString] \
        accessibilityIdentifier:nil \
        detailTextBlock:nil \
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) { return NO; } \
    ]]

#define SWITCH(title, description, key, ...) \
    [sectionItems addObject:[%c(YTSettingsSectionItem) \
        switchItemWithTitle:title \
        titleDescription:description \
        accessibilityIdentifier:nil \
        switchOn:IS_ENABLED(key) \
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) { \
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:key]; \
            __VA_ARGS__; \
            return YES; \
        } \
        settingItemId:0 \
    ]]

#define SWITCH2(title, description, key) \
    SWITCH(title, description, key, SHOW_RELAUNCH_YT_SNACKBAR)

NSArray *copyKeys = @[
    // UYOUPLUS - Video player Keys
    kSlideToSeek,
    kSnapToChapter,
    kPinchToZoom,
    kYTMiniPlayer,
    kHideRemixButton,
    kHideClipButton,
    kHideDownloadButton,
    kStockVolumeHUD,
    // UYOUPLUS - Video controls overlay Keys
    kHideAutoplaySwitch,
    kHideCC,
    kHideHUD,
    kHidePaidPromotionCard,
    kHideChannelWatermark,
    kRedProgressBar,
    kHideHoverCards,
    kHideRightPanel,
    // UYOUPLUS - Shorts controls overlay Keys
    kHideBuySuperThanks,
    kHideSubscriptions,
    // UYOUPLUS - Miscellaneous Keys
    kHideiSponsorBlockButton,
    kDisableHints,
    kYTStartupAnimation,
    kHideChipBar,
    kHidePlayNextInQueue,
    kiPhoneLayout,
    kBigYTMiniPlayer,
    kReExplore,
    kGoogleSigninFix,
    kFlex,
    // uYou Keys (some of them) - https://github.com/miro92/uyou-for-youtube
    @"showedWelcomeVC",
    @"hideShortsTab",
    @"hideCreateTab",
    @"hideCastButton",
    @"relatedVideosAtTheEndOfYTVideos",
    @"removeYouTubeAds",
    @"backgroundPlayback",
    @"disableAgeRestriction",
    @"iPadLayout",
    @"noSuggestedVideoAtEnd",
    @"shortsProgressBar",
    @"hideShortsCells",
    @"removeShortsCell",
    @"startupPage",
    // DontEatMyContent Keys - https://github.com/therealFoxster/DontEatMyContent/blob/master/Tweak.h
    @"DEMC_enabled", @"DEMC_colorViewsEnabled", @"DEMC_safeAreaConstant", @"DEMC_disableAmbientMode", 
    @"DEMC_limitZoomToFill", @"DEMC_enableForAllVideos",
    // Return YouTube Dislikes Keys - https://github.com/PoomSmart/Return-YouTube-Dislikes/blob/main/TweakSettings.h
    @"RYD-ENABLED", @"RYD-VOTE-SUBMISSION", @"RYD-EXACT-LIKE-NUMBER", @"RYD-EXACT-NUMBER",
    // YTVideoOverlay Keys - https://github.com/therealFoxster/DontEatMyContent/blob/master/Tweak.h
    @"YTVideoOverlay-YouMute-Enabled", @"YTVideoOverlay-YouQuality-Enabled", 
    @"YTVideoOverlay-YouMute-Position", @"YTVideoOverlay-YouQuality-Position",
    // YouPiP Keys - https://github.com/PoomSmart/YouPiP/blob/main/Header.h
    @"YouPiPPosition", @"CompatibilityModeKey", @"PiPActivationMethodKey", @"PiPActivationMethod2Key", 
    @"NoMiniPlayerPiPKey", @"NonBackgroundableKey",
    // YTUHD Keys - https://github.com/PoomSmart/YTUHD/blob/master/Header.h
    @"EnableVP9",
    @"AllVP9",
    // YouTube Keys
    @"inline_muted_playback_enabled"
];

static const NSInteger uYouPlusSection = 500;

@interface YTSettingsSectionItemManager (uYouPlus)
- (void)updateTweakSectionWithEntry:(id)entry;
@end

extern NSBundle *uYouPlusBundle();

// Settings
%hook YTAppSettingsPresentationData
+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        NSMutableArray <NSNumber *> *mutableOrder = [order mutableCopy];
        [mutableOrder insertObject:@(uYouPlusSection) atIndex:insertIndex + 1];
        order = mutableOrder.copy;
    }
    return order;
}
%end

%hook YTSettingsSectionController
- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}
%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateTweakSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = uYouPlusBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    # pragma mark - About
    // SECTION_HEADER(LOC(@"ABOUT"));

    YTSettingsSectionItem *version = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"VERSION")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return VERSION_STRING;
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:UYOUPLUS_RELEASES_URL]];
        }
    ];
    [sectionItems addObject:version];

    YTSettingsSectionItem *bug = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"REPORT_AN_ISSUE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSString *url = [NSString stringWithFormat:UYOUPLUS_NEW_ISSUE_URL, VERSION_STRING, LOC(@"ADD_TITLE")];

            return [%c(YTUIUtils) openURL:[NSURL URLWithString:url]];
        }
    ];
    [sectionItems addObject:bug];

    YTSettingsSectionItem *copySettings = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"COPY_SETTINGS")
        titleDescription:LOC(@"COPY_SETTINGS_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSMutableString *settingsString = [NSMutableString string];
                for (NSString *key in copyKeys) {
                    if ([userDefaults objectForKey:key]) {
                        NSString *value = [userDefaults objectForKey:key];
                        [settingsString appendFormat:@"%@: %@\n", key, value];
                    }
                }       
                [[UIPasteboard generalPasteboard] setString:settingsString];
                // Show a confirmation message or perform some other action here
                return YES;
            }
    ];
    [sectionItems addObject:copySettings];

    YTSettingsSectionItem *pasteSettings = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"PASTE_SETTINGS")
        titleDescription:LOC(@"PASTE_SETTINGS_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                UIAlertController *confirmPasteAlert = [UIAlertController alertControllerWithTitle:LOC(@"PASTE_SETTINGS_ALERT") message:nil preferredStyle:UIAlertControllerStyleAlert];
                [confirmPasteAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                [confirmPasteAlert addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSString *settingsString = [[UIPasteboard generalPasteboard] string];
                    if (settingsString.length > 0) {
                        NSArray *lines = [settingsString componentsSeparatedByString:@"\n"];
                        for (NSString *line in lines) {
                            NSArray *components = [line componentsSeparatedByString:@": "];
                            if (components.count == 2) {
                                NSString *key = components[0];
                                NSString *value = components[1];
                                [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
                            }
                        }
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                    }
                }]];
                [settingsViewController presentViewController:confirmPasteAlert animated:YES completion:nil];
                return YES;
            }
    ];
    [sectionItems addObject:pasteSettings];

    YTSettingsSectionItem *exitYT = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"QUIT_YOUTUBE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // https://stackoverflow.com/a/17802404/19227228
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:0.5];
            exit(0);
        }
    ];
    [sectionItems addObject:exitYT];

    # pragma mark - App theme
    SECTION_HEADER(LOC(@"APP_THEME"));

    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass
        itemWithTitle:LOC(@"DARK_THEME")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (APP_THEME_IDX) {
                case 1:
                    return LOC(@"OLD_DARK_THEME");
                case 2:
                    return LOC(@"OLED_DARK_THEME_2");
                case 0:
                default:
                    return LOC(@"DEFAULT_THEME");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"DEFAULT_THEME")
                    titleDescription:LOC(@"DEFAULT_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kAppTheme];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME")
                    titleDescription:LOC(@"OLD_DARK_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kAppTheme];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    checkmarkItemWithTitle:LOC(@"OLED_DARK_THEME")
                    titleDescription:LOC(@"OLED_DARK_THEME_DESC")
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:kAppTheme];
                        [settingsViewController reloadData];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                ],
                [YTSettingsSectionItemClass
                    switchItemWithTitle:LOC(@"OLED_KEYBOARD")
                    titleDescription:LOC(@"OLED_KEYBOARD_DESC")
                    accessibilityIdentifier:nil
                    switchOn:IS_ENABLED(kOLEDKeyboard)
                    switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kOLEDKeyboard];
                        SHOW_RELAUNCH_YT_SNACKBAR;
                        return YES;
                    }
                    settingItemId:0
                ]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc]
                initWithNavTitle:LOC(@"DARK_THEME")
                pickerSectionTitle:[LOC(@"DARK_THEME") uppercaseString]
                rows:rows selectedItemIndex:APP_THEME_IDX
                parentResponder:[self parentResponder]
            ];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];
    [sectionItems addObject:themeGroup];

    # pragma mark - Video player options
    SECTION_HEADER(LOC(@"VIDEO_PLAYER_OPTIONS"));

    SWITCH2(LOC(@"SLIDE_TO_SEEK"), LOC(@"SLIDE_TO_SEEK_DESC"), kSlideToSeek);
    SWITCH2(LOC(@"SNAP_TO_CHAPTER"), LOC(@"SNAP_TO_CHAPTER_DESC"), kSnapToChapter);
    SWITCH2(LOC(@"PINCH_TO_ZOOM"), LOC(@"PINCH_TO_ZOOM_DESC"), kPinchToZoom);
    SWITCH(LOC(@"YT_MINIPLAYER"), LOC(@"YT_MINIPLAYER_DESC"), kYTMiniPlayer);
    SWITCH(LOC(@"HIDE_REMIX_BUTTON"), LOC(@"HIDE_REMIX_BUTTON_DESC"), kHideRemixButton);
    SWITCH(LOC(@"HIDE_CLIP_BUTTON"), LOC(@"HIDE_CLIP_BUTTON_DESC"), kHideClipButton);
    SWITCH(LOC(@"HIDE_DOWNLOAD_BUTTON"), LOC(@"HIDE_DOWNLOAD_BUTTON_DESC"), kHideDownloadButton);
    SWITCH(LOC(@"STOCK_VOLUME_HUD"), LOC(@"STOCK_VOLUME_HUD_DESC"), kStockVolumeHUD);
    SWITCH(LOC(@"REPLACE_YT_DOWNLOAD_WITH_UYOU"), LOC(@"REPLACE_YT_DOWNLOAD_WITH_UYOU_DESC"), kReplaceYTDownloadWithuYou);

    # pragma mark - Video controls overlay options
    SECTION_HEADER(LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS"));

    SWITCH(LOC(@"HIDE_AUTOPLAY_SWITCH"), LOC(@"HIDE_AUTOPLAY_SWITCH_DESC"), kHideAutoplaySwitch);
    SWITCH(LOC(@"HIDE_SUBTITLES_BUTTON"), LOC(@"HIDE_SUBTITLES_BUTTON_DESC"), kHideCC);
    SWITCH(LOC(@"HIDE_HUD_MESSAGES"), LOC(@"HIDE_HUD_MESSAGES_DESC"), kHideHUD);
    SWITCH(LOC(@"HIDE_PAID_PROMOTION_CARDS"), LOC(@"HIDE_PAID_PROMOTION_CARDS_DESC"), kHidePaidPromotionCard);
    SWITCH2(LOC(@"HIDE_CHANNEL_WATERMARK"), LOC(@"HIDE_CHANNEL_WATERMARK_DESC"), kHideChannelWatermark);
    SWITCH2(LOC(@"RED_PROGRESS_BAR"), LOC(@"RED_PROGRESS_BAR_DESC"), kRedProgressBar);
    SWITCH(LOC(@"HIDE_HOVER_CARD"), LOC(@"HIDE_HOVER_CARD_DESC"), kHideHoverCards);
    SWITCH2(LOC(@"HIDE_RIGHT_PANEL"), LOC(@"HIDE_RIGHT_PANEL_DESC"), kHideRightPanel);

    # pragma mark - Shorts controls overlay options
    SECTION_HEADER(LOC(@"SHORTS_CONTROLS_OVERLAY_OPTIONS"));

    SWITCH(LOC(@"HIDE_SUPER_THANKS"), LOC(@"HIDE_SUPER_THANKS_DESC"), kHideBuySuperThanks);
    SWITCH(LOC(@"HIDE_SUBCRIPTIONS"), LOC(@"HIDE_SUBCRIPTIONS_DESC"), kHideSubscriptions);

    # pragma mark - Miscellaneous
    SECTION_HEADER(LOC(@"MISCELLANEOUS"));

    SWITCH(LOC(@"HIDE_ISPONSORBLOCK"), nil, kHideiSponsorBlockButton);
    SWITCH(LOC(@"DISABLE_HINTS"), LOC(@"DISABLE_HINTS_DESC"), kDisableHints);
    SWITCH2(LOC(@"ENABLE_YT_STARTUP_ANIMATION"), LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC"), kYTStartupAnimation);
    SWITCH(LOC(@"HIDE_CHIP_BAR"), LOC(@"HIDE_CHIP_BAR_DESC"), kHideChipBar);
    SWITCH(LOC(@"HIDE_PLAY_NEXT_IN_QUEUE"), LOC(@"HIDE_PLAY_NEXT_IN_QUEUE_DESC"), kHidePlayNextInQueue);
    SWITCH2(LOC(@"IPHONE_LAYOUT"), LOC(@"IPHONE_LAYOUT_DESC"), kiPhoneLayout);
    SWITCH2(LOC(@"NEW_MINIPLAYER_STYLE"), LOC(@"NEW_MINIPLAYER_STYLE_DESC"), kBigYTMiniPlayer);
    SWITCH2(LOC(@"YT_RE_EXPLORE"), LOC(@"YT_RE_EXPLORE_DESC"), kReExplore);
    SWITCH(LOC(@"GOOGLE_SIGNIN_FIX"), LOC(@"GOOGLE_SIGNIN_FIX_DESC"), kGoogleSigninFix);
    SWITCH(LOC(@"ENABLE_FLEX"), LOC(@"ENABLE_FLEX_DESC"), kFlex);

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [settingsViewController setSectionItems:sectionItems forCategory:uYouPlusSection title:@"uYouPlus" icon:nil titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
    else
        [settingsViewController setSectionItems:sectionItems forCategory:uYouPlusSection title:@"uYouPlus" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == uYouPlusSection) {
        [self updateTweakSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
