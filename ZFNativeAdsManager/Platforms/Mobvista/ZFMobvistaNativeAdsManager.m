//
//  ZFMobvistaNativeAdsManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFMobvistaNativeAdsManager.h"
#import <MVSDK/MVSDK.h>
#import <objc/runtime.h>
#import "ZFMobvistaNativeAdObserver.h"

#define MV_NATIVE_ADS_REQUEST_ONCE_COUNT        10
#define MV_NATIVE_ADS_POOL_REFILL_THRESHOLD     5

static const char MVReformAdKey;
static const char MVAdPlacementKey;

@interface ZFMobvistaNativeAdsManager () <ZFMobvistaNativeAdObserverDelegate>

@property (nonatomic, strong) NSDictionary *placementInfo;

@property (nonatomic, strong) NSMutableDictionary *placementAdsManager;

@property (nonatomic, strong) NSMutableDictionary *loadImageIndicator;

@property (nonatomic, strong) NSMutableDictionary *reformedAdsCachePool;

@property (nonatomic, strong) NSMutableArray<ZFMobvistaNativeAdObserver *> *observerRetainArray;
@property (nonatomic, strong) NSMutableArray<MVCampaign *> *campaignRetainArray;

@property (nonatomic, assign) BOOL debugLogEnable;

@end

@implementation ZFMobvistaNativeAdsManager

+ (instancetype)sharedInstance {
    static ZFMobvistaNativeAdsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZFMobvistaNativeAdsManager alloc] init];
    });
    return instance;
}

#pragma mark - public methods
- (void)configureAppId:(NSString *)appId apiKey:(NSString *)apiKey {
    [[MVSDK sharedInstance] setAppID:appId ApiKey:apiKey];
}

- (void)configurePlacementInfo:(NSDictionary *)placementInfo {
    self.placementInfo = placementInfo;
    
    for (NSString *key in placementInfo) {
        
        NSMutableSet<ZFReformedNativeAd *> *reformedAdsPlacementCachePool = [NSMutableSet<ZFReformedNativeAd *> set];
        [self.reformedAdsCachePool setObject:reformedAdsPlacementCachePool forKey:key];
        
        MVTemplate *template = [MVTemplate templateWithType:MVAD_TEMPLATE_BIG_IMAGE adsNum:MV_NATIVE_ADS_REQUEST_ONCE_COUNT];
        
        [[MVSDK sharedInstance] preloadNativeAdsWithUnitId:[self.placementInfo objectForKey:key]
                                             fbPlacementId:nil
                                        supportedTemplates:@[template]
                                            autoCacheImage:YES
                                                adCategory:MVAD_CATEGORY_ALL];
        
        MVNativeAdManager *manager = [[MVNativeAdManager alloc] initWithUnitID:[self.placementInfo objectForKey:key]
                                        fbPlacementId:nil
                                   supportedTemplates:@[template]
                                       autoCacheImage:YES
                                           adCategory:MVAD_CATEGORY_ALL
                             presentingViewController:nil];
        
        ZFMobvistaNativeAdObserver *observer = [[ZFMobvistaNativeAdObserver alloc] initWithPlacement:key];
        [self.observerRetainArray addObject:observer];
        
        manager.delegate = observer;
        observer.delegate = self;
        
        [self.placementAdsManager setObject:manager forKey:key];
    }
}

- (void)loadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption {
    
    [self.loadImageIndicator setObject:@(loadImageOption) forKey:placementKey];
    
    if (self.placementInfo && [self.placementInfo objectForKey:placementKey]) {
        [self loadAdsForPlacement:placementKey];
        [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】Start loading ads for placement:%@", placementKey]];
    } else {
        [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】Missing configuration for placement:%@", placementKey]];
    }
}

- (ZFReformedNativeAd *)fetchNativeAd:(NSString *)placementKey {
    
    NSMutableSet<ZFReformedNativeAd *> *reformedAdsPool = [self.reformedAdsCachePool objectForKey:placementKey];
    ZFReformedNativeAd *reformedAd = [reformedAdsPool anyObject];
    
    if (reformedAd) {
        [reformedAdsPool removeObject:reformedAd];
        [self.reformedAdsCachePool setObject:reformedAdsPool forKey:placementKey];
    }
        
    if (reformedAdsPool.count < MV_NATIVE_ADS_POOL_REFILL_THRESHOLD) {
        [self loadAdsForPlacement:placementKey];
    }
    
    if (reformedAdsPool.count == 0 && self.delegate && [self.delegate respondsToSelector:@selector(nativeAdStatusLoading:placement:)]) {
        [self.delegate nativeAdStatusLoading:ZFNativeAdsPlatformMobvista placement:placementKey];
    }
    
    return reformedAd;
}

- (void)registerAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view {
    
    MVCampaign *campaign = objc_getAssociatedObject(reformedAd, &MVReformAdKey);
    NSString *placementKey = objc_getAssociatedObject(reformedAd, &MVAdPlacementKey);
    
    MVNativeAdManager *manager = [self.placementAdsManager objectForKey:placementKey];
    [manager registerViewForInteraction:view withCampaign:campaign];
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】register view %@ with campaign:%@", view, campaign]];
}

#pragma mark - <ZFMobvistaNativeAdObserverDelegate>
- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds placement:(nonnull NSString *)placementKey {
    
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ads loaded:%@ for placement:%@", nativeAds, placementKey]];
    
    ZFNativeAdsLoadImageOption loadImageOption = [[self.loadImageIndicator valueForKey:placementKey] unsignedIntegerValue];
    
    for (MVCampaign *campaign in nativeAds) {
        
        [self.campaignRetainArray addObject:campaign];
        
        ZFReformedNativeAd *reformedAd = [[ZFReformedNativeAd alloc] init];
        
        reformedAd.platform = ZFNativeAdsPlatformMobvista;
        reformedAd.title = campaign.appName;
        reformedAd.subtitle = campaign.packageName;
        reformedAd.callToAction = campaign.adCall;
        reformedAd.detail = campaign.appDesc;
        reformedAd.adId = campaign.adId;
        
        reformedAd.iconURL = [NSURL URLWithString:campaign.iconUrl];
        reformedAd.coverImageURL = [NSURL URLWithString:campaign.imageUrl];
        
        objc_setAssociatedObject(reformedAd, &MVReformAdKey, campaign, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(reformedAd, &MVAdPlacementKey, placementKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (loadImageOption == ZFNativeAdsLoadImageOptionNone) {
            
            [[self.reformedAdsCachePool objectForKey:placementKey] addObject:reformedAd];
            [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】reformed ad did cache:%@", reformedAd]];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)]) {
                [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformMobvista placement:placementKey];
            }
            
            return;
        }
        
        if (loadImageOption == ZFNativeAdsLoadImageOptionCover) {
            
            __weak typeof(self) weakSelf = self;
            [campaign loadImageUrlAsyncWithBlock:^(UIImage *image) {
                __strong typeof(weakSelf) self = weakSelf;
                
                if (image) {
                    reformedAd.coverImage = image;
                    
                    if ((loadImageOption & ZFNativeAdsLoadImageOptionIcon) && !reformedAd.iconImage) {
                        return;
                    }
                    
                    [[self.reformedAdsCachePool objectForKey:placementKey] addObject:reformedAd];
                    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】reformed ad did cache:%@", reformedAd]];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)]) {
                        [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformMobvista placement:placementKey];
                    }
                } else {
                    [self printDebugLog:@"【ZFMobvistaNativeAdsManager】reformed ad image cover load error!"];
                }
            }];
            
            return;
        }
        
        if (loadImageOption == ZFNativeAdsLoadImageOptionIcon) {
            
            __weak typeof(self) weakSelf = self;
            [campaign loadIconUrlAsyncWithBlock:^(UIImage *image) {
                __strong typeof(weakSelf) self = weakSelf;
                
                if (image) {
                    reformedAd.coverImage = image;
                    
                    if ((loadImageOption & ZFNativeAdsLoadImageOptionCover) && !reformedAd.coverImage) {
                        return;
                    }
                    
                    [[self.reformedAdsCachePool objectForKey:placementKey] addObject:reformedAd];
                    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】reformed ad did cache:%@", reformedAd]];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)]) {
                        [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformMobvista placement:placementKey];
                    }
                } else {
                    [self printDebugLog:@"【ZFMobvistaNativeAdsManager】reformed ad icon cover load error!"];
                }
            }];
        }
        
    }
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error placement:(nonnull NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ads load failed:%@ for placement:%@", error, placementKey]];
}

- (void)nativeAdDidClick:(nonnull MVCampaign *)nativeAd placement:(NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ad did click:%@ for placement:%@", nativeAd, placementKey]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidClick:placement:)]) {
        [self.delegate nativeAdDidClick:ZFNativeAdsPlatformMobvista placement:placementKey];
    }
}

- (void)nativeAdClickUrlWillStartToJump:(nonnull NSURL *)clickUrl placement:(nonnull NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ad click url will start to jump:%@ for placement:%@", clickUrl, placementKey]];
}

- (void)nativeAdClickUrlDidJumpToUrl:(nonnull NSURL *)jumpUrl placement:(nonnull NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ads click url did jump to url:%@ for placement:%@", jumpUrl, placementKey]];
}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error
                         placement:(nonnull NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ads did end jump to final url:%@ error:%@ for placement:%@", finalUrl, error, placementKey]];
}

#pragma mark - private methods
- (void)loadAdsForPlacement:(NSString *)placementKey {
    MVNativeAdManager *manager = [self.placementAdsManager objectForKey:placementKey];
    [manager loadAds];
}

- (void)printDebugLog:(NSString *)debugLog {
    if (self.debugLogEnable) {
        NSLog(@"%@", debugLog);
    }
}

#pragma mark - getters
- (NSMutableDictionary *)placementAdsManager {
    if (!_placementAdsManager) {
        _placementAdsManager = [NSMutableDictionary dictionary];
    }
    return _placementAdsManager;
}


- (NSMutableDictionary *)loadImageIndicator {
    if (!_loadImageIndicator) {
        _loadImageIndicator = [NSMutableDictionary dictionary];
    }
    return _loadImageIndicator;
}

- (NSMutableDictionary *)reformedAdsCachePool {
    if (!_reformedAdsCachePool) {
        _reformedAdsCachePool = [NSMutableDictionary dictionary];
    }
    return _reformedAdsCachePool;
}

- (NSMutableArray<ZFMobvistaNativeAdObserver *> *)observerRetainArray {
    if (!_observerRetainArray) {
        _observerRetainArray = [NSMutableArray<ZFMobvistaNativeAdObserver *> array];
    }
    return _observerRetainArray;
}

- (NSMutableArray<MVCampaign *> *)campaignRetainArray {
    if (!_campaignRetainArray) {
        _campaignRetainArray = [NSMutableArray<MVCampaign *> array];
    }
    return _campaignRetainArray;
}


@end
