//
//  ZFNativeAdsMediator+Facebook.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/16/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFNativeAdsMediator.h"
#import "ZFNativeAdsDefine.h"
#import "ZFReformedNativeAd.h"

@interface ZFNativeAdsMediator (Facebook)

- (void)ZFNativeAdsMediator_setFacebookDelegate:(id<ZFNativeAdsDelegate>)delegate;

- (void)ZFNativeAdsMediator_configureFacebookPlacementInfo:(NSDictionary *)placementInfo;

- (void)ZFNativeAdsMediator_loadFacebookNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption preload:(BOOL)preload;

- (ZFReformedNativeAd *)ZFNativeAdsMediator_fetchFacebookNativeAd:(NSString *)placementKey;

- (void)ZFNativeAdsMediator_registerFacebookAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view;

- (void)ZFNativeAdsMediator_setFacebookDebugLogEnable:(BOOL)enable;

@end
