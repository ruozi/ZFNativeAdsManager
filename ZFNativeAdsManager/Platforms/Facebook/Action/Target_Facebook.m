//
//  Target_Facebook.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/17/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "Target_Facebook.h"
#import "ZFFBNativeAdsManager.h"

@implementation Target_Facebook

- (void)Action_setDelegate:(NSDictionary *)params {
    id<ZFNativeAdsDelegate> delegate = [params objectForKey:@"delegate"];
    [ZFFBNativeAdsManager sharedInstance].delegate = delegate;
}

- (void)Action_configurePlacementInfo:(NSDictionary *)params {
    NSDictionary *placementInfo = [params objectForKey:@"placementInfo"];
    [[ZFFBNativeAdsManager sharedInstance] configureWithPlacementInfo:placementInfo];
}

- (void)Action_loadNativeAds:(NSDictionary *)params {
    NSString *placementKey = [params objectForKey:@"placementKey"];
    ZFNativeAdsLoadImageOption loadImageOption = [[params objectForKey:@"loadImageOption"] unsignedIntegerValue];
    BOOL preload = [[params objectForKey:@"preload"] boolValue];
    [[ZFFBNativeAdsManager sharedInstance] loadNativeAds:placementKey loadImageOption:loadImageOption preload:preload];
}

- (id)Action_fetchNativeAd:(NSDictionary *)params {
    NSString *placementKey = [params objectForKey:@"placementKey"];
    ZFReformedNativeAd *reformedAd = [[ZFFBNativeAdsManager sharedInstance] fetchNativeAd:placementKey];
    return reformedAd;
}

- (void)Action_registerAdInteraction:(NSDictionary *)params {
    ZFReformedNativeAd *reformedAd = [params objectForKey:@"reformedAd"];
    UIView *view = [params objectForKey:@"view"];
    [[ZFFBNativeAdsManager sharedInstance] registerAdInteraction:reformedAd view:view];
}

- (void)Action_setDebugLogEnable:(NSDictionary *)params {
    BOOL debugLogEnable = [[params objectForKey:@"debugLogEnable"] boolValue];
    [[ZFFBNativeAdsManager sharedInstance] setDebugLogEnable:debugLogEnable];
}

@end
