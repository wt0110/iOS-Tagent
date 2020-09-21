/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <WebDriverAgentLib/FBDebugLogDelegateDecorator.h>
#import <WebDriverAgentLib/FBConfiguration.h>
#import <WebDriverAgentLib/FBFailureProofTestCase.h>
#import <WebDriverAgentLib/FBWebServer.h>
#import <WebDriverAgentLib/XCTestCase.h>
#import <WebDriverAgentLib/FBAlert.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <WebDriverAgentLib/WebDriverAgentLib.h>
#import <WebDriverAgentLib/FBMathUtils.h>

@interface NSObject (ML)

@end

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@implementation NSObject (ML)
+(void)load{
  {
     Method originalMethod = class_getInstanceMethod(NSClassFromString(@"RoutingHTTPServer"), @selector(routeMethod:withPath:parameters:request:connection:));
     Method swizzledMethod = class_getInstanceMethod(NSClassFromString(@"RoutingHTTPServer"), @selector(swizzle_routeMethod:withPath:parameters:request:connection:));
     method_exchangeImplementations(originalMethod, swizzledMethod);
  }
  
  {
    Method originalMethod = class_getClassMethod(NSClassFromString(@"FBElementCommands"), @selector(gestureCoordinateWithCoordinate:application:shouldApplyOrientationWorkaround:));
    Method swizzledMethod = class_getClassMethod(NSClassFromString(@"NSObject"), @selector(fb_gestureCoordinateWithCoordinate:application:shouldApplyOrientationWorkaround:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
  
  {
    Method originalMethod = class_getClassMethod(NSClassFromString(@"FBElementCommands"), @selector(handleTap:));
    Method swizzledMethod = class_getClassMethod(NSClassFromString(@"FBElementCommands"), @selector(fb_handleTap:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
  
  {
    Method originalMethod = class_getClassMethod(NSClassFromString(@"XCUIApplication"), @selector(dictionaryForElement:recursive:));
    Method swizzledMethod = class_getClassMethod(NSClassFromString(@"XCUIApplication"), @selector(fb_dictionaryForElement:recursive:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
  
  {
    Method originalMethod = class_getClassMethod(NSClassFromString(@"FBSessionCommands"), @selector(handleDeleteSession:));
    Method swizzledMethod = class_getClassMethod(NSClassFromString(@"FBSessionCommands"), @selector(fb_handleDeleteSession:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
}

#pragma mark- FBSessionCommands::handleDeleteSession
+ (id<FBResponsePayload>)handleDeleteSession:(FBRouteRequest *)request
{
  return nil;
}

+ (id<FBResponsePayload>)fb_handleDeleteSession:(FBRouteRequest *)request
{
  return [self fb_handleDeleteSession:request];
}


#pragma mark - XCUIApplication::dictionaryForElement
+ (NSDictionary *)dictionaryForElement:(XCElementSnapshot *)snapshot recursive:(BOOL)recursive {
  return nil;
}

+ (NSDictionary *)fb_dictionaryForElement:(XCElementSnapshot *)snapshot recursive:(BOOL)recursive {
  NSMutableDictionary *result = (NSMutableDictionary *)[self fb_dictionaryForElement:snapshot recursive:recursive];
  result[@"label"] = FBValueOrNull(snapshot.wdLabel);
  result[@"title"] = FBValueOrNull(snapshot.title);
  result[@"value"] = FBValueOrNull(snapshot.value);
  return result;
}

#pragma mark - gestureCoordinateWithCoordinate
+ (XCUICoordinate *)gestureCoordinateWithCoordinate:(CGPoint)coordinate element:(XCUIElement *)element
{
  return nil;
}

+ (XCUICoordinate *)gestureCoordinateWithCoordinate:(CGPoint)coordinate application:(XCUIApplication *)application shouldApplyOrientationWorkaround:(BOOL)shouldApplyOrientationWorkaround{
  return nil;
}

+ (XCUICoordinate *)fb_gestureCoordinateWithCoordinate:(CGPoint)coordinate application:(XCUIApplication *)application shouldApplyOrientationWorkaround:(BOOL)shouldApplyOrientationWorkaround{
    CGPoint point = coordinate;
    if (shouldApplyOrientationWorkaround) {
      point = FBInvertPointForApplication(coordinate, application.frame.size, application.interfaceOrientation);
    }
    
    XCUIElement *alert = [application.alerts firstMatch];
    if (alert.frame.origin.x > 0) {
      point.x -= alert.frame.origin.x;
      point.y -= (alert.frame.origin.y);
      return [self gestureCoordinateWithCoordinate:point element:alert];
    }else{
      return [self fb_gestureCoordinateWithCoordinate:coordinate application:application shouldApplyOrientationWorkaround:shouldApplyOrientationWorkaround];
    }
}

#pragma mark - handleTap
+ (id)handleTap:(id)request {
  return nil;
}

+ (id)fb_handleTap:(id)request {
  NSLog(@"****** begginTap:");
  id result = [self fb_handleTap:request];
  NSLog(@"****** endTap:");
  return result;
}

#pragma mark - sessionWithApplication
+ (instancetype)sessionWithApplication:(id)session
{
  return nil;
}

+ (instancetype)sw_sessionWithApplication:(id)session
{
  id ss = [self sw_sessionWithApplication:session];
  return ss;
}

+ (void)markSessionActive:(id)session
{
}

+ (void)sw_markSessionActive:(id)session
{
  [self sw_markSessionActive:session];
}

#pragma mark - routeMethod

- (RouteResponse *)swizzle_routeMethod:(NSString *)method withPath:(NSString *)path parameters:(NSDictionary *)params request:(id)httpMessage connection:(id)connection {
  if ([path containsString:@"screenshot"]) {
    //调用频次太高，在此可以做限流，解决页面响应慢问题
  }else{
    NSLog(@"******** receive request:%@  path:%@",method,path);
  }
  return [self swizzle_routeMethod:method withPath:path parameters:params request:httpMessage connection:connection];
}

- (RouteResponse *)routeMethod:(NSString *)method withPath:(NSString *)path parameters:(NSDictionary *)params request:( id)httpMessage connection:(id)connection{
  return nil;
}

@end

@interface UITestingUITests : FBFailureProofTestCase <FBWebServerDelegate>
@end

@implementation UITestingUITests

+ (void)setUp
{
  [FBDebugLogDelegateDecorator decorateXCTestLogger];
  [FBConfiguration disableRemoteQueryEvaluation];
  [FBConfiguration configureDefaultKeyboardPreferences];
  [super setUp];
}

/**
 Never ending test used to start WebDriverAgent
 */
- (void)testRunner
{
  FBWebServer *webServer = [[FBWebServer alloc] init];
  webServer.delegate = self;
  [webServer startServing];
}

#pragma mark - FBWebServerDelegate

- (void)webServerDidRequestShutdown:(FBWebServer *)webServer
{
  [webServer stopServing];
}

@end
