//
//  ZFNativeAdsMediator+Facebook.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/16/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFNativeAdsMediator+Facebook.h"

NSString *const kZFNativeAdsMediatorTargetFacebook = @"Facebook";

NSString *const kZFNativeAdsMediatorActionSetFacebookDelegate = @"setDelegate";
NSString *const kZFNativeAdsMediatorActionConfigureFacebookPlacementInfo = @"configurePlacementInfo";
NSString *const kZFNativeAdsMediatorActionLoadFacebookNativeAds = @"loadNativeAds";
NSString *const kZFNativeAdsMediatorActionFetchFacebookNativeAds = @"fetchNativeAd";
NSString *const kZFNativeAdsMediatorActionRegisterFacebookAdInteraction = @"registerAdInteraction";
NSString *const kZFNativeAdsMediatorActionSetFacebookDebugLogEnable = @"setDebugLogEnable";

@implementation ZFNativeAdsMediator (Facebook)

- (void)ZFNativeAdsMediator_setFacebookDelegate:(id<ZFNativeAdsDelegate>)delegate {
    [self performTarget:kZFNativeAdsMediatorTargetFacebook
                 action:kZFNativeAdsMediatorActionSetFacebookDelegate
                 params:@{@"delegate" : delegate}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_configureFacebookPlacementInfo:(NSDictionary *)placementInfo {
    [self performTarget:kZFNativeAdsMediatorTargetFacebook
                 action:kZFNativeAdsMediatorActionConfigureFacebookPlacementInfo
                 params:@{@"placementInfo" : placementInfo}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_loadFacebookNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption preload:(BOOL)preload {
    [self performTarget:kZFNativeAdsMediatorTargetFacebook
                 action:kZFNativeAdsMediatorActionLoadFacebookNativeAds
                 params:@{@"placementKey" : placementKey,
                          @"loadImageOption" : @(loadImageOption),
                          @"preload" : @(preload)}
      shouldCacheTarget:NO];
}

- (ZFReformedNativeAd *)ZFNativeAdsMediator_fetchFacebookNativeAd:(NSString *)placementKey {
    return  [self performTarget:kZFNativeAdsMediatorTargetFacebook
                         action:kZFNativeAdsMediatorActionFetchFacebookNativeAds
                         params:@{@"placementKey" : placementKey}
              shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_registerFacebookAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view {
    [self performTarget:kZFNativeAdsMediatorTargetFacebook
                 action:kZFNativeAdsMediatorActionRegisterFacebookAdInteraction
                 params:@{@"reformedAd" : reformedAd,
                          @"view" : view}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_setFacebookDebugLogEnable:(BOOL)enable {
    [self performTarget:kZFNativeAdsMediatorTargetFacebook
                 action:kZFNativeAdsMediatorActionSetFacebookDebugLogEnable
                 params:@{@"debugLogEnable" : @(enable)}
      shouldCacheTarget:NO];
}

@end
