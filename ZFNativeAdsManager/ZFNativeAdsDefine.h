//
//  ZFNativeAdsDefine.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#ifndef ZFNativeAdsDefine_h
#define ZFNativeAdsDefine_h

typedef NS_ENUM(NSInteger, ZFNativeAdsPlatform) {
    ZFNativeAdsPlatformFacebook = 0,
    ZFNativeAdsPlatformMobvista,
    ZFNativeAdsPlatformCount
};

typedef NS_ENUM(NSUInteger, ZFNativeAdsLoadImageOption) {
    ZFNativeAdsLoadImageOptionNone = 0,
    ZFNativeAdsLoadImageOptionIcon = 1 << 0,
    ZFNativeAdsLoadImageOptionCover = 1 << 1,
};

@protocol ZFNativeAdsDelegate <NSObject>

- (void)nativeAdDidLoad:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey;

- (void)nativeAdStatusLoading:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey;

- (void)nativeAdDidClick:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey;

@end

#endif /* ZFNativeAdsDefine_h */
