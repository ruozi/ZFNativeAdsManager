//
//  ZFReformedNativeAd.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFNativeAdsDefine.h"

@interface ZFReformedNativeAd : NSObject

@property (nonatomic, assign) ZFNativeAdsPlatform platform;

@property (nonatomic, strong) NSString          *title;
@property (nonatomic, strong) NSString          *subtitle;
@property (nonatomic, strong) NSString          *callToAction;
@property (nonatomic, strong) NSString          *detail;
@property (nonatomic, strong) NSString          *adId;

@property (nonatomic, strong) UIImage           *coverImage;
@property (nonatomic, strong) NSURL             *coverImageURL;

@property (nonatomic, strong) UIImage           *iconImage;
@property (nonatomic, strong) NSURL             *iconURL;

@end
