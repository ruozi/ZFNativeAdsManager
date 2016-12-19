//
//  ZFMobvistaNativeAdObserver.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/10/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFMobvistaNativeAdObserver.h"

@interface ZFMobvistaNativeAdObserver () 

@property (nonatomic, strong) NSString *placementKey;

@end

@implementation ZFMobvistaNativeAdObserver

#pragma mark - public methods
- (instancetype)initWithPlacement:(NSString *)placementKey {
    if (self = [super init]) {
        self.placementKey = placementKey;
    }
    return self;
}

#pragma mark - <MVNativeAdManagerDelegate>
- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds {
//    NSLog(@"【ZFMobvistaNativeAdObserver】Native ads loaded:%@ for placement:%@", nativeAds, self.placementKey);
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdsLoaded:placement:)]) {
        [self.delegate nativeAdsLoaded:nativeAds placement:self.placementKey];
    }
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error {
//    NSLog(@"【ZFMobvistaNativeAdObserver】Native ads load with error:%@ for placement:%@", error, self.placementKey);
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdsFailedToLoadWithError:placement:)]) {
        [self.delegate nativeAdsFailedToLoadWithError:error placement:self.placementKey];
    }
}

- (void)nativeAdDidClick:(nonnull MVCampaign *)nativeAd {
//    NSLog(@"【ZFMobvistaNativeAdObserver】Native ads did click:%@ for placement:%@", nativeAd, self.placementKey);
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidClick:placement:)]) {
        [self.delegate nativeAdDidClick:nativeAd placement:self.placementKey];
    }
}

- (void)nativeAdClickUrlWillStartToJump:(nonnull NSURL *)clickUrl {
//    NSLog(@"【ZFMobvistaNativeAdObserver】Native ads will start to jump:%@ for placement:%@", clickUrl, self.placementKey);
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdClickUrlWillStartToJump:placement:)]) {
        [self.delegate nativeAdClickUrlWillStartToJump:clickUrl placement:self.placementKey];
    }
}

- (void)nativeAdClickUrlDidJumpToUrl:(nonnull NSURL *)jumpUrl {
//    NSLog(@"【ZFMobvistaNativeAdObserver】Native ads did jump to url:%@ for placement:%@", jumpUrl, self.placementKey);
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdClickUrlDidJumpToUrl:placement:)]) {
        [self.delegate nativeAdClickUrlDidJumpToUrl:jumpUrl placement:self.placementKey];
    }
}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error {
//    NSLog(@"【ZFMobvistaNativeAdObserver】Native ads did end jump:%@ with error:%@ for placement:%@", finalUrl, error, self.placementKey);
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdClickUrlDidEndJump:error:placement:)]) {
        [self.delegate nativeAdClickUrlDidEndJump:finalUrl error:error placement:self.placementKey];
    }
}


@end
