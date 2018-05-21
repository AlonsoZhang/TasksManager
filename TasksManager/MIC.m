//
//  MIC.m
//
//
//  Created by MAC on 15/11/4.
//
//

#import "MIC.h"
#import <CommonCrypto/CommonDigest.h>


//MICURL
#define MICURL @"http://10.42.25.200"

static MIC *sharedManager=nil;

@implementation MIC

- (id)init
{
    self = [super init];
    BodyAFA=@"";
    ConfigPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"]];
    return self;
    
}

+ (MIC *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager=[[self alloc]init];
    });
    return sharedManager;
}

- (NSString *)CheckNetworkToMic
{
    NSString *Respnse  = [self GetURL:[NSString stringWithFormat:@"%@/Portal/Login.aspx",MICURL]];
    // NSLog(@"response:%@",Respnse);
    if ([Respnse rangeOfString:@"Allie" options:NSCaseInsensitiveSearch].location!=NSNotFound||[Respnse rangeOfString:@"纬创资通" options:NSCaseInsensitiveSearch].location!=NSNotFound)
    {
        return @"Network OK!";
    }
    else
    {
        return @"Can't connect to Mic338!";
    }
}

- (NSString *)CheckPsw:(NSString *)Name Password:(NSString *)Psw
{
    NSString *EVENTVALIDATION = @"%2FwEWBwL%2BraDpAgLT07raDgLJg7v7AwL%2BjNCfDwKAhrBOApaZ27gJAoXrx78KaA8Nt8V2m%2FiWnaL%2FRarW90q%2BVqY%3D";
    NSString    *Postbody     = [NSString stringWithFormat:@"__VIEWSTATE=&__EVENTVALIDATION=%@&UserIdText=%@&PasswordText=%@&LoginButton=Sign in&CultureName=",EVENTVALIDATION,Name,[self md5:Psw]];
    NSString    *Respnse      = [self PostURL:[NSString stringWithFormat:@"%@/Portal/Login.aspx",MICURL] Postbody:Postbody];
    if ([Respnse rangeOfString:@"Content.aspx" options:NSCaseInsensitiveSearch].location!=NSNotFound)
    {
        return @"Psw ok!";
    }
    else
    {
        return @"Username/Password is wrong!";
    }
}

- (NSString *)GetURL :(NSString*)URL
{
    NSURL *url = [NSURL URLWithString:URL];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *htmlString = [[NSString alloc]initWithData:received encoding: NSUTF8StringEncoding ];
    return htmlString;
}

- (NSString*)PostURL:(NSString *)URL Postbody:(NSString *)BODY
{
    NSURL *url = [NSURL URLWithString:  URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSData *data = [BODY dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *String = [[NSString alloc]initWithData:received encoding: NSUTF8StringEncoding ];
    return String;
}

- (NSString*)GetTagStringback:(NSString *)Tag  TagIndex:(int) Index HTMLBody:(NSString *)Body
{
    NSString *Tagstart   = [NSString stringWithFormat:@"<%@",Tag];
    NSString *Tagend     = [NSString stringWithFormat:@"</%@",Tag];
    NSRange  rang        = [Body rangeOfString:Tagend options:NSBackwardsSearch];
    if (rang.location == NSNotFound) {return @"NSNotFound";}
    NSString *subString  = [Body substringToIndex:rang.location];
    while (--Index > 0)
    {
        rang             = [subString rangeOfString:Tagend options:NSBackwardsSearch];
        if (rang.location == NSNotFound) {return @"NSNotFound";}
        subString        = [subString substringToIndex:rang.location];
    }
    rang                 = [subString rangeOfString:Tagstart options:NSBackwardsSearch];
    if (rang.location == NSNotFound)
    {
        return @"NSNotFound";
    }
    subString            = [subString substringFromIndex:(rang.location+rang.length)];
    rang                 = [subString rangeOfString:@">"];
    if (rang.location == NSNotFound)
    {
        return @"NSNotFound";
    }
    subString            = [subString substringFromIndex:(rang.location+rang.length)];
    return subString;
}

-(NSString *)md5:(NSString *)str
{
    const char *cstr= [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (int)strlen(cstr),result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15]];
}

- (NSString*) GetProperty:(NSString *)String  HTMLBody:(NSString *)Body
{
    NSString *Tagstart = [NSString stringWithFormat:@"<input"];
    NSString *Tagend   = [NSString stringWithFormat:@">"];
    NSRange  rang = [Body rangeOfString:String];
    NSString *subString;
    if (rang.location!=NSNotFound)
    {
        subString = [Body substringToIndex:rang.location + rang.length ];
        rang          = [subString rangeOfString:Tagstart options:NSBackwardsSearch];
        if (rang.location == NSNotFound) {return @"NSNotFound";}
        subString     = [Body substringFromIndex:rang.location];
        if (rang.location == NSNotFound) {return @"NSNotFound";}
        rang          = [subString rangeOfString:Tagend];
        if (rang.location == NSNotFound) {return @"NSNotFound";}
        subString     = [subString substringToIndex:(rang.location+rang.length)];
        subString=[NSString stringWithFormat:@"%@",subString];
        rang           = [subString rangeOfString:@"value"];
        if (rang.location == NSNotFound) {return @"NSNotFound";}
        subString      = [subString substringFromIndex:(rang.location+rang.length+2)];
        rang                    = [subString rangeOfString:@"\""];
        if (rang.location == NSNotFound) {return @"NSNotFound";}
        subString               = [subString substringToIndex:rang.location];
        subString = [subString stringByReplacingOccurrencesOfString :@"/" withString:@"%2F"];
        subString = [subString stringByReplacingOccurrencesOfString :@"+" withString:@"%2B"];
        subString = [subString stringByReplacingOccurrencesOfString :@"=" withString:@"%3D"];
    }
    else
    {
        NSLog(@"error");
    }
    return subString;
}

- (NSMutableDictionary *)GetIT4DataMining_Table:(NSString *)USN
{
    NSMutableDictionary *resultdic=[NSMutableDictionary new];
    NSString *CheckFlag  = [self GetURL:[NSString stringWithFormat:@"%@/MIREPORT001/MIREPORT001.aspx?apid=MIEPMA01",MICURL]];
    NSString *Respnse=[self PostURL:[NSString stringWithFormat:@"%@/MIREPORT001/MIREPORT001.aspx?apid=MIEPMA01",MICURL] Postbody:[NSString stringWithFormat:@"__VIEWSTATE=%@&__EVENTVALIDATION=%@&lstTab=0&USN=%@&cmdQuery=Query&EXCEL=&txtREPORTSort=",[self GetProperty:@"VIEWSTATE" HTMLBody:CheckFlag],[self GetProperty:@"EVENTVALIDATION" HTMLBody:CheckFlag],USN]];
    //NSLog(@"%@",Respnse);
    NSRange   rang = [Respnse rangeOfString:@"id=\"grdGrid\"" options:NSBackwardsSearch];
    if (rang.location == NSNotFound)
    {
        [resultdic setObject:@"Webpage has been updated!Please call SW to update!" forKey:@"error"];
        return resultdic;
    }
    else
    {
        NSString *DumpTable= [self FindTagString:@"id=\"grdGrid\"" HTMLTag:@"table" HTMLBody:Respnse];
        [resultdic setObject:[self GetTable:DumpTable] forKey:@"IT4DataMining"];
        NSLog(@"%@",resultdic);
    }
    return resultdic;
}

- (NSString*)FindTagString:(NSString *)String HTMLTag:(NSString *)Tag HTMLBody:(NSString *)Body
{
    NSString *Tagstart = [NSString stringWithFormat:@"<%@",Tag];
    NSString *Tagend   = [NSString stringWithFormat:@"</%@>",Tag];
    NSRange  rang = [Body rangeOfString:String];
    NSString *subString = [Body substringToIndex:rang.location + rang.length];
    rang          = [subString rangeOfString:Tagstart options:NSBackwardsSearch];
    subString     = [Body substringFromIndex:(rang.location-rang.length)];
    rang          = [subString rangeOfString:Tagend];
    subString     = [subString substringToIndex:(rang.location+rang.length)];
    subString=[NSString stringWithFormat:@"%@",subString];
    return subString;
}

- (NSString*) GetTagStringgo:(NSString *)Tag  TagIndex:(int) Index HTMLBody:(NSString *)Body
{
    NSString *Tagstart = [NSString stringWithFormat:@"<%@",Tag];
    NSString *Tagend   = [NSString stringWithFormat:@"</%@",Tag];
    NSRange  rang           = [Body rangeOfString:Tagstart];
    if (rang.location == NSNotFound) {return @"NSNotFound";}
    NSString *subString     = [Body substringFromIndex:(rang.location+rang.length)];
    while (--Index > 0)
    {
        rang          = [subString rangeOfString:Tagstart];
        if (rang.location == NSNotFound) {return @"NSNotFound";}
        subString     = [subString substringFromIndex:(rang.location+rang.length)];
    }
    rang          = [subString rangeOfString:@">"];
    if (rang.location == NSNotFound) {return @"NSNotFound";}
    subString     = [subString substringFromIndex:(rang.location+rang.length)];
    rang          = [subString rangeOfString:Tagend];
    if (rang.location == NSNotFound) {return @"NSNotFound";}
    subString     = [subString substringToIndex:rang.location];
    return subString;
}

-(NSMutableArray *)GetTable:(NSString *)HTMLString
{
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"th" withString:@"td"];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"TD" withString:@"td"];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"TR" withString:@"tr"];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"<A " withString:@"<a "];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"</A>" withString:@"</a>"];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
    NSMutableArray * OutArry = [[NSMutableArray alloc]init];
    for (NSString* One in [self FindArry:HTMLString withregex:@"<tr[\\s\\S]+?(?=</tr>)"])
    {
        [OutArry addObject:[self FindArry:One withregex:@"<td[\\s\\S]+?(?=</td>)"]];
    }
    return OutArry;
}

-(NSMutableArray *)FindArry:(NSString *)TargetString withregex:(NSString *) regexString
{
    NSError *error;
    NSString *pattern = [NSString stringWithFormat:@"%@",regexString];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSMutableArray *temparr = [NSMutableArray new];
    if (regex != nil)
    {
        NSArray *array = [regex matchesInString:TargetString options:0 range:NSMakeRange(0, TargetString.length)];
        for (NSTextCheckingResult* b in array)
        {
            NSString * tmp = [[TargetString substringWithRange:b.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([[self FindinString:tmp withregex:@"(?<=>)[\\s\\S]*"] length] > 0)
            {
                tmp = [self FindinString:tmp withregex:@"(?<=>)[\\s\\S]*"];
                if ( [regexString rangeOfString:@"td"].location!= NSNotFound)
                {
                    if ([tmp containsString:@"</font>"])
                    {
                        tmp = [self GetTagStringgo:@"font" TagIndex:1 HTMLBody:tmp];
                    }
                    if ([tmp containsString:@"</b>"])
                    {
                        tmp = [self GetTagStringgo:@"b" TagIndex:1 HTMLBody:tmp];
                    }
                    if ([tmp containsString:@"</a>"])
                    {
                        tmp = [self GetTagStringgo:@"a" TagIndex:1 HTMLBody:tmp];
                    }
                }
            }
            tmp = [tmp stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"#" withString:@""];
            tmp = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [temparr addObject:tmp];
        }
    }
    return temparr;
}

-(NSString *)FindinString:(NSString *)TargetString withregex:(NSString *) regexString
{
    NSError *error;
    NSString *pattern = [NSString stringWithFormat:@"%@",regexString];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSString *strResult=@"";
    if (regex != nil)
    {
        NSTextCheckingResult *result = [regex firstMatchInString:TargetString options:0 range:NSMakeRange(0, [TargetString length])];
        
        if (result)
        {
            strResult = [[TargetString substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    return strResult;
}

@end
