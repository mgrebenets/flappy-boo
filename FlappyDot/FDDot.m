//
//  FDDot.m
//  FlappyDot
//
//  Created by Grebenets, Maksym on 2/7/14.
//  Copyright (c) 2014 i4nApps. All rights reserved.
//

#import "FDDot.h"


@interface FDDot ()
@property (nonatomic,strong) SKEmitterNode *explosion;
@end

@implementation FDDot

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {
         NSString *path = [[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"];
        self.explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

        [self.explosion setTargetNode:self];
    }
    return self;
}

- (void)applyDelta {
    self.position = CGPointMake(self.position.x, self.position.y + self.dy);
}

- (BOOL)didFallDown {
    return self.position.y - self.frame.size.height / 2 <= 0.0f;
}

- (void)explode:(void(^)(void))completion {
    if (![self.explosion parent]) [self addChild:self.explosion];

    [self.explosion resetSimulation];

    double delayInSeconds = self.explosion.particleLifetime;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.explosion removeFromParent];
        if (completion) completion();
    });
}
@end
