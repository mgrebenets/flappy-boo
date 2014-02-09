//
//  FDWall.h
//  FlappyDot
//
//  Created by Grebenets, Maksym on 2/8/14.
//  Copyright (c) 2014 i4nApps. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FDWall : SKNode

+ (instancetype)wall;

// offset from prev wall, 0 if first
@property (nonatomic, assign) float offset;
// offset of the wall gap from the bottom
@property (nonatomic, assign) float gapOffset;
// the height of the gap
@property (nonatomic, assign) float gapHeight;
// the width of the wall (sknode by itself has null-frame)
@property (nonatomic, assign) float wallWidth;
@property (nonatomic, assign) float wallHeight;

// check if moved too far to the left
- (BOOL)isOffscreenLeft;
// move to the left
- (void)moveLeft:(float)dx;
// update shape
- (void)updateShape;
// check collision
- (BOOL)testCollisionWithPoint:(CGPoint)point;
- (BOOL)testCollisionWithRect:(CGRect)rect;

@end
