// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "Unittest_import_lite.pb.h"
// @@protoc_insertion_point(imports)

@implementation UnittestImportLiteRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [UnittestImportLiteRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [UnittestImportPublicLiteRoot registerAllExtensions:registry];
    extensionRegistry = registry;
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

BOOL ImportEnumLiteIsValidValue(ImportEnumLite value) {
  switch (value) {
    case ImportEnumLiteImportLiteFoo:
    case ImportEnumLiteImportLiteBar:
    case ImportEnumLiteImportLiteBaz:
      return YES;
    default:
      return NO;
  }
}
NSString *NSStringFromImportEnumLite(ImportEnumLite value) {
  switch (value) {
    case ImportEnumLiteImportLiteFoo:
      return @"ImportEnumLiteImportLiteFoo";
    case ImportEnumLiteImportLiteBar:
      return @"ImportEnumLiteImportLiteBar";
    case ImportEnumLiteImportLiteBaz:
      return @"ImportEnumLiteImportLiteBaz";
    default:
      return nil;
  }
}

@interface ImportMessageLite ()
@property SInt32 d;
@end

@implementation ImportMessageLite

- (BOOL) hasD {
  return !!hasD_;
}
- (void) setHasD:(BOOL) _value_ {
  hasD_ = !!_value_;
}
@synthesize d;
- (instancetype) init {
  if ((self = [super init])) {
    self.d = 0;
  }
  return self;
}
static ImportMessageLite* defaultImportMessageLiteInstance = nil;
+ (void) initialize {
  if (self == [ImportMessageLite class]) {
    defaultImportMessageLiteInstance = [[ImportMessageLite alloc] init];
  }
}
+ (instancetype) defaultInstance {
  return defaultImportMessageLiteInstance;
}
- (instancetype) defaultInstance {
  return defaultImportMessageLiteInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasD) {
    [output writeInt32:1 value:self.d];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (SInt32) serializedSize {
  __block SInt32 size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasD) {
    size_ += computeInt32Size(1, self.d);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (ImportMessageLite*) parseFromData:(NSData*) data {
  return (ImportMessageLite*)[[[ImportMessageLite builder] mergeFromData:data] build];
}
+ (ImportMessageLite*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (ImportMessageLite*)[[[ImportMessageLite builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (ImportMessageLite*) parseFromInputStream:(NSInputStream*) input {
  return (ImportMessageLite*)[[[ImportMessageLite builder] mergeFromInputStream:input] build];
}
+ (ImportMessageLite*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (ImportMessageLite*)[[[ImportMessageLite builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (ImportMessageLite*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (ImportMessageLite*)[[[ImportMessageLite builder] mergeFromCodedInputStream:input] build];
}
+ (ImportMessageLite*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (ImportMessageLite*)[[[ImportMessageLite builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (ImportMessageLiteBuilder*) builder {
  return [[ImportMessageLiteBuilder alloc] init];
}
+ (ImportMessageLiteBuilder*) builderWithPrototype:(ImportMessageLite*) prototype {
  return [[ImportMessageLite builder] mergeFrom:prototype];
}
- (ImportMessageLiteBuilder*) builder {
  return [ImportMessageLite builder];
}
- (ImportMessageLiteBuilder*) toBuilder {
  return [ImportMessageLite builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasD) {
    [output appendFormat:@"%@%@: %@\n", indent, @"d", [NSNumber numberWithInteger:self.d]];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (void) storeInDictionary:(NSMutableDictionary *)dictionary {
  if (self.hasD) {
    [dictionary setObject: [NSNumber numberWithInteger:self.d] forKey: @"d"];
  }
  [self.unknownFields storeInDictionary:dictionary];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[ImportMessageLite class]]) {
    return NO;
  }
  ImportMessageLite *otherMessage = other;
  return
      self.hasD == otherMessage.hasD &&
      (!self.hasD || self.d == otherMessage.d) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasD) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.d] hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface ImportMessageLiteBuilder()
@property (strong) ImportMessageLite* resultImportMessageLite;
@end

@implementation ImportMessageLiteBuilder
@synthesize resultImportMessageLite;
- (instancetype) init {
  if ((self = [super init])) {
    self.resultImportMessageLite = [[ImportMessageLite alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return resultImportMessageLite;
}
- (ImportMessageLiteBuilder*) clear {
  self.resultImportMessageLite = [[ImportMessageLite alloc] init];
  return self;
}
- (ImportMessageLiteBuilder*) clone {
  return [ImportMessageLite builderWithPrototype:resultImportMessageLite];
}
- (ImportMessageLite*) defaultInstance {
  return [ImportMessageLite defaultInstance];
}
- (ImportMessageLite*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (ImportMessageLite*) buildPartial {
  ImportMessageLite* returnMe = resultImportMessageLite;
  self.resultImportMessageLite = nil;
  return returnMe;
}
- (ImportMessageLiteBuilder*) mergeFrom:(ImportMessageLite*) other {
  if (other == [ImportMessageLite defaultInstance]) {
    return self;
  }
  if (other.hasD) {
    [self setD:other.d];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (ImportMessageLiteBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (ImportMessageLiteBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSetBuilder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    SInt32 tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 8: {
        [self setD:[input readInt32]];
        break;
      }
    }
  }
}
- (BOOL) hasD {
  return resultImportMessageLite.hasD;
}
- (SInt32) d {
  return resultImportMessageLite.d;
}
- (ImportMessageLiteBuilder*) setD:(SInt32) value {
  resultImportMessageLite.hasD = YES;
  resultImportMessageLite.d = value;
  return self;
}
- (ImportMessageLiteBuilder*) clearD {
  resultImportMessageLite.hasD = NO;
  resultImportMessageLite.d = 0;
  return self;
}
@end


// @@protoc_insertion_point(global_scope)
