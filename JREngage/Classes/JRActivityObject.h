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
 
 File:	 JRActivityObject.h
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:	 Tuesday, August 24, 2010
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/**
 * @file
 * @brief Interface for creating and populating activities that you wish to publish.
 * 
 * Interface for creating and populating activities that you wish to publish
 * to your user's social networks.  Create an activity object, fill in the 
 * object's fields, and pass the object to the JREngage library when you
 * are ready to share.
 **/

#import <Foundation/Foundation.h>
#import "JRConnectionManager.h"

/* Added a category to NSString including a function to correctly escape any arguments sent to 
   Engage, so that there are no errors when sending a json structure to rpxnow's api */
@interface NSString (NSString_URL_ESCAPING)
- (NSString*)URLEscaped;
@end

/**
 * @internal 
 * Base class for JRImageMediaObject, JRFlashMediaObject, and JRMp3MediaObject.
 **/
@interface JRMediaObject : NSObject { }
@end

/**
 * @brief Image object to be included in a post to a user's stream. 
 *
 * Create an image media object, fill in the object's fields, and add the object to the 
 * JRActivityObject#media array in your JRActivityObject.  How the images get presented 
 * and whether or not they are used, depend on the provider.
 *
 * Each image must contain a \e src URL, which maps to the photo's URL, and an 
 * \e href URL, which maps to the URL where a user should be taken if he or she clicks the photo.
 *
 * @sa
 * Format and rules are identical to those described on the
 * <a href="http://developers.facebook.com/docs/guides/attachments"> 
 * Facebook Developer page on Attachments</a>.
 **/
@interface JRImageMediaObject : JRMediaObject
{
    // QTS: Place doxygen comments on instance variables or public properties?
    NSString *src;  /**< The photo's URL. */
    NSString *href; /**< The URL where a user should be taken if he or she clicks the photo. */
    
    UIImage  *preview; /**< \internal Contains the downloaded preview of the image for display in the publish activity dialog. */
}
@property (readonly) NSString *src;
@property (readonly) NSString *href;
@property (retain) UIImage *preview;

/** 
 * @name Constructors
 **/
/*@{*/
/**
 * Returns a JRImageMediaObject initialized with the given src and href.
 *
 * @param _src
 *   The photo's URL.  This value cannot be \e nil
 *
 * @param _href
 *   The URL where a user should be taken if he or she clicks the photo.  This value cannot be \e nil
 *
 * @return
 *   A JRImageMediaObject initialized with the given src and href.  If either
 *   _src or _href are \e nil, returns \e nil
 **/
- (id)initWithSrc:(NSString *)_src andHref:(NSString *)_href;
+ (id)imageMediaObjectWithSrc:(NSString*)_src andHref:(NSString*)_href;
/*@}*/
@end


/**
 * @brief Flash object to be included in a post to a user's stream. 
 *
 * Create an flash media object, fill in the object's fields, and add the object to the 
 * JRActivityObject#media array in your JRActivityObject.  How the flash videos get presented 
 * and whether or not they are used, depend on the provider.
 *
 * Each video must contain a \e swfsrc url, which is the URL of the Flash object to be rendered,
 * and an \e imgsrc, which is the URL of an photo that should be displayed in place of the 
 * flash object until the user clicks to prompt the flash object to play.  Flash object
 * has two optional fields, \e width and \e height, which can be used to override the 
 * default choices when displaying the video in the provider's stream (e.g., Facebook's stream).
 * It also has two optional fields, \e expanded_width and \e expanded_height, to specify 
 * the width and height of flash object will resize to, on the provider's stream,
 * once the user clicks on it.
 *
 * @note You can only include one JRFlashMediaObject in the media array.  Any others
 * will be ignored.
 *
 * @sa
 * Format and rules are identical to those described on the
 * <a href="http://developers.facebook.com/docs/guides/attachments"> 
 * Facebook Developer page on Attachments</a>.
 **/
@interface JRFlashMediaObject : JRMediaObject
{
    NSString *swfsrc;           /**< The URL of the Flash object to be rendered. */
    NSString *imgsrc;           /**< The URL of an photo that should be displayed in place of the flash object. */
    NSUInteger width;           /**< Used to override the default width. */
    NSUInteger height;          /**< Used to override the default height. */
    NSUInteger expanded_width;  /**< Width the video will resize to once the user clicks it. */
    NSUInteger expanded_height; /**< Height the video will resize to once the user clicks it. */
    
    UIImage *preview;           /**< \internal Contains the downloaded preview of the image for display in the publish activity dialog. */
}
@property (readonly) NSString *swfsrc;
@property (readonly) NSString *imgsrc;
@property NSUInteger width;		
@property NSUInteger height;
@property NSUInteger expanded_width;
@property NSUInteger expanded_height;
@property (retain) UIImage *preview;

/** 
 * @name Constructors
 **/
/*@{*/
/**
 * Returns a JRFlashMediaObject initialized with the given swfsrc and imgsrc.
 *
 * @param _swfsrc
 *   The URL of the Flash object to be rendered.  This value cannot be \e nil
 *
 * @param _imgsrc
 *   The URL of an photo that should be displayed in place of the flash object.  This value cannot be \e nil
 *
 * @return
 *   A JRFlashMediaObject initialized with the given swfsrc and imgsrc.  If either
 *   _swfsrc or _imgsrc are \e nil, returns \e nil
 **/
- (id)initWithSwfsrc:(NSString *)_swfsrc andImgsrc:(NSString *)_imgsrc;

+ (id)flashMediaObjectWithSwfsrc:(NSString*)_swfsrc andImgsrc:(NSString*)_imgsrc;
/*@}*/
@end


/**
 * @brief Mp3 object to be included in a post to a user's stream. 
 *
 * Create an mp3 media object, fill in the object's fields, and add the object to the 
 * JRActivityObject#media array in your JRActivityObject.  How the mp3s get presented 
 * and whether or not they are used, depend on the provider.
 *
 * Each mp3 must contain a \e src url, which is the URL of the MP3 file to be rendered. 
 * The mp3 can also include a \e title, \e artist, and \e album.
 *
 * @note You can only include one JRMp3MediaObject in the media array.  Any others
 * will be ignored.
 *
 * @sa
 * Format and rules are identical to those described on the
 * <a href="http://developers.facebook.com/docs/guides/attachments"> 
 * Facebook Developer page on Attachments</a>.
 **/
@interface JRMp3MediaObject : JRMediaObject
{
    NSString *src;      /**< The URL of the MP3 file to be rendered. */
    NSString *title;    /**< The title of the song. */
    NSString *artist;   /**< The artist. */
    NSString *album;    /**< The album. */
}
@property (readonly) NSString *src;
@property (retain) NSString *title;
@property (retain) NSString *artist;
@property (retain) NSString *album;

/** 
 * @name Constructors
 **/
/*@{*/
/**
 * Returns a JRMp3MediaObject initialized with the given src.
 *
 * @param _src
 *   The URL of the MP3 file to be rendered.  This value cannot be \e nil
 *
 * @return
 *   A JRMp3MediaObject initialized with the given src.  If 
 *   _src is \e nil, returns \e nil
 **/
- (id)initWithSrc:(NSString *)_src;

+ (id)mp3MediaObjectWithSrc:(NSString*)_src;
/*@}*/
@end


/**
 * @brief A link a user can use to take action on an activity update on the provider.
 *
 * Create an action link object, fill in the object's fields, and add the object
 * the JRActivityObject#action_links array of your JRActivityObject.
 *
 * Each action link must contain a link, \e href, and some \e text, describing what action
 * will happen if someone clicks the link. 
 *
 * @par Example:
 * @code
 * action_links: 
 * [
 *   {
 *     "text": "Rate this quiz result",
 *     "href": "http://example.com/quiz/12345/result/6789/rate"
 *   },
 *   {
 *     "text": "Take this quiz",
 *     "href": "http://example.com/quiz/12345/take"
 *   }
 * ]
 * @endcode
 * 
 **/
@interface JRActionLink : NSObject
{
    NSString *text; /**< The text describing the link. */
    NSString *href; /**< A link a user can use to take action on an activity update on the provider. */
}
@property (retain) NSString *text;
@property (retain) NSString *href;

/** 
 * @name Constructors
 **/
/*@{*/
/**
 * Returns a JRActionLink initialized with the given text and href.
 *
 * @param _text
 *   The text describing the link.  This value cannot be \e nil
 *
 * @param _imgsrc
 *   A link a user can use to take action on an activity update on the provider.  This value cannot be \e nil
 *
 * @return
 *   A JRActionLink initialized with the given text and href.  If either
 *   _text or _href are \e nil, returns \e nil
 **/
- (id)initWithText:(NSString *)_text andHref:(NSString *)_href;

+ (id)actionLinkWithText:(NSString*)_text andHref:(NSString*)_href;
/*@}*/
@end


/**
 * @brief Object containing content to be shared by email
 *
 * Create an email object, fill in the fields, and add the object
 * to the JRActivityObject#email property in your JRActivityObject.
 * The given content is supplied to the \e MFMailComposeViewController 
 * class when the user wants to share your activity via email. 
 * 
 * If your email message body contains URLs that you would like shortened 
 * to an <a href="http://rpxnow.com/docs/iphone#shorten_urls">http://rpx.me/</a>
 * URL (with which you can track click-throughs), add the 
 * exact URL(s) to the \e urls array.  The library will contact the Engage
 * servers to obtain shortened URLs and replace any instance of the url in
 * your email body.
 *
 * @note
 * If the user attempts to share the activity via email before the
 * call to shorten the URLs is returned, the email will contain the original 
 * URLs and the click-throughs will not be tracked. \n@note
 * Once the \e MFMailComposeViewController is displayed, the given subject and body can be modified by the user.
 **/
@interface JREmailObject : NSObject
{
    NSString *subject;      /**< The desired email subject. */
    NSString *messageBody;  /**< The desired message body. */
    BOOL      isHtml;       /**< Specify YES if the body parameter contains HTML content or specify NO if it contains plain text, */
    NSArray  *urls;         /**< An array of URLs that will be shortened to the http://rpx.me domain so that click-through rates can be tracked @anchor emailUrls. */
}
@property (retain) NSString *subject;       
@property (retain) NSString *messageBody;
@property          BOOL      isHtml;
@property (retain) NSArray  *urls;

/** 
 * @name Constructors
 **/
/*@{*/
/**
 * Returns a JREmailObject initialized with the given subject and message body.
 *
 * @param _subject
 *   The desired subject of the email.  The user can edit this value once the \e MFMailComposeViewController
 *   is displayed
 *
 * @param _messageBody
 *   The desired message body of the email.  The message body can be in plain text or html, and if it is in html,
 *   this should be indicated by the argument \e isHtml.  If you want to include urls that are shortened
 *   to an <a href="http://rpxnow.com/docs/iphone#shorten_urls">http://rpx.me/</a> they should be added to the
 *   \e urls array.  Once the call to get the shortened URLs is completed, the library will replace
 *   all occurrences of each url with its corresponding shortened url.  This value can be edited by the user once the 
 *   \e MFMailComposeViewController is displayed
 *
 * @param _isHtml
 *   \c YES if the message body contains HTML content or \c NO if it contains plain text
 *
 * @param _urls
 *   The array of urls that %JREngage will shorten to an <a href="http://rpxnow.com/docs/iphone#shorten_urls">http://rpx.me/</a>
 *   Once the call to get the shortened URLs is completed, the library will replace all occurrences of each url with its corresponding 
 *   shortened url. To avoid blocking the UI, if the user tries to share via email before the call is returned, the original urls will remain
 *
 * @return
 *   A JREmailObject initialized with the given subject and message body
 **/
- (id)initWithSubject:(NSString *)_subject andMessageBody:(NSString *)_messageBody isHtml:(BOOL)_isHtml andUrlsToBeShortened:(NSArray*)_urls;

+ (id)emailObjectWithSubject:(NSString *)_subject andMessageBody:(NSString *)_messageBody isHtml:(BOOL)_isHtml andUrlsToBeShortened:(NSArray*)_urls;
/*@}*/
@end


/**
 * @brief Object containing the default message to be shared by sms
 *
 * Create an sms object, fill in the message field, and add the object
 * to the JRActivityObject#sms property in your JRActivityObject.
 * The given message string is supplied to the \e MFMessageComposeViewController 
 * class when the user wants to share your activity via sms. 
 * 
 * If your sms message contains URLs that you would like shortened 
 * to an <a href="http://rpxnow.com/docs/iphone#shorten_urls">http://rpx.me/</a>
 * (with which you can track click-throughs), add the exact URL(s) to the \e urls array.
 * The library will contact the Engage servers to obtain shortened URLs and replace any 
 * instance of the url in your sms message.
 *
 * @note
 * If the user attempts to share the activity via sms before the
 * call to shorten the URLs is returned, the sms will contain the original 
 * URLs and the click-throughs will not be tracked. <br /><br />
 * Once the \e MFMessageComposeViewController is displayed, the given message string can be
 * modified by the user.
 **/
@interface JRSmsObject : NSObject
{
    NSString *message;  /**< The desired message. */
    NSArray  *urls;     /**< An array of URLs that will be shortened to the http://rpx.me domain so that click-through rates can be tracked. @anchor smsUrls*/
}
@property (retain) NSString *message;
@property (retain) NSArray  *urls;

/**
 * @name Constructors
 **/
/*@{*/
/**
 * Returns a JRSmsObject initialized with the given message and URLs that you wish to be
 * shortened to the <a href="http://rpxnow.com/docs/iphone#shorten_urls">http://rpx.me/</a> format.
 *
 * @param _message
 *   The desired message text of the sms.  If you want to include urls that are shortened to an 
 *   <a href="http://rpxnow.com/docs/iphone#shorten_urls">http://rpx.me/</a> url, they should be added 
 *   to the \e urls array.  Once the call to get the shortened URLs is completed, the library will replace
 *   all occurrences of each url with its corresponding shortened url.  This value can be edited by 
 *   the user once the \e MFMessageComposeViewController is displayed
 *
 * @param _urls
 *   The array of urls that %JREngage will shorten to an <a href="http://rpxnow.com/docs/iphone#shorten_urls">http://rpx.me/</a> url.
 *   Once the call to get the shortened URLs is completed, the library will replace all occurrences of each url with its corresponding
 *   shortened url. To avoid blocking the UI, if the user tries to share via sms before the call is returned, the original urls will remain
 *
 * @return
 *   A JRSmsObject initialized with the given message text
 **/
- (id)initWithMessage:(NSString*)_message andUrlsToBeShortened:(NSArray*)_urls;

+ (id)smsObjectWithMessage:(NSString *)_message andUrlsToBeShortened:(NSArray*)_urls;
/*@}*/
@end


/**
 * @brief An activity object you create, populate, and post to the user's activity stream. 
 *
 * Create an activity object, fill in the object's fields, and pass the object to
 * the JREngage library when you are ready to publish. Currently supported providers are:
 *   - Facebook
 *   - LinkedIn
 *   - Twitter
 *   - MySpace
 *   - Yahoo!
 *
 * Janrain Engage will make a best effort to use all of the fields submitted in the activity request, 
 * but note that how they get presented (and which ones are used) ultimately depends on the provider.
 *
 * This API will work if and only if:
 *   - Your Janrain Engage application has been configured with the given provider
 *   - The user has already authenticated and has given consent to publish activity
 * 
 * Otherwise, you will be given an error response indicating what was wrong. Detailed error responses will 
 * also be given if the activity parameter does not meet the formatting requirements described below. 
 * 
 * @sa
 * For more information of Janrain Engage's activity api, see
 * <a href="http://documentation.janrain.com/activity">the activity section</a> of our API Documentation.
 **/
@interface JRActivityObject : NSObject 
{
   /** 
    * @name
    * The various properties of the JRActivityObject that you can configure.
    **/
   /*@{*/
    
   /**
    * A string describing what the user did, written in the third person (e.g., 
    * "wrote a restaurant review", "posted a comment", "took a quiz").
    **/
    NSString *action;  					
    
   /**
    * The URL of the resource being mentioned in the activity update.
    **/
    NSString *url;
    
   /**
    * A string containing user-supplied content, such as a comment or the first paragraph of an article 
    * that the user wrote. 
    * 
    * @note
    * Some providers (Twitter in particular) may truncate this value.
    **/
    NSString *user_generated_content;    

   /**
    * The title of the resource being mentioned in the activity update. 
    *
    * @note
    * No length restriction on the status is imposed by Janrain Engage,
    * however Yahoo truncates this value to 256 characters. 
    **/
    NSString *title;                     
    
   /**
    * A description of the resource mentioned in the activity update.
    **/
    NSString *description;
    
   /**
    * An array of JRActionLink objects, each having two attributes: text and href.
    * An action link is a link a user can use to take action on an activity update on the provider.
    *
    * @par Example:
    * @code
    * action_links:
    * [
    *   {
    *     "text": "Rate this quiz result",
    *     "href": "http://example.com/quiz/12345/result/6789/rate"
    *   },
    *   {
    *     "text": "Take this quiz",
    *     "href": "http://example.com/quiz/12345/take"
    *   }
    * ]
    * @endcode
    * 
    * @note
    * Any objects added to this array that are not of type JRActionLink will be ignored.
    **/
    NSMutableArray *action_links;
    
   /**
    * An array of objects with base class \e JRMediaObject (i.e., JRImageMediaObject,
    * JRFlashMediaObject, JRMp3MediaObject). 
    * 
    * To publish attached media objects with your activity, create the preferred
    * object, populate the object's fields, then add the object to the \e media array.
    * You can attach pictures, videos, and mp3s to your activity, although how the
    * media objects get presented and whether or not they are used, depend on the provider.
    *
    * If you include more than one media type in the array, JREngage will 
    * choose only one of these types, in this order:
    *   -# image
    *   -# flash
    *   -# mp3
    *
    * Also, any objects added to this array that are not of type \e JRMediaObject will be ignored.
    *
    * @sa
    * Media object format and rules are identical to those described on the
    * <a href="http://developers.facebook.com/docs/guides/attachments"> Facebook Developer page on Attachments</a>.
    **/   
    NSMutableArray *media;

   /**
    * An object with attributes describing properties of the update. An attribute value can be 
    * a string or an object with two attributes, text and href. 
    *
    * @par Example:
    * @code
    *   properties: 
    *   {
    *       "Time": "05:00",
    *       "Location": 
    *       {
    *           "text": "Portland",
    *           "href": "http://en.wikipedia.org/wiki/Portland,_Oregon"
    *       }
    *   }
    * @endcode
    **/
    NSMutableDictionary *properties;
    
   /**
    * @anchor activityEmail
    *
    * An object containing the subject and message body of an email, if the user wishes to
    * share via email.
    **/
    JREmailObject *email;

   /**
    * @anchor activitySms
    *
    * An object containing the message body of an sms, if the user wishes to
    * share via sms.
    **/
    JRSmsObject *sms;
    
    /*@}*/
    
    NSString *shortenedUrl;
}

@property (readonly) NSString *action;  							
@property (readonly) NSString *url;
@property (retain) NSString *user_generated_content;
@property (retain) NSString *title;				
@property (retain) NSString *description;
@property (retain) NSMutableArray *action_links; 					
@property (retain) NSMutableArray *media;
@property (retain) NSMutableDictionary *properties;
@property (retain) JREmailObject *email;
@property (retain) JRSmsObject *sms;

/** 
 * @name Constructors
 **/
/*@{*/
/**
 * Returns a JRActivityObject initialized with the given action and url.
 *
 * @param _action
 *   A string describing what the user did, written in the third person.  This value cannot be \e nil
 *
 * @param _url
 *   The URL of the resource being mentioned in the activity update.  
 *
 * @return
 *   A JRActivityObject initialized with the given action and url.  If action _action is \e nil, returns \e nil
 **/
- (id)initWithAction:(NSString*)_action andUrl:(NSString*)_url;

+ (id)activityObjectWithAction:(NSString*)_action andUrl:(NSString*)_url;

/**
 * Returns a JRActivityObject initialized with the given action.
 *
 * @param _action
 *   A string describing what the user did, written in the third person.  This value cannot be \e nil
 *
 * @return
 *   A JRActivityObject initialized with the given action.  If action _action is \e nil, returns \e nil
 **/
- (id)initWithAction:(NSString*)_action;

+ (id)activityObjectWithAction:(NSString*)_action;
/*@}*/

/**
 * @internal
 * Returns an NSDictionary representing the JRActivityObject.
 *
 * @return
 *   An NSDictionary of NSString objects representing the JRActivityObject
 *
 * @note
 * This function should not be used directly.  It is intended only for use by the
 * JREngage library
 **/
- (NSDictionary*)dictionaryForObject;
@end
