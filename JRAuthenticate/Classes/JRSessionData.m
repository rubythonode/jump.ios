/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 Copyright (c) 2010, Janrain, Inc.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
	 list of conditions and the following disclaimer. 
 * Redistributions in binary form must reproduce the above copyright notice, 
	 this list of conditions and the following disclaimer in the documentation and/or
	 other materials provided with the distribution. 
 * Neither the name of the Janrain, Inc. nor the names of its
	 contributors may be used to endorse or promote products derived from this
	 software without specific prior written permission.
 
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 File:	 JRSessionData.m 
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:	 Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import "JRSessionData.h"

// TODO: Figure out why the -DDEBUG cflag isn't being set when Active Conf is set to debug
#define DEBUG
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


@implementation JRProvider

- (JRProvider*)initWithName:(NSString*)nm andStats:(NSDictionary*)stats
{
	DLog(@"");
	
	if (nm == nil || nm.length == 0 || stats == nil)
	{
		[self release];
		return nil;
	}
	
	if (self = [super init]) 
	{
		providerStats = [[NSDictionary dictionaryWithDictionary:stats] retain];
		name = [nm retain];

		welcomeString = nil;
		
		placeholderText = nil;
		shortText = nil;
		userInput = nil;
		friendlyName = nil;
		providerRequiresInput = NO;
	}
	
	return self;
}

- (NSString*)name
{
	return name;
}

- (NSString*)friendlyName 
{
	return [providerStats objectForKey:@"friendly_name"];
}

- (NSString*)placeholderText
{
	return [providerStats objectForKey:@"input_prompt"];
}

- (NSString*)shortText
{
	if (self.providerRequiresInput)
	{
		NSArray *arr = [[self.placeholderText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "];
		NSRange subArr = {[arr count] - 2, 2};
		
		NSArray *newArr = [arr subarrayWithRange:subArr];
		return [newArr componentsJoinedByString:@" "];	
	}
	else 
	{
		return @"";
	}
}

- (NSString*)userInput
{
	return userInput;
}

- (void)setUserInput:(NSString*)ui
{
	userInput = [ui retain];
}

- (void)setWelcomeString:(NSString*)ws
{
	welcomeString = [ws retain];
}

- (NSString*)welcomeString
{
	return welcomeString;
}

- (BOOL)providerRequiresInput
{
	if ([[providerStats objectForKey:@"requires_input"] isEqualToString:@"YES"])
		 return YES;
		
	return NO;
}

- (void)dealloc
{
	DLog(@"");
		
	[providerStats release];
	[name release];
	[welcomeString release];
	[userInput release];
	
	[super dealloc];
}
@end

@interface JRSessionData()
- (void)startGetConfiguredProviders;
- (void)finishGetConfiguredProviders:(NSString*)dataStr;

- (void)loadCookieData;
@end

@implementation JRSessionData
@synthesize errorStr;

//@synthesize allProviders;
@synthesize providerInfo;
@synthesize configedProviders;
@synthesize socialProviders;

@synthesize currentProvider;
@synthesize returningProvider;
@synthesize currentSocialProvider;
@synthesize returningSocialProvider;

@synthesize delegate;
//@synthesize activity;

@synthesize hidePoweredBy;

@synthesize forceReauth;

//@synthesize token;
//@synthesize tokenUrl;

- (id)initWithBaseUrl:(NSString*)URL /*tokenUrl:(NSString*)tokUrl*/ andDelegate:(id<JRSessionDelegate>)del
{
	DLog(@"");
	
	if (URL == nil || URL.length == 0)
	{
		[self release];
		return nil;
	}
	
	if (self = [super init]) 
	{
		delegate = [del retain];
		baseURL = [[NSString stringWithString:URL] retain];

//		tokenUrl = tokUrl;
		currentProvider = nil;
		returningProvider = nil;

        deviceTokensByProvider = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceTokensByProvider"]];
        
//		allProviders = nil;
		providerInfo = nil;
		configedProviders = nil;
	
		errorStr = nil;
		forceReauth = NO;
		
		[self startGetConfiguredProviders];
	}
	return self;
}

- (void)dealloc 
{
	DLog(@"");
		
//	[allProviders release];
	[providerInfo release];
	[configedProviders release];
	
	[currentProvider release];
	[returningProvider release];
	
	[baseURL release];
	[errorStr release];
	
//	[token release];
	[delegate release];
	
	[super dealloc];
}

- (NSURL*)startURL
{
	DLog(@"");
    
//	NSDictionary *providerStats = [allProviders objectForKey:currentProvider.name];
	JRProvider *provider = (currentSocialProvider) ? (currentSocialProvider) : currentProvider;
    
//    NSDictionary *providerStats = [providerInfo objectForKey:currentProvider.name];
    NSDictionary *providerStats = [providerInfo objectForKey:provider.name];
	NSMutableString *oid;
	
	if ([providerStats objectForKey:@"openid_identifier"])
	{
		oid = [NSMutableString stringWithFormat:@"openid_identifier=%@&", [NSString stringWithString:[providerStats objectForKey:@"openid_identifier"]]]; //[NSMutableString stringWithString:[providerStats objectForKey:@"openid_identifier"]];
		
//		if(currentProvider.providerRequiresInput)
		if(provider.providerRequiresInput)
			[oid replaceOccurrencesOfString:@"%@" 
								 //withString:[currentProvider.userInput
                                 withString:[provider.userInput
											 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
									options:NSLiteralSearch 
									  range:NSMakeRange(0, [oid length])];
		//	oid = [NSString stringWithFormat:oid, [currentProvider.userInput stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	else 
	{
		oid = [NSMutableString stringWithString:@""];
	}

	NSString* str = [NSString stringWithFormat:@"%@%@?%@%@%@device=iphone", 
                     baseURL, 
                     [providerStats objectForKey:@"url"], 
                     oid, 
                     ((forceReauth) ? @"force_reauth=true&" : @""),
                     (([provider.name isEqualToString:@"facebook"]) ? 
                      @"ext_perm=publish_stream&" : @"")];
    
	
	forceReauth = NO;
	
	DLog(@"startURL: %@", str);
	return [NSURL URLWithString:str];
}


- (void)loadCookieData
{
	DLog(@"");
	NSHTTPCookieStorage* cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookieStore cookiesForURL:[NSURL URLWithString:baseURL]];
	
	NSString *welcomeString = nil;
	NSString *provider = nil;
	NSString *userInput = nil;
		
	for (NSHTTPCookie *cookie in cookies) 
	{
		if ([cookie.name isEqualToString:@"welcome_info"])
		{
			welcomeString = [NSString stringWithString:cookie.value];
			DLog(@"welcomeString: %@", welcomeString);
		}
		else if ([cookie.name isEqualToString:@"login_tab"])
		{
			provider = [NSString stringWithString:cookie.value];
			DLog(@"provider:      %@", provider);
		}
		else if ([cookie.name isEqualToString:@"user_input"])
		{
			userInput = [NSString stringWithString:cookie.value];
			DLog(@"userInput:     %@", userInput);
		}
	}	
	
	if (provider)
	{
		DLog(@"returningProvider: %@", provider);
//		returningProvider = [[JRProvider alloc] initWithName:provider andStats:[allProviders objectForKey:provider]];
		returningProvider = [[JRProvider alloc] initWithName:provider andStats:[providerInfo objectForKey:provider]];
		
		if (welcomeString)
			[returningProvider setWelcomeString:welcomeString];
		if (userInput)
			[returningProvider setUserInput:userInput];
	}
}

- (void)startGetConfiguredProviders
{
	DLog(@"");

	NSString *urlString = [baseURL stringByAppendingString:@"/openid/iphone_config"];
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	if(!url) // Then there was an error
		return;
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	
	NSString *tag = [[NSString stringWithFormat:@"getConfiguredProviders"] retain];
	
	if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
		errorStr = [NSString stringWithFormat:@"There was an error initializing JRAuthenticate.\nThere was a problem getting the list of configured providers."];

	[request release];
}

- (void)finishGetConfiguredProviders:(NSString*)dataStr
{
	DLog(@"");
	NSDictionary *jsonDict = [dataStr JSONValue];
	
	if(!jsonDict)
		return;
	
//	TODO: Switch all the classes to call providerInfo instead of allProviders	
	providerInfo = [[NSDictionary dictionaryWithDictionary:[jsonDict objectForKey:@"provider_info"]] retain];
//	allProviders = [[NSDictionary dictionaryWithDictionary:[jsonDict objectForKey:@"provider_info"]] retain];
	
	configedProviders = [[NSArray arrayWithArray:[jsonDict objectForKey:@"enabled_providers"]] retain];
    //socialProviders = [[NSArray arrayWithArray:[jsonDict objectForKey:@"social_providers"]] retain];
    
    
    NSMutableArray *temporaryArrayForTestingShouldBeRemoved = [[[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:@"social_providers"]
                                                                                           copyItems:YES] autorelease];
    [temporaryArrayForTestingShouldBeRemoved addObject:@"yahoo"];
    socialProviders = [[NSArray arrayWithArray:temporaryArrayForTestingShouldBeRemoved] retain];
        
    
	if ([[jsonDict objectForKey:@"hide_tagline"] isEqualToString:@"YES"])
		hidePoweredBy = YES;
	else
		hidePoweredBy = NO;
	
//	if(configedProviders)
//		[configedProviders retain];
	
	[self loadCookieData];
}

- (NSString*)identifierForProvider:(NSString*)provider
{
    return [identifiersProviders objectForKey:provider];
}

- (NSString*)sessionTokenForProvider:(NSString*)provider
{
    return [deviceTokensByProvider objectForKey:provider];
}

- (void)forgetSessionTokenForProvider:(NSString*)provider
{
    [deviceTokensByProvider removeObjectForKey:@"provider"];
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokensByProvider forKey:@"deviceTokensByProvider"];
}

- (void)forgetAllSessionTokens
{
    [deviceTokensByProvider release];
    deviceTokensByProvider = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"deviceTokensByProvider"];
}

// TODO: Many issues with this function, like timing of cookies/calls/etc/
- (void)checkForIdentifierCookie:(NSURLRequest*)request
{
    NSHTTPCookieStorage* cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookieStore cookiesForURL:[request URL]];//[NSURL URLWithString:@"http://jrauthenticate.appspot.com"]];
	NSString *cookieIdentifier = nil;
//	NSString *test = [request valueForHTTPHeaderField:@"sid"];
    
	for (NSHTTPCookie *cookie in cookies) 
	{
		if ([cookie.name isEqualToString:@"sid"])
		{
			cookieIdentifier = [[NSString stringWithString:cookie.value] 
								stringByTrimmingCharactersInSet:
								[NSCharacterSet characterSetWithCharactersInString:@"\""]];
		}
	}	
    
    if (!identifiersProviders)
        identifiersProviders = [[NSMutableDictionary alloc] initWithObjectsAndKeys:cookieIdentifier, currentSocialProvider.name, nil];
    else
        [identifiersProviders setObject:cookieIdentifier forKey:currentSocialProvider.name];
    
    if (!deviceTokensByProvider)
        deviceTokensByProvider = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [deviceTokensByProvider setObject:cookieIdentifier forKey:currentSocialProvider.name];
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokensByProvider forKey:@"deviceTokensByProvider"];
}

- (void)connectionDidFinishLoadingWithUnEncodedPayload:(NSData*)payload request:(NSURLRequest*)request andTag:(void*)userdata { }

- (void)connectionDidFinishLoadingWithPayload:(NSString*)payload request:(NSURLRequest*)request andTag:(void*)userdata
{
	NSString* tag = (NSString*)userdata;
	[payload retain];
	
	DLog(@"payload: %@", payload);
	DLog(@"tag:     %@", tag);
	
	if ([tag isEqualToString:@"getConfiguredProviders"])
	{
		if ([payload rangeOfString:@"\"provider_info\":{"].length != 0)
		{
			[self finishGetConfiguredProviders:payload];
		}
		else // There was an error...
		{
			errorStr = [NSString stringWithFormat:@"There was an error initializing JRAuthenticate.\nThere was an error in the response to a request."];
		}
	}
	else if ([tag hasPrefix:@"token_url:"])
	{
//		theTokenUrlPayload = [[NSString stringWithString:payload] retain];
		NSString* tokenURL = [NSString stringWithString:[[request URL] absoluteString]];
							
        [self checkForIdentifierCookie:request];
        
        [delegate jrAuthenticateDidReachTokenURL:tokenURL withPayload:payload];
	}

	[payload release];
	[tag release];	
}

- (void)connectionDidFailWithError:(NSError*)error request:(NSURLRequest*)request andTag:(void*)userdata 
{
	NSString* tag = (NSString*)userdata;
	DLog(@"tag:     %@", tag);

	if ([tag isEqualToString:@"getBaseURL"])
	{
		errorStr = [NSString stringWithFormat:@"There was an error initializing JRAuthenticate.\nThere was an error in the response to a request."];
	}
	else if ([tag isEqualToString:@"getConfiguredProviders"])
	{
		errorStr = [NSString stringWithFormat:@"There was an error initializing JRAuthenticate.\nThere was an error in the response to a request."];
	}
    else if ([tag hasPrefix:@"token_url:"])
	{
		errorStr = [NSString stringWithFormat:@"There was an error posting the token to the token URL.\nThere was an error in the response to a request."];
		NSRange prefix = [tag rangeOfString:@"token_url:"];
		
		NSString *tokenURL = (prefix.length > 0) ? [tag substringFromIndex:prefix.length]: nil;
		
        [delegate jrAuthenticateCallToTokenURL:tokenURL didFailWithError:error];
    }
    
	
	[tag release];	
}

- (void)connectionWasStoppedWithTag:(void*)userdata 
{
	[(NSString*)userdata release];
}

- (void)setReturningProviderToProvider:(JRProvider*)provider
{
	DLog(@"");
    
	[returningProvider release];
	returningProvider = [provider retain];
}

- (void)setCurrentProviderToReturningProvider
{
	DLog(@"");
	currentProvider = [returningProvider retain];
}

- (void)setProvider:(NSString *)provider
{
	DLog(@"provider: %@", provider);

	if (![currentProvider.name isEqualToString:provider])
	{	
		[currentProvider release];
		
		if ([returningProvider.name isEqualToString:provider])
			[self setCurrentProviderToReturningProvider];
		else
			currentProvider = [[[JRProvider alloc] initWithName:provider andStats:[providerInfo objectForKey:provider]] retain];
//			currentProvider = [[[JRProvider alloc] initWithName:prov andStats:[allProviders objectForKey:prov]] retain];
	}

	[currentProvider retain];
}


- (void)setSocialProvider:(NSString *)provider
{
	DLog(@"provider: %@", provider);
    
	if (![currentSocialProvider.name isEqualToString:provider])
	{	
		[currentSocialProvider release];
		
        currentSocialProvider = [[[JRProvider alloc] initWithName:provider andStats:[providerInfo objectForKey:provider]] retain];
    }
    
//	[currentProvider retain];
}

- (void)makeCallToTokenUrl:(NSString*)tokenURL WithToken:(NSString *)token
{
	DLog(@"token:    %@", token);
	DLog(@"tokenURL: %@", tokenURL);
	
	NSMutableData* body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"token=%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
	NSMutableURLRequest* request = [[NSMutableURLRequest requestWithURL:[NSURL URLWithString:tokenURL]] retain];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:body];
	
	NSString* tag = [[NSString stringWithFormat:@"token_url:%@", tokenURL] retain];
	
	if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
	{
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Problem initializing connection to Token URL" 
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"JRAuthenticate"
                                             code:100
                                         userInfo:userInfo];
		
        [delegate jrAuthenticateCallToTokenURL:tokenURL didFailWithError:error];
	}
	
	[request release];
}


//- (void)makeCallToTokenUrlWithToken:(NSString*)token
//{
//	[self makeCallToTokenUrl:theTokenUrl WithToken:token];
//}	





- (void)authenticationDidCancel
{
	[delegate jrAuthenticationDidCancel];
}

- (void)authenticationDidCompleteWithToken:(NSString*)token
{
//	token = [tok retain];
	
	[self setReturningProviderToProvider:self.currentProvider];
	NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookieStore cookiesForURL:[NSURL URLWithString:baseURL]];
	
	[cookieStore setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
	NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceNow:604800] autorelease];
	
	NSHTTPCookie *cookie = nil;
	NSRange found;
	NSString* cookieDomain = nil;
	
	found = [baseURL rangeOfString:@"http://"];
	
	if (found.length == 0)
		found = [baseURL rangeOfString:@"https://"];

	if (found.length == 0)
		cookieDomain = baseURL;
	else
		cookieDomain = [baseURL substringFromIndex:(found.location + found.length)];
	
	DLog("Setting cookie \"login_tab\" to value:  %@", self.returningProvider.name);
	cookie = [NSHTTPCookie cookieWithProperties:
			  [NSDictionary dictionaryWithObjectsAndKeys:
			   self.returningProvider.name, NSHTTPCookieValue,
			   @"login_tab", NSHTTPCookieName,
			   cookieDomain, NSHTTPCookieDomain,
			   @"/", NSHTTPCookiePath,
			   @"FALSE", NSHTTPCookieDiscard,
			   date, NSHTTPCookieExpires, nil]];
	[cookieStore setCookie:cookie];
	
	DLog("Setting cookie \"user_input\" to value: %@", self.returningProvider.userInput);
	cookie = [NSHTTPCookie cookieWithProperties:
			  [NSDictionary dictionaryWithObjectsAndKeys:
			   self.returningProvider.userInput, NSHTTPCookieValue,
			   @"user_input", NSHTTPCookieName,
			   cookieDomain, NSHTTPCookieDomain,
			   @"/", NSHTTPCookiePath,
			   @"FALSE", NSHTTPCookieDiscard,
			   date, NSHTTPCookieExpires, nil]];
	[cookieStore setCookie:cookie];
	
	for (NSHTTPCookie *savedCookie in cookies) 
	{
		if ([savedCookie.name isEqualToString:@"welcome_info"])
		{
			[returningProvider setWelcomeString:[NSString stringWithString:savedCookie.value]];
		}
	}	
    
	[delegate jrAuthenticationDidCompleteWithToken:token andProvider:currentProvider.name];
}

- (void)authenticationDidCompleteWithAuthenticationToken:(NSString*)authToken andSessionToken:(NSString*)sessToken
{
    if (!deviceTokensByProvider)
        deviceTokensByProvider = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [deviceTokensByProvider setObject:sessToken forKey:currentSocialProvider.name];
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokensByProvider forKey:@"deviceTokensByProvider"];

    [self  authenticationDidCompleteWithToken:authToken];
}

- (void)authenticationDidFailWithError:(NSError*)err
{
	[delegate jrAuthenticationDidFailWithError:err];
}

@end
