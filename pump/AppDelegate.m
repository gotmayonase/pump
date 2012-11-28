//
//  AppDelegate.m
//  pump
//
//  Created by Mike Mayo on 11/26/12.
//  Copyright (c) 2012 Mike Mayo. All rights reserved.
//

#import "AppDelegate.h"
#import "Game.h"
#import "Stream.h"
#import <RestKit/RestKit.h>
#import <RestKit/RKJSONParserJSONKit.h>

@implementation AppDelegate

@synthesize games, streams;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [RKObjectManager managerWithBaseURLString:@"https://api.twitch.tv/kraken"];
  [[RKParserRegistry sharedRegistry] setParserClass:[RKJSONParserJSONKit class] forMIMEType:@"application/vnd.twitch.api-v1+json"];
  [RKObjectManager sharedManager].acceptMIMEType = @"application/vnd.twitch.api-v1+json";
  RKObjectMapping *gameMapping = [RKObjectMapping mappingForClass:[Game class]];
  [gameMapping mapKeyPath:@"game.name" toAttribute:@"name"];
  [gameMapping mapKeyPath:@"game.box.medium" toAttribute:@"imageURL"];
  
  [[RKObjectManager sharedManager].mappingProvider setMapping:gameMapping forKeyPath:@"top"];
  
  [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/games/top" usingBlock:^(RKObjectLoader *loader) {
    [loader setOnDidLoadObjects:^(NSArray *retGames){
      [self setGames:[retGames mutableCopy]];
    }];
    [loader setOnDidFailWithError:^(NSError *error) {
//      NSLog(@"url: %@", loader.response.request.URL);
//      NSLog(@"response: %@", [loader.response bodyAsString]);
      NSLog(@"error: %@", [error localizedDescription]);
    }];
  }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (object == self.sideBarController && [keyPath isEqualToString:@"selectionIndexes"]) {
    NSIndexSet *indexSet = [object valueForKeyPath:keyPath];
    Game *game = [games objectAtIndex:[indexSet firstIndex]];
    [self fetchStreamsForGame:game];
  }
}

- (void)awakeFromNib {
  [self.sideBarController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)insertObject:(Game *)object inGamesAtIndex:(NSUInteger)index {
  [games insertObject:object atIndex:index];
}

- (void)removeObjectFromGamesAtIndex:(NSUInteger)index {
  [games removeObjectAtIndex:index];
}

- (void)setGames:(NSMutableArray *)_games {
  games = _games;
}

- (NSMutableArray *)games {
  return games;
}

- (void)insertObject:(Stream *)object inStreamsAtIndex:(NSUInteger)index {
  [streams insertObject:object atIndex:index];
}

- (void)removeObjectFromStreamsAtIndex:(NSUInteger)index {
  [streams removeObjectAtIndex:index];
}

- (void)setStreams:(NSMutableArray *)_streams {
  streams = _streams;
}

- (NSMutableArray *)streams {
  return streams;
}

- (void)fetchStreamsForGame:(Game *)game {
  [self setSpinnerHidden:NO];
  RKObjectMapping *streamMapping = [RKObjectMapping mappingForClass:[Stream class]];
  [streamMapping mapAttributes:@"viewers", nil];
  [streamMapping mapKeyPath:@"preview" toAttribute:@"previewImageURL"];
  [streamMapping mapKeyPath:@"channel.status" toAttribute:@"status"];
  [streamMapping mapKeyPath:@"channel.name" toAttribute:@"name"];
  [streamMapping mapKeyPath:@"channel.display_name" toAttribute:@"displayName"];
  streamMapping.rootKeyPath = @"streams";
  NSDictionary *query = [NSDictionary dictionaryWithObject:game.name forKey:@"game"];
  [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[@"/streams" stringByAppendingQueryParameters:query] usingBlock:^(RKObjectLoader *loader) {
    [loader setObjectMapping:streamMapping];
    [loader setOnDidLoadObjects:^(NSArray *retStreams){
      [self setStreams:[retStreams mutableCopy]];
      [self setSpinnerHidden:YES];
    }];
    [loader setOnDidFailWithError:^(NSError *error) {
      [self setSpinnerHidden:YES];
      NSLog(@"url: %@", loader.response.request.URL);
//      NSLog(@"response: %@", [loader.response bodyAsString]);
      NSLog(@"error: %@", [error localizedDescription]);
    }];
  }];
}

- (void)setSpinnerHidden:(BOOL)hidden {
  [self.spinnerBox setHidden:hidden];
  if (hidden) {
    [self.spinner stopAnimation:nil];
  } else {
    [self.spinner startAnimation:nil];
  }

}

@end
