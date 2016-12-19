//
//  ZFMobvistaNativeAdObserver.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/10/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MVSDK/MVSDK.h>

@protocol ZFMobvistaNativeAdObserverDelegate <NSObject>

@optional
- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds placement:(nonnull NSString *)placementKey;

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error placement:(nonnull NSString *)placementKey;

- (void)nativeAdDidClick:(nonnull MVCampaign *)nativeAd placement:(nonnull NSString *)placementKey;

- (void)nativeAdClickUrlWillStartToJump:(nonnull NSURL *)clickUrl placement:(nonnull NSString *)placementKey;

- (void)nativeAdClickUrlDidJumpToUrl:(nonnull NSURL *)jumpUrl placement:(nonnull NSString *)placementKey;

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl error:(nullable NSError *)error placement:(nonnull NSString *)placementKey;

@end

@interface ZFMobvistaNativeAdObserver : NSObject <MVNativeAdManagerDelegate>

NS_ASSUME_NONNULL_BEGIN
- (instancetype)initWithPlacement:(NSString *)placementKey;

@property (nonatomic, weak) id<ZFMobvistaNativeAdObserverDelegate> delegate;
NS_ASSUME_NONNULL_END

@end
