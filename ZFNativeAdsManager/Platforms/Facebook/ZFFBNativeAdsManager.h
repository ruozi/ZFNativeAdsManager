//
//  ZFFBNativeAdsManager.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFNativeAdsDefine.h"
#import "ZFReformedNativeAd.h"

@interface ZFFBNativeAdsManager : NSObject

+ (instancetype)sharedInstance;

- (void)configureWithPlacementInfo:(NSDictionary *)placementInfo;

- (void)loadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption preload:(BOOL)preload;

- (ZFReformedNativeAd *)fetchNativeAd:(NSString *)placementKey;

- (void)registerAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view;

- (void)setDebugLogEnable:(BOOL)enable;

@property (nonatomic, weak) id<ZFNativeAdsDelegate> delegate;

@end
