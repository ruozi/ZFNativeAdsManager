//
//  ZFViewController.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFViewController.h"
#import <Masonry/Masonry.h>
#import "ZFNativeAdsManager.h"

@interface ZFViewController () <ZFNativeAdsManagerDelegate>

@property (nonatomic, strong) UIView *preloadAdView;
@property (nonatomic, strong) UIImageView *preloadImageView;
@property (nonatomic, strong) UILabel *preloadLabel;

@property (nonatomic, strong) UIView *loadAdView;
@property (nonatomic, strong) UIImageView *loadImageView;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UILabel *loadLabel;

@end

@implementation ZFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configureViews];
    
    [self configureAdsInfo];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureViews {
    
    [self.view addSubview:self.preloadAdView];
    [self.preloadAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).multipliedBy(0.4);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(self.preloadAdView.mas_width).multipliedBy(0.6);
    }];
    
    [self.preloadAdView addSubview:self.preloadImageView];
    [self.preloadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.preloadAdView);
    }];
    
    [self.view addSubview:self.preloadLabel];
    [self.preloadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.preloadAdView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.loadAdView];
    [self.loadAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).multipliedBy(0.8);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(self.loadAdView.mas_width).multipliedBy(0.6);
    }];
    
    [self.loadAdView addSubview:self.loadImageView];
    [self.loadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.loadAdView);
    }];
    
    [self.view addSubview:self.loadLabel];
    [self.loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadAdView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.loadButton];
    [self.loadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).multipliedBy(0.95);
        make.width.equalTo(self.view).multipliedBy(0.7);
        make.height.mas_equalTo(40);
    }];
}

- (void)configureAdsInfo {
    
    [ZFNativeAdsManager sharedInstance].delegate = self;
    [[ZFNativeAdsManager sharedInstance] setDebugLogEnable:YES];
    [[ZFNativeAdsManager sharedInstance] configureAppId:@"25784" apiKey:@"7e03a2daee806fefa292d1447ea50155" platform:ZFNativeAdsPlatformMobvista];
    [[ZFNativeAdsManager sharedInstance] configurePlacementInfo:@{@"preload" : @"1169668629790481_1169669976457013",
                                                                  @"syncload" : @"962085583908347_962089450574627"}
                                                       platform:ZFNativeAdsPlatformFacebook];
    [[ZFNativeAdsManager sharedInstance] configurePlacementInfo:@{@"preload" : @"1497",
                                                                  @"syncload" : @"1497"}
                                                       platform:ZFNativeAdsPlatformMobvista];
    [[ZFNativeAdsManager sharedInstance] setPriority:@[@(ZFNativeAdsPlatformFacebook),
                                                       @(ZFNativeAdsPlatformMobvista)]];
    
//    [[ZFNativeAdsManager sharedInstance] setPriority:@[@(ZFNativeAdsPlatformMobvista)]];
    
//    [[ZFNativeAdsManager sharedInstance] setPriority:@[@(ZFNativeAdsPlatformFacebook)]];
    
    [[ZFNativeAdsManager sharedInstance] preloadNativeAds:@"preload" loadImageOption:ZFNativeAdsLoadImageOptionCover];
    
}

#pragma mark - <ZFNativeAdsManagerDelegate>

- (void)nativeAdDidClick:(NSString *)placementKey {
    
    NSLog(@"Placement:%@ did click!", placementKey);
    
    __weak typeof(self) weakSelf = self;
    [[ZFNativeAdsManager sharedInstance] fetchAdForPlacement:placementKey loadImageOption:ZFNativeAdsLoadImageOptionCover fetchBlock:^(ZFReformedNativeAd *reformedAd) {
        __strong typeof(weakSelf) self = weakSelf;
        [self renderAd:reformedAd placement:placementKey];
    }];
}

#pragma mark - action methods
- (void)onLoadAds {
    [self.loadButton setEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [[ZFNativeAdsManager sharedInstance] fetchAdForPlacement:@"preload" loadImageOption:ZFNativeAdsLoadImageOptionCover fetchBlock:^(ZFReformedNativeAd *reformedAd) {
        __strong typeof(weakSelf) self = weakSelf;
        [self renderAd:reformedAd placement:@"preload"];
    }];
    
    [[ZFNativeAdsManager sharedInstance] fetchAdForPlacement:@"syncload" loadImageOption:ZFNativeAdsLoadImageOptionCover fetchBlock:^(ZFReformedNativeAd *reformedAd) {
        __strong typeof(weakSelf) self = weakSelf;
        [self renderAd:reformedAd placement:@"syncload"];
    }];
}

#pragma mark - Private methods
- (void)renderAd:(ZFReformedNativeAd *)reformedAd placement:(NSString *)placementKey {
    
    if ([placementKey isEqualToString:@"preload"]) {
        self.preloadImageView.image = reformedAd.coverImage;
        [[ZFNativeAdsManager sharedInstance] registAdForInteraction:reformedAd view:self.preloadAdView];
    } else if ([placementKey isEqualToString:@"syncload"]) {
        self.loadImageView.image = reformedAd.coverImage;
        [[ZFNativeAdsManager sharedInstance] registAdForInteraction:reformedAd view:self.loadAdView];
    }
}

#pragma mark - Getters
- (UIView *)preloadAdView {
    if (!_preloadAdView) {
        _preloadAdView = [[UIView alloc] init];
        _preloadAdView.backgroundColor = [UIColor grayColor];
        _preloadAdView.clipsToBounds = YES;
    }
    return _preloadAdView;
}

- (UIImageView *)preloadImageView {
    if (!_preloadImageView) {
        _preloadImageView = [[UIImageView alloc] init];
        _preloadImageView.backgroundColor = [UIColor clearColor];
        _preloadImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _preloadImageView;
}

- (UILabel *)preloadLabel {
    if (!_preloadLabel) {
        _preloadLabel = [[UILabel alloc] init];
        _preloadLabel.text = @"Preload";
        _preloadLabel.textColor = [UIColor whiteColor];
        _preloadLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _preloadLabel;
}

- (UIView *)loadAdView {
    if (!_loadAdView) {
        _loadAdView = [[UIView alloc] init];
        _loadAdView.backgroundColor = [UIColor lightGrayColor];
        _loadAdView.clipsToBounds = YES;
    }
    return _loadAdView;
}

- (UIImageView *)loadImageView {
    if (!_loadImageView) {
        _loadImageView = [[UIImageView alloc] init];
        _loadImageView.backgroundColor = [UIColor clearColor];
        _loadImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _loadImageView;
}

- (UILabel *)loadLabel {
    if (!_loadLabel) {
        _loadLabel = [[UILabel alloc] init];
        _loadLabel.text = @"Load";
        _loadLabel.textAlignment = NSTextAlignmentCenter;
        _loadLabel.textColor = [UIColor whiteColor];
    }
    return _loadLabel;
}

- (UIButton *)loadButton {
    if (!_loadButton) {
        _loadButton = [[UIButton alloc] init];
        [_loadButton setTitle:@"Start Load" forState:UIControlStateNormal];
        [_loadButton setTitle:@"Loading" forState:UIControlStateDisabled];
        [_loadButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_loadButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        _loadButton.backgroundColor = [UIColor lightGrayColor];
        [_loadButton addTarget:self action:@selector(onLoadAds) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loadButton;
}


@end
