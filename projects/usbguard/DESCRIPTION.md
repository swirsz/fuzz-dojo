Use (Report link) to browse the source code and fuzz introspector report https://introspector.oss-fuzz.com/project-profile?project=usbguard

Fuzz Introspector
https://storage.googleapis.com/oss-fuzz-introspector/usbguard/inspector-report/20250411/fuzz_report.html

USBGuard is a software framework for implementing USB device authorization policies. 3 fuzz drivers reach 41% of the project code.  97% static code coverage indicates that large sections of the code could possibly be called by these existing fuzz drivers but currently is not.

For example, the appliesToWithConditions, a function in RulePrivate.cpp that checks if a rule applies to a given device with additional conditions is mostly untested.
