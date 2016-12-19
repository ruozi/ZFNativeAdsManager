//
//  ZFNativeAdsMediator+Mobvista.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/16/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFNativeAdsMediator.h"
#import "ZFNativeAdsDefine.h"
#import "ZFReformedNativeAd.h"

@interface ZFNativeAdsMediator (Mobvista)

- (void)ZFNativeAdsMediator_setMobvistaDelegate:(id<ZFNativeAdsDelegate>)delegate;

- (void)ZFNativeAdsMediator_configureMobvistaAppId:(NSString *)appId apiKey:(NSString *)apiKey;

- (void)ZFNativeAdsMediator_configureMobvistaWithPlacementInfo:(NSDictionary *)placementInfo;

- (void)ZFNativeAdsMediator_loadMobvistaNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption;

- (ZFReformedNativeAd *)ZFNativeAdsMediator_fetchMobvistaNativeAd:(NSString *)placementKey;

- (void)ZFNativeAdsMediator_registerMobvistaAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view;

- (void)ZFNativeAdsMediator_setMobvistaDebugLogEnable:(BOOL)enable;

@end
