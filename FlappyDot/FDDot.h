//
//  FDDot.h
//  FlappyDot
//
//  Created by Grebenets, Maksym on 2/7/14.
//  Copyright (c) 2014 i4nApps. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FDDot : SKSpriteNode

// y coord delta (>0 - go up, <0 - go down)
@property (nonatomic, assign) float dy;

- (void)applyDelta;
- (BOOL)didFallDown;
- (void)explode:(void(^)(void))completion;
@end
