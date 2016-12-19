//
//  Target_Mobvista.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/17/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "Target_Mobvista.h"
#import "ZFMobvistaNativeAdsManager.h"

@implementation Target_Mobvista

- (void)Action_setDelegate:(NSDictionary *)params {
    id<ZFNativeAdsDelegate> delegate = [params objectForKey:@"delegate"];
    [ZFMobvistaNativeAdsManager sharedInstance].delegate = delegate;
}

- (void)Action_configureAppInfo:(NSDictionary *)params {
    NSString *appId = [params objectForKey:@"appId"];
    NSString *apiKey = [params objectForKey:@"apiKey"];
    [[ZFMobvistaNativeAdsManager sharedInstance] configureAppId:appId apiKey:apiKey];
}

- (void)Action_configurePlacementInfo:(NSDictionary *)params {
    NSDictionary *placementInfo = [params objectForKey:@"placementInfo"];
    [[ZFMobvistaNativeAdsManager sharedInstance] configurePlacementInfo:placementInfo];
}

- (void)Action_loadNativeAds:(NSDictionary *)params {
    NSString *placementKey = [params objectForKey:@"placementKey"];
    ZFNativeAdsLoadImageOption loadImageOption = [[params objectForKey:@"loadImageOption"] unsignedIntegerValue];
    [[ZFMobvistaNativeAdsManager sharedInstance] loadNativeAds:placementKey loadImageOption:loadImageOption];
}

- (id)Action_fetchNativeAd:(NSDictionary *)params {
    NSString *placementKey = [params objectForKey:@"placementKey"];
    return [[ZFMobvistaNativeAdsManager sharedInstance] fetchNativeAd:placementKey];
}

- (void)Action_registerAdInteraction:(NSDictionary *)params {
    ZFReformedNativeAd *reformedAd = [params objectForKey:@"reformedAd"];
    UIView *view = [params objectForKey:@"view"];
    [[ZFMobvistaNativeAdsManager sharedInstance] registerAdInteraction:reformedAd view:view];
}

- (void)Action_setDebugLogEnable:(NSDictionary *)params {
    BOOL debugLogEnable = [[params objectForKey:@"debugLogEnable"] boolValue];
    [[ZFMobvistaNativeAdsManager sharedInstance] setDebugLogEnable:debugLogEnable];
}

@end
