//
//  FDMyScene.m
//  FlappyDot
//
//  Created by Grebenets, Maksym on 2/7/14.
//  Copyright (c) 2014 i4nApps. All rights reserved.
//

#import "FDMyScene.h"
#import "FDDot.h"
#import "FDWall.h"

enum {
    GameStatusReady = 0,
    GameStatusFlying,
    GameStatusFalling,
    GameStatusOver
};

#ifdef UI_USER_INTERFACE_IDIOM
#define kScale (2.0f)
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define kScale (1.0f)
#define IS_IPAD() (NO)
#endif


static float MaxDY = 4.0f * kScale;
static float MinDY = -4.0f * kScale;
static float DeltaDY = 0.2f * kScale;
static float MinDeltaDY = 3.0f * kScale;
static float JumpDY = 70.0f * kScale;

// walls offset (distance between walls)
static float MinWallOffset = 100.0f * kScale;
static float WallOffsetRange = 100.0f *kScale;
// wall movement speed
static float WallDX = 2.0f * kScale;
// wall width
static float WallWidth = 100.0f * kScale;
// start wall offset from the right edge of the screen
static float StartWallOffset = 100.0f;  // no need to scale this one
// gap in the wall to fly through
static float WallGapHeight = 130.0f * kScale;
// min gap offset from top or bottom
static float MinGapOffset = 40.0f * kScale;

// best score key
static NSString *BestScoreKey = @"BestScoreKey";


@interface FDMyScene ()

// disclaimer: I love properties, probably too much in this case

// flying dot
@property (nonatomic, strong) FDDot *dot;
// fly up target
@property (nonatomic, assign) float targetHeight;

// speed with which the obstacles move in (the bird flies, all is relative)
@property (nonatomic, assign) double speed;
// game status (ready, flying, falling, game over)
@property (nonatomic, assign) NSInteger status;

// walls
@property (nonatomic, strong) NSArray *walls;
// current wall idx
@property (nonatomic, assign) NSInteger firstWallIdx;
// index of next wall to pass
@property (nonatomic, assign) NSInteger nextWallIdx;

// score and high score
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger bestScore;

@end

@implementation FDMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */

        // seed the rands
        srand48(time(0));
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

        // the dot
        NSString *name = (IS_IPAD() ? @"boo64" : @"boo32");
        self.dot = [[FDDot alloc] initWithImageNamed:name];
        [self addChild:self.dot];

        // the walls (5 should be more than enough)
//        self.walls = @[[FDWall wall], [FDWall wall], [FDWall wall], [FDWall wall], [FDWall wall]];
        self.walls = @[[FDWall wall], [FDWall wall], [FDWall wall]];

        // add them all as children
        // when offscreen they're not drawn anyway
        for (FDWall *wall in self.walls) {
            wall.wallWidth = WallWidth;
            wall.wallHeight = self.frame.size.height;
            [self addChild:wall];
        }

        // score laber
        self.bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:BestScoreKey];
        self.scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"System"];
        self.scoreLabel.fontSize = 20;
        self.scoreLabel.position = CGPointMake(80, 0);
        [self addChild:self.scoreLabel];
        [self prepareGame];
    }
    return self;
}

- (void)updateScoreLabel {
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld | Best: %ld", (long)self.score, (long)self.bestScore];
}

- (float)randomWallGapOffset {
    return MinGapOffset + (self.frame.size.height - MinGapOffset * 2 - WallGapHeight) * drand48();
}

- (void)prepareGame {
    self.status = GameStatusReady;

    // dot
    self.dot.position = CGPointMake(CGRectGetMidX(self.frame) * 0.25f,
                                    CGRectGetMidY(self.frame));
    self.targetHeight = self.dot.position.y;

    // walls
    self.firstWallIdx = 0;
    self.nextWallIdx = 0;
    FDWall *prevWall = nil;
    for (FDWall *wall in self.walls) {
        // set the frame
        wall.offset = (prevWall ? [self randomOffset] : 0.0f);
        float prevOffset = (prevWall ? prevWall.position.x + WallWidth : self.frame.size.width + StartWallOffset);
        wall.position = CGPointMake(prevOffset + wall.offset, wall.position.y);
        wall.gapHeight = WallGapHeight;
        wall.gapOffset = [self randomWallGapOffset];
        [wall updateShape];

        prevWall = wall;
    }

    // score label
    self.score = 0;
    [self updateScoreLabel];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    // any touch pushes the dot, even multiple touches
    // there's no soft or hard touch, all touches push the dot up the same
    switch (self.status) {
        case GameStatusReady:
            self.status = GameStatusFlying;
        case GameStatusFlying:
            self.targetHeight = self.dot.position.y + JumpDY;
            self.dot.dy = MaxDY;
            break;
        case GameStatusFalling:
            // ignore touches
            break;
        case GameStatusOver:
            // TODO:
            break;
        default:
            break;
    }

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */

    switch (self.status) {
        case GameStatusReady:
            // waiting for tap to start
            break;
        case GameStatusFlying:
            [self updateFlight:currentTime];
            break;
        case GameStatusFalling:
            [self updateFall:currentTime];
            break;
        case GameStatusOver:
            // displaying game over, waiting for tap
            break;

        default:
            break;
    }

}

- (void)updateFlight:(CFTimeInterval)currentTime {

    // detect passing the walls and update score
    FDWall *nextWall = self.walls[self.nextWallIdx];
    if (self.dot.position.x >= nextWall.position.x + WallWidth / 2) {
        self.score = self.score + 1;
        self.nextWallIdx = (self.nextWallIdx + 1) % self.walls.count;
        [self updateScoreLabel];
    }

    // check if fell on the ground
    if ([self.dot didFallDown]) {
        [self fallDown];
        return;
    }

    // detect collisions
    // with walls
    for (FDWall *wall in self.walls) {
        if ([wall testCollisionWithRect:self.dot.frame]) {
            [self fallDown];
            return;
        }
    }

    // update delta
    if (self.dot.position.y <= self.targetHeight) {
        self.dot.dy = fmaxf(MaxDY * (self.targetHeight - self.dot.position.y) / JumpDY, MinDeltaDY);
    } else {
        self.targetHeight = 0;
        self.dot.dy = fminf(MinDY, self.dot.dy - DeltaDY);
    }

    // apply delta
    [self.dot applyDelta];

    // update walls
    [self updateWalls];

}

- (void)fallDown {
    self.status = GameStatusFalling;
    [self.dot explode:^{
        self.status = GameStatusOver;
        // update the best score
        if (self.score > self.bestScore) {
            self.bestScore = self.score;
            [[NSUserDefaults standardUserDefaults] setInteger:self.bestScore forKey:BestScoreKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self prepareGame];
    }];
}

- (void)updateFall:(CFTimeInterval)currentTime {

}

- (float)randomOffset {
    return MinWallOffset + WallOffsetRange * drand48();
}

- (void)updateWalls {

    FDWall *firstWall = self.walls[self.firstWallIdx];
    if ([firstWall isOffscreenLeft]) {
        // "move" the first wall to the end of the queue
        FDWall *lastWall = self.walls[(self.firstWallIdx + self.walls.count - 1) % self.walls.count];
        // with new random offset
        firstWall.offset = [self randomOffset];
        firstWall.position = CGPointMake(lastWall.position.x + WallWidth + firstWall.offset, firstWall.position.y);
        // and new offset of the wall gap
        firstWall.gapOffset = [self randomWallGapOffset];
        [firstWall updateShape];

        // shift the first wall idx
        self.firstWallIdx = (self.firstWallIdx + 1) % self.walls.count;
    }


    // move them all
    for (FDWall *wall in self.walls) {
        [wall moveLeft:WallDX];
    }
}

@end
