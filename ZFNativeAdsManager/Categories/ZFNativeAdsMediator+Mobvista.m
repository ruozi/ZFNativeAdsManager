//
//  ZFNativeAdsMediator+Mobvista.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/16/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFNativeAdsMediator+Mobvista.h"

NSString *const kZFNativeAdsMediatorTargetMobvista = @"Mobvista";

NSString *const kZFNativeAdsMediatorActionSetMobvistaDelegate = @"setDelegate";
NSString *const kZFNativeAdsMediatorActionConfigureMobvistaAppInfo = @"configureAppInfo";
NSString *const kZFNativeAdsMediatorActionConfigureMobvistaPlacementInfo = @"configurePlacementInfo";
NSString *const kZFNativeAdsMediatorActionLoadMobvistaNativeAds = @"loadNativeAds";
NSString *const kZFNativeAdsMediatorActionFetchMobvistaNativeAds = @"fetchNativeAd";
NSString *const kZFNativeAdsMediatorActionRegisterMobvistaAdInteraction = @"registerAdInteraction";
NSString *const kZFNativeAdsMediatorActionSetMobvistaDebugLogEnable = @"setDebugLogEnable";

@implementation ZFNativeAdsMediator (Mobvista)

- (void)ZFNativeAdsMediator_setMobvistaDelegate:(id<ZFNativeAdsDelegate>)delegate {
    [self performTarget:kZFNativeAdsMediatorTargetMobvista
                 action:kZFNativeAdsMediatorActionSetMobvistaDelegate
                 params:@{@"delegate" : delegate}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_configureMobvistaAppId:(NSString *)appId apiKey:(NSString *)apiKey {
    [self performTarget:kZFNativeAdsMediatorTargetMobvista
                 action:kZFNativeAdsMediatorActionConfigureMobvistaAppInfo
                 params:@{@"appId" : appId,
                          @"apiKey" : apiKey}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_configureMobvistaWithPlacementInfo:(NSDictionary *)placementInfo {
    [self performTarget:kZFNativeAdsMediatorTargetMobvista
                 action:kZFNativeAdsMediatorActionConfigureMobvistaPlacementInfo
                 params:@{@"placementInfo" : placementInfo}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_loadMobvistaNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption {
    [self performTarget:kZFNativeAdsMediatorTargetMobvista
                 action:kZFNativeAdsMediatorActionLoadMobvistaNativeAds
                 params:@{@"placementKey" : placementKey,
                          @"loadImageOption" : @(loadImageOption)}
      shouldCacheTarget:NO];
}

- (ZFReformedNativeAd *)ZFNativeAdsMediator_fetchMobvistaNativeAd:(NSString *)placementKey {
    return  [self performTarget:kZFNativeAdsMediatorTargetMobvista
                         action:kZFNativeAdsMediatorActionFetchMobvistaNativeAds
                         params:@{@"placementKey" : placementKey}
              shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_registerMobvistaAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view {
    [self performTarget:kZFNativeAdsMediatorTargetMobvista
                 action:kZFNativeAdsMediatorActionRegisterMobvistaAdInteraction
                 params:@{@"reformedAd" : reformedAd,
                          @"view" : view}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_setMobvistaDebugLogEnable:(BOOL)enable {
    [self performTarget:kZFNativeAdsMediatorTargetMobvista
                 action:kZFNativeAdsMediatorActionSetMobvistaDebugLogEnable
                 params:@{@"debugLogEnable" : @(enable)}
      shouldCacheTarget:NO];
}


@end
