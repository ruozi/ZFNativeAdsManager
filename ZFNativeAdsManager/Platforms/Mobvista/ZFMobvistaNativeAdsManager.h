//
//  ZFMobvistaNativeAdsManager.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFReformedNativeAd.h"
#import "ZFNativeAdsDefine.h"

@interface ZFMobvistaNativeAdsManager : NSObject

+ (instancetype)sharedInstance;

- (void)configureAppId:(NSString *)appId apiKey:(NSString *)apiKey;
- (void)configurePlacementInfo:(NSDictionary *)placementInfo;

- (void)loadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption;

- (ZFReformedNativeAd *)fetchNativeAd:(NSString *)placementKey;

- (void)registerAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view;

- (void)setDebugLogEnable:(BOOL)enable;

@property (nonatomic, weak) id<ZFNativeAdsDelegate> delegate;


@end
