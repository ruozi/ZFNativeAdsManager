//
//  ZFNativeAdsManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFNativeAdsManager.h"
#import "ZFNativeAdsMediator+Facebook.h"
#import "ZFNativeAdsMediator+Mobvista.h"

@interface ZFNativeAdsManager () <ZFNativeAdsDelegate>

@property (nonatomic, strong) NSMutableArray<NSNumber *> *priorityIndicator;

@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *infoArray;
@property (nonatomic, strong) NSMutableDictionary *nativeAdsPool;

@property (nonatomic, strong) NSMutableDictionary *reformedAdFetchBlockDictionary;

@end

@implementation ZFNativeAdsManager

+ (instancetype)sharedInstance {
    static ZFNativeAdsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZFNativeAdsManager alloc] init];
    });
    return instance;
}

- (void)configureAppId:(NSString *)appId apiKey:(NSString *)apiKey platform:(ZFNativeAdsPlatform)platform {
    
    switch (platform) {
        case ZFNativeAdsPlatformFacebook: {
        }
            break;
            
        case ZFNativeAdsPlatformMobvista: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_configureMobvistaAppId:appId apiKey:apiKey];
        }
            break;
            
        default:
            NSLog(@"【ZFNativeAdsManager】should never reach here!");
            break;
    }
}

- (void)configurePlacementInfo:(NSDictionary *)placementInfo platform:(ZFNativeAdsPlatform)platform {
    
    NSMutableDictionary *platformInfo = [NSMutableDictionary dictionaryWithDictionary:placementInfo];
    [self.infoArray replaceObjectAtIndex:platform withObject:platformInfo];
    
    for (NSString *key in placementInfo) {
        if (![self.nativeAdsPool objectForKey:key]) {
            NSMutableOrderedSet *placementAdPool = [NSMutableOrderedSet orderedSetWithCapacity:ZFNativeAdsPlatformCount];
            [self.nativeAdsPool setObject:placementAdPool forKey:key];
        }
    }
    
    switch (platform) {
        case ZFNativeAdsPlatformFacebook: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setFacebookDelegate:self];
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_configureFacebookPlacementInfo:placementInfo];
        }
            break;
            
        case ZFNativeAdsPlatformMobvista: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setMobvistaDelegate:self];
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_configureMobvistaWithPlacementInfo:placementInfo];
        }
            break;
            
        default:
            NSLog(@"【ZFNativeAdsManager】should never reach here!");
            break;
    }
}

- (void)setPriority:(NSArray<NSNumber *> *)priorityArray {
    
    if (priorityArray.count > ZFNativeAdsPlatformCount) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [priorityArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.priorityIndicator replaceObjectAtIndex:obj.unsignedIntegerValue withObject:[NSNumber numberWithUnsignedInteger:idx]];
    }];
    
    NSLog(@"【ZFNativeAdsManager】 indicator:%@", self.priorityIndicator);
}

- (void)preloadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption {
    
    [self loadNativeAds:placementKey loadImageOption:loadImageOption preload:YES];
}

- (ZFReformedNativeAd *)fetchPreloadAdForPlacement:(NSString *)placementKey {
    
    NSMutableOrderedSet<NSNumber *> *placementAdPool = [self.nativeAdsPool objectForKey:placementKey];
    if (placementAdPool && placementAdPool.count > 0) {
        [placementAdPool sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [[self.priorityIndicator objectAtIndex:[obj1 unsignedIntegerValue]] compare:[self.priorityIndicator objectAtIndex:[obj2 unsignedIntegerValue]]];
        }];
        NSLog(@"【ZFNativeAdsManager】native ad sorted pool for this placement:%@", placementAdPool);
        
        NSNumber *platformIndex = [placementAdPool firstObject];
        ZFNativeAdsPlatform index = [platformIndex intValue];
        
        return [self fetchAdFromPlatform:index placement:placementKey];
    }

    return nil;
}

- (void)fetchAdForPlacement:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption fetchBlock:(ZFReformedAdFetchBlock)fetchblock {
    
    NSMutableOrderedSet<NSNumber *> *placementAdPool = [self.nativeAdsPool objectForKey:placementKey];
    if (placementAdPool && placementAdPool.count > 0) {
        [placementAdPool sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [[self.priorityIndicator objectAtIndex:[obj1 unsignedIntegerValue]] compare:[self.priorityIndicator objectAtIndex:[obj2 unsignedIntegerValue]]];
        }];
        NSLog(@"【ZFNativeAdsManager】native ad sorted pool for this placement:%@", placementAdPool);
        
        NSNumber *platformIndex = [placementAdPool firstObject];
        ZFNativeAdsPlatform index = [platformIndex intValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            fetchblock([self fetchAdFromPlatform:index placement:placementKey]);
        });
    } else {
        
        [self.reformedAdFetchBlockDictionary setObject:fetchblock forKey:placementKey];
        
        [self loadNativeAds:placementKey loadImageOption:loadImageOption preload:NO];
    }
    
}

- (void)registAdForInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view {
    
    switch (reformedAd.platform) {
        case ZFNativeAdsPlatformFacebook: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_registerFacebookAdInteraction:reformedAd view:view];
        }
            break;
            
        case ZFNativeAdsPlatformMobvista: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_registerMobvistaAdInteraction:reformedAd view:view];
        }
            break;
            
        default:
            NSLog(@"【ZFNativeAdsManager】should never reach here!");
            break;
    }
}

#pragma mark - <ZFNativeAdsDelegate>
- (void)nativeAdDidLoad:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey {
    
    NSLog(@"【ZFNativeAdsManager】native ad did load from platform:%ld, placement:%@", (long)platform, placementKey);
    
    NSMutableOrderedSet *placementAdsPool = [self.nativeAdsPool objectForKey:placementKey];
    NSUInteger beforeCount = placementAdsPool.count;
    
    [placementAdsPool addObject:@(platform)];
    [self.nativeAdsPool setObject:placementAdsPool forKey:placementKey];
    
    if (!beforeCount) {
        NSLog(@"【ZFNativeAdsManager】native ad did load for placement:%@", placementKey);
        ZFReformedAdFetchBlock fetchBlock = [self.reformedAdFetchBlockDictionary objectForKey:placementKey];
        if (fetchBlock) {
            
            ZFReformedNativeAd *reformedAd = [self fetchAdFromPlatform:platform placement:placementKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                fetchBlock(reformedAd);
            });
            
            [self.reformedAdFetchBlockDictionary removeObjectForKey:placementKey];
        }
    }
}

- (void)nativeAdStatusLoading:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey {
    
    NSLog(@"【ZFNativeAdsManager】native ad status loading for platform:%ld, placement:%@", (long)platform, placementKey);
    
    NSMutableOrderedSet *placementAdsPool = [self.nativeAdsPool objectForKey:placementKey];
    [placementAdsPool removeObject:@(platform)];
    [self.nativeAdsPool setObject:placementAdsPool forKey:placementKey];
}

- (void)nativeAdDidClick:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:placementKey];
    }
}

#pragma mark - Private methods
- (void)loadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption preload:(BOOL)preload {
    
    if ([[self.priorityIndicator objectAtIndex:ZFNativeAdsPlatformFacebook] unsignedIntegerValue] < ZFNativeAdsPlatformCount) {
        [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_loadFacebookNativeAds:placementKey loadImageOption:loadImageOption preload:preload];
    }
    
    if ([[self.priorityIndicator objectAtIndex:ZFNativeAdsPlatformMobvista] unsignedIntegerValue] < ZFNativeAdsPlatformCount) {
        [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_loadMobvistaNativeAds:placementKey loadImageOption:loadImageOption];
    }
}

- (ZFReformedNativeAd *)fetchAdFromPlatform:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey {
    
    NSLog(@"【ZFNativeAdsManager】fetch native ad from platform:%ld", (long)platform);
    
    switch (platform) {
        case ZFNativeAdsPlatformFacebook: {
            ZFReformedNativeAd *ad = [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_fetchFacebookNativeAd:placementKey];
            NSLog(@"【ZFNativeAdsManager】fetch reformed ad from Facebook:%@", ad);
            return ad;
        }
            break;
            
        case ZFNativeAdsPlatformMobvista: {
            ZFReformedNativeAd *ad = [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_fetchMobvistaNativeAd:placementKey];
            NSLog(@"【ZFNativeAdsManager】fetch reformed ad from Mobvista:%@", ad);
            return ad;
        }
            break;
            
        default: {
            NSLog(@"【ZFNativeAdsManager】should never reach here!");
            return nil;
        }
            break;
    }
}

- (void)setDebugLogEnable:(BOOL)enable {
    
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setFacebookDebugLogEnable:enable];
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setMobvistaDebugLogEnable:enable];
}

#pragma mark - Getters
- (NSMutableArray<NSNumber *> *)priorityIndicator {
    if (!_priorityIndicator) {
        _priorityIndicator = [NSMutableArray<NSNumber *> arrayWithCapacity:ZFNativeAdsPlatformCount];
        for (NSInteger i = 0; i < ZFNativeAdsPlatformCount; i++) {
            [_priorityIndicator addObject:@(ZFNativeAdsPlatformCount)];
        }
    }
    return _priorityIndicator;
}

- (NSMutableArray<NSMutableDictionary *> *)infoArray {
    if (!_infoArray) {
        _infoArray = [NSMutableArray<NSMutableDictionary *> arrayWithCapacity:ZFNativeAdsPlatformCount];
        for (int i = 0; i < ZFNativeAdsPlatformCount; i++) {
            
            NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionary];
            [_infoArray addObject:infoDictionary];
        }
    }
    return _infoArray;
}

- (NSMutableDictionary *)nativeAdsPool {
    if (!_nativeAdsPool) {
        _nativeAdsPool = [NSMutableDictionary dictionary];
    }
    return _nativeAdsPool;
}

- (NSMutableDictionary *)reformedAdFetchBlockDictionary {
    if (!_reformedAdFetchBlockDictionary) {
        _reformedAdFetchBlockDictionary = [NSMutableDictionary dictionary];
    }
    return _reformedAdFetchBlockDictionary;
}

@end
