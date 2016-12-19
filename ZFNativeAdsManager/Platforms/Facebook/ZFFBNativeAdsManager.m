//
//  ZFFBNativeAdsManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFFBNativeAdsManager.h"
#import "ZFNativeAdsManager.h"
#import <objc/runtime.h>
#import <FBAudienceNetwork/FBNativeAd.h>

static const char FBReformAdKey;

@interface ZFFBNativeAdsManager () <FBNativeAdDelegate>

@property (nonatomic, strong) NSDictionary *placementInfo;

@property (nonatomic, strong) NSMutableDictionary *cachedAdDictionary;

@property (nonatomic, strong) NSMutableArray<FBNativeAd *> *nativeAdCacheArray;
@property (nonatomic, strong) NSMutableDictionary *preloadIndicator;
@property (nonatomic, strong) NSMutableDictionary *loadImageIndicator;

@property (nonatomic, assign) BOOL  debugLogEnable;

@end

@implementation ZFFBNativeAdsManager

#pragma mark - public methods
+ (instancetype)sharedInstance {
    static ZFFBNativeAdsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZFFBNativeAdsManager alloc] init];
    });
    return instance;
}

- (void)configureWithPlacementInfo:(NSDictionary *)placementInfo {
    self.placementInfo = placementInfo;
}

- (void)loadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption preload:(BOOL)preload {
    
    if (preload) {
        [self.preloadIndicator setObject:@(YES) forKey:placementKey];
        [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】start preloading ads with placement id:%@", placementKey]];
    }
    
    [self.loadImageIndicator setObject:@(loadImageOption) forKey:placementKey];
    
    if (self.placementInfo && [self.placementInfo objectForKey:placementKey]) {
        
        FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:[self.placementInfo objectForKey:placementKey]];
        nativeAd.delegate = self;
        nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyCoverImage;
        [nativeAd loadAd];

        [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】start loading ads with placement id:%@", placementKey]];
    } else {
        [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】missing configuration for placement:%@", placementKey]];
    }
}

- (ZFReformedNativeAd *)fetchNativeAd:(NSString *)placementKey {
    
    ZFReformedNativeAd *reformedAd = [self.cachedAdDictionary objectForKey:placementKey];
    [self.cachedAdDictionary removeObjectForKey:placementKey];
    
    ZFNativeAdsLoadImageOption loadImageOption = [[self.loadImageIndicator valueForKey:placementKey] unsignedIntegerValue];
    
    if ([[self.preloadIndicator objectForKey:placementKey] boolValue]) {
        [self loadNativeAds:placementKey loadImageOption:loadImageOption preload:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdStatusLoading:placement:)]) {
        [self.delegate nativeAdStatusLoading:ZFNativeAdsPlatformFacebook placement:placementKey];
    }
    
    return reformedAd;
}

- (void)registerAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view {
    
    FBNativeAd *ad = objc_getAssociatedObject(reformedAd, &FBReformAdKey);
    
    if (ad) {
        [ad unregisterView];
    }
    
    [ad registerViewForInteraction:view withViewController:nil];
    [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】native ad(%@) has registered view(%@)", ad, view]];
}

- (void)setDebugLogEnable:(BOOL)enable {
    _debugLogEnable = enable;
}

#pragma mark - <FBNativeAdDelegate>
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    
    [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】native ad did load:%@", nativeAd]];
    
    [self.nativeAdCacheArray addObject:nativeAd];
    
    if (![self.cachedAdDictionary objectForKey:nativeAd.placementID]) {
        
        ZFReformedNativeAd *reformedAd = [[ZFReformedNativeAd alloc] init];
        reformedAd.platform = ZFNativeAdsPlatformFacebook;
        reformedAd.title = nativeAd.title;
        reformedAd.subtitle = nativeAd.subtitle;
        reformedAd.callToAction = nativeAd.callToAction;
        reformedAd.detail = nativeAd.body;
        reformedAd.adId = [NSString stringWithFormat:@"%@_%@", @"FB", [self randomString:8]];
        reformedAd.iconURL = nativeAd.icon.url;
        reformedAd.coverImageURL = nativeAd.coverImage.url;
        
        objc_setAssociatedObject(reformedAd, &FBReformAdKey, nativeAd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NSString *placementKey = [self placementKeyForPlacementId:nativeAd.placementID];
        ZFNativeAdsLoadImageOption loadImageOption = [[self.loadImageIndicator valueForKey:placementKey] unsignedIntegerValue];
        
        if (loadImageOption == ZFNativeAdsLoadImageOptionNone) {
            
            [self.cachedAdDictionary setValue:reformedAd forKey:placementKey];
            [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】reformed ad did cache:%@ for placement:%@", reformedAd, placementKey]];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)] && placementKey) {
                [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformFacebook placement:placementKey];
            }
            
            return;
        }
        
        if (loadImageOption & ZFNativeAdsLoadImageOptionCover) {
            
            __weak typeof(self) weakSelf = self;
            [nativeAd.coverImage loadImageAsyncWithBlock:^(UIImage * _Nullable image) {
                __strong typeof(weakSelf) self = weakSelf;
                
                if (image) {
                    reformedAd.coverImage = image;
                    
                    if ((loadImageOption & ZFNativeAdsLoadImageOptionIcon) && !reformedAd.iconImage) {
                        return;
                    }
                    
                    [self.cachedAdDictionary setValue:reformedAd forKey:placementKey];
                    [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】reformed ad did cache:%@ for placement:%@", reformedAd, placementKey]];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)] && placementKey) {
                        [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformFacebook placement:placementKey];
                    }
                } else {
                    [self printDebugLog:@"【ZFFBNativeAdsManager】reformed ad load cover image error."];
                }
            }];
            
            return;
        }
        
        if (loadImageOption & ZFNativeAdsLoadImageOptionIcon) {
            
            __weak typeof(self) weakSelf = self;
            [nativeAd.icon loadImageAsyncWithBlock:^(UIImage * _Nullable image) {
                __strong typeof(weakSelf) self = weakSelf;
                
                if (image) {
                    
                    reformedAd.iconImage = image;
                    
                    if ((loadImageOption & ZFNativeAdsLoadImageOptionCover) && !reformedAd.coverImage) {
                        return;
                    }
                    
                    [self.cachedAdDictionary setValue:reformedAd forKey:placementKey];
                    [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】reformed ad did cache:%@ for placement:%@", reformedAd, placementKey]];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)] && placementKey) {
                        [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformFacebook placement:placementKey];
                    }
                    
                } else {
                    [self printDebugLog:@"【ZFNativeAdsLoadImageOptionIcon】reformed ad load icon image error"];
                }
            }];
        }
    }
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】native ad will log impression:%@", nativeAd]];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】native ad did fail with error:%@", error]];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】native ad did click:%@", nativeAd]];
    
    NSString *placementKey = [self placementKeyForPlacementId:nativeAd.placementID];
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidClick:placement:)] && placementKey) {
        [self.delegate nativeAdDidClick:ZFNativeAdsPlatformFacebook placement:placementKey];
    }
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFFBNativeAdsManager】native ad did finish handling click: %@", nativeAd]];
}

#pragma mark - private methods
- (NSString *)placementKeyForPlacementId:(NSString *)placementId {
    
    if (!self.placementInfo) {
        return nil;
    }
    
    for (NSString *key in self.placementInfo) {
        if ([[self.placementInfo objectForKey:key] isEqualToString:placementId]) {
            return key;
        }
    }
    
    return nil;
}

- (NSString *)randomString:(NSInteger)length {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++)
    {
        [randomString appendFormat:@"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

- (void)printDebugLog:(NSString *)debugLog {
    if (self.debugLogEnable) {
        NSLog(@"%@", debugLog);
    }
}

#pragma mark - getters
- (NSMutableDictionary *)cachedAdDictionary {
    if (!_cachedAdDictionary) {
        _cachedAdDictionary = [[NSMutableDictionary alloc] init];
    }
    return _cachedAdDictionary;
}

- (NSMutableArray<FBNativeAd *> *)nativeAdCacheArray {
    if (!_nativeAdCacheArray) {
        _nativeAdCacheArray = [NSMutableArray array];
    }
    return _nativeAdCacheArray;
}

- (NSMutableDictionary *)preloadIndicator {
    if (!_preloadIndicator) {
        _preloadIndicator = [NSMutableDictionary dictionary];
    }
    return _preloadIndicator;
}

- (NSMutableDictionary *)loadImageIndicator {
    if (!_loadImageIndicator) {
        _loadImageIndicator = [NSMutableDictionary dictionary];
    }
    return _loadImageIndicator;
}

@end
