//
//  FDWall.m
//  FlappyDot
//
//  Created by Grebenets, Maksym on 2/8/14.
//  Copyright (c) 2014 i4nApps. All rights reserved.
//

#import "FDWall.h"

@interface FDWall ()
// top and bottom parts of the wall
@property (nonatomic, strong) SKShapeNode *top;
@property (nonatomic, strong) SKShapeNode *bottom;
// top and bottom rects, (could get those from the shape node paths, but can keep separate for speed
@property (nonatomic, assign) CGRect topRect;
@property (nonatomic, assign) CGRect bottomRect;
@end

@implementation FDWall

+ (instancetype)wall {
    return [[FDWall alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.top = [[SKShapeNode alloc] init];
        self.bottom = [[SKShapeNode alloc] init];
        self.top.lineWidth = self.bottom.lineWidth = 1.0;
//        self.top.fillColor = self.bottom.fillColor = [SKColor greenColor];
        self.top.strokeColor = self.bottom.strokeColor = [SKColor yellowColor];
        self.top.glowWidth = self.bottom.glowWidth = 0.5;

        // the paths updated when the wall is updated
        [self addChild:self.top];
        [self addChild:self.bottom];

    }
    return self;
}

- (BOOL)isOffscreenLeft {
    return self.position.x + self.wallWidth <= 0.0f;
}

- (void)moveLeft:(float)dx {
    self.position = CGPointMake(self.position.x - dx, self.position.y);
}


- (void)updateShape {
    self.bottomRect = CGRectMake(0, 0, self.wallWidth, self.gapOffset);
    self.bottom.path = CGPathCreateWithRect(self.bottomRect, NULL);
    self.topRect = CGRectMake(0, self.gapOffset + self.gapHeight, self.wallWidth, self.wallHeight - self.gapOffset - self.gapHeight);
    self.top.path = CGPathCreateWithRect(self.topRect, NULL);
}

- (BOOL)testCollisionWithRect:(CGRect)rect {
    CGRect topRect = CGRectOffset(self.topRect, self.position.x, self.position.y);
    CGRect bottomRect = CGRectOffset(self.bottomRect, self.position.x, self.position.y);
    // also check if flying over the top
    return CGRectIntersectsRect(rect, topRect) || CGRectIntersectsRect(rect, bottomRect)
        || (rect.origin.y >= self.wallHeight && rect.origin.x + rect.size.width >= self.position.x && rect.origin.x <= self.position.x + self.wallWidth);
}

@end
