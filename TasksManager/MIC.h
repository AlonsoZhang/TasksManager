//
//  MIC.h
//
//
//  Created by MAC on 15/11/4.
//
//

#import <Foundation/Foundation.h>

@interface MIC : NSObject
{
    NSString *BodyAFA;
    NSMutableDictionary *ConfigPlist;
}

- (NSString*)PostURL:(NSString *)URL Postbody:(NSString *)BODY;
- (NSString *)CheckNetworkToMic;
- (NSString *)CheckPsw:(NSString *)Name Password:(NSString *)Psw;
- (NSMutableDictionary *)GetIT4DataMining_Table:(NSString *)USN;
+(MIC *)sharedManager;


@end
