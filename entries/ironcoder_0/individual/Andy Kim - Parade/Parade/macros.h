/*
 PFMacros.h
 
 Bunch of convenience macros for coding and debugging
 
 Version: 1.2
 */

/*--------------------------------------------------------------------------------
Localization
--------------------------------------------------------------------------------*/

#define NSLS(string, comment) NSLocalizedString(string, comment)

/*--------------------------------------------------------------------------------
Debugging macros
--------------------------------------------------------------------------------*/

// Hybrid of printf and NSLog
#define print(format, ...)												\
printf("%s\n", [[NSString stringWithFormat:[NSString stringWithUTF8String:format], ##__VA_ARGS__] UTF8String])

#define printobj(obj) \
print("%@", obj)

// Print method signature
#define SIG											\
printf("----------------------------------------\n"); \
printf("%s\n", __PRETTY_FUNCTION__);					\

// Print method signature with timestamp
#define TSIG											\
NSLog(@"----------------------------------------"); \
NSLog(@"%s", __PRETTY_FUNCTION__);					\

// NSLog without having to type the @ character for the string
#define nslog(format, ...) NSLog(@#format, ##__VA_ARGS__)

#define PFABSTRACT \
printf("%s - This method is abstract\n", __PRETTY_FUNCTION__);

#define foreach(element, collection) for(id _ ## element ## _enumerator = [collection objectEnumerator], element; element = [_ ## element ## _enumerator nextObject]; )
