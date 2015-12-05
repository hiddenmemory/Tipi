# Discount Markdown Processor for iOS and OS X

## Overview [![Build Status](https://travis-ci.org/sumardi/OCDiscount.png)](https://travis-ci.org/sumardi/OCDiscount)

Discount is an implementation of John Gruber's Markdown markup language in C. It
implements all of the language described in [the markdown syntax document][1] and
passes the [Markdown 1.0 test suite][2].

Discount was developed by [David Loren Parsons][3]. `OCDiscount` is created and maintained by [Sumardi Shukor][4].

## Requirements

`OCDiscount` requires Xcode 5, targeting either iOS 6.0 and above, or Mac OS 10.8 Mountain Lion (64-bit with modern Cocoa runtime) and above.

The `libdiscount.a` static library must be linked into the application target for proper compilation. The steps are:

1. In the project editor, select the target to which you want to add the library
1. Click Build Phases at the top of the project editor.
1. Open the Link Binary With Libraries section.
1. Click the Add button (+) to add `libdiscount.a` library.

> Ignore these steps if you are using [CocoaPods][5].

## Installation

[CocoaPods][5] is the recommended way to add `OCDiscount` to your project.  

Here's an example podfile that installs `OCDiscount`. 

### Podfile

```ruby
platform :osx, '10.8'
pod 'OCDiscount', '~> 0.1.0'
```

Then run `pod install`.

## Usage

Depending on how you configure your project you may need to `#import` either `<OCDiscount/OCDiscount.h>` or `"OCDiscount.h"`.

```objective-c
NSString *test = @"*Hello* from **markdown**!";

NSLog(@"%@", [markdown htmlStringFromMarkdown]);
```

## Support

Bugs and feature request are tracked on [Github][6].

## Documentations

* [OCDiscount Reference][7]

## License 

Discount is free software;  it is released under a BSD-style license
that allows you to do as you wish with it as long as you don't attempt
to claim it as your own work. `OCDiscount` is available under the MIT license. See the `LICENSE` file for more info.

[1]: http://daringfireball.net/projects/markdown/syntax
[2]: http://daringfireball.net/projects/downloads/MarkdownTest_1.0.zip
[3]: http://www.pell.portland.or.us/~orc
[4]: https://twitter.com/sumardi
[5]: http://www.cocoapods.org
[6]: https://github.com/sumardi/OCDiscount/issues.
[7]: http://sumardi.github.io/OCDiscount/