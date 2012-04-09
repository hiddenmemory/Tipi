# Tipi: Tiny Templating Engine

Copyright 2012 [Dave Gurnell] of [Untyped] and [Chris Ross] of [hiddenMemory].

*Tipi* is a tiny templating engine written in Objective-C. It lets you define templates to avoid needless repetition and redundancy in any type of text file. Its primary intended use is the static generation of HTML pages.

**Tipi is currently in early alpha. Everything may be subject to change.**

# Overview

Tipi's syntax is based on [Mustache]. However, its engine is a little more powerful.

Mustache requires you to invoke your templates from a programming language such as Javascript. All your template data has to be defined in code - you can't blend data and templates.

Tipi allows you to do everything you can do with Mustache, but it can also be used independently of the host programming language. You can define templates, define data, and invoke the templates with the data, all from within a single Tipi file.

Here's an example:

    {{# def cat name="" knownFor="" }}
      <li>{{ name }}, best known for {{ knownFor }}</li>
    {{/ def }]

    <p>Notable Internet felines:</p>

    <ul>
    {{ cat name="Long Cat"     knownFor="being long" }}
    {{ cat name="Keyboard Cat" knownFor="playing a fine tune" }}
    {{ cat name="Nyan Cat"     knownFor="singing, being half Pop Tart" }}
    {{ cat name="Nonono Cat"   knownFor="negativity" }}
    </ul>

This file uses a special tag, `def`, to define a template called `cat`. it then invokes `cat` four times to produce the bullet points in the list. The output is as follows:

    <p>Notable Internet felines:</p>

    <ul>
      <li>Long Cat, best known for being long</li>
      <li>Keyboard Cat, best known for playing a fine tune</li>
      <li>Nyan Cat, best known for singing, being half Pop Tart</li>
      <li>Nonono Cat, best known for negativity</li>
    </ul>

The `def` tag itself doesn't produce any output. However, when Tipi processes it, it stores the `cat` away for later use. This causes the `cat` tags later on to produce the correct templated output.

Programmers will recognise these semantics straight away. Tipi is actually a very simple programming language, supporting function definition and invocation (with static binding and lexical scoping semantics). The `def` tag is simply a predefined function that has a side-effect of registering a template for later use.

As a way of illustrating this, here is a Javascript fragment that is semantically equivalent to the above document:

    function cat(name, knownFor) {
      return "<li>" + name + ", best known for " + knownFor + "</li>";
    }

    function main() {
      return
        "<ul>" +
        cat("Long Cat",     "being long") +
        cat("Keyboard Cat", "playing a fine tune") +
        cat("Nyan Cat",     "singing, being half Pop Tart") +
        cat("Nonono Cat",   "negativity") +
        "</ul>";
    }

    document.write(main());

# Writing template files

## Tags and arguments

Tipi syntax involves three types of *tag*:

 - `{{# openingTags }}` denote the beginning of a block of content - they must be paired with a closing tag
 - `{{/ closingTags }}` denote the end of a block - they must be paired with an opening tag
 - `{{ singletonTags }}` appear on their own - they are equivalent to an opening tag immediately followed by a corresponding closing tag

Opening and singleton tags optionally take a list of arguments. Closing tags may not take arguments. Here is an example:

    {{# person name="Dave" url="http://untyped.com" }}
      {{# occupation }}Software Developer{{/ occupation }]
      {{# hobbies }}Music, running{{/ hobbies }}
    {{/ person }}

## Defining templates

By default, Tipi recognises only three built-in templates: `def`, `bind`, and `this`.

`def` is used to define other templates. You can define simple templates in argument style:

    {{ def food="Lasagne" drink="Water" }}

or more complex templates in block style:

    {{# def person name="No name specified" url="http://www.example.com" }}
      {{ name }} has a web site at {{ url }}
    {{/ def }}

The two forms are semantically similar. Think of them as function definitions in a regular programming language:

    var food = function() {
    	return "Lasagne"
    }
	var drink = function() {
		return "Water"
	}

    var person = function(name, url) {
    	return name + " has a web site at " + url;
    }

If you don't wish to povide a default value for the argument you can leave the value out. Tipi will evaluate the argument to an empty string (if not provide at call).

	{{#def food}}
		{{food}}
	{{/def}}

*Note: Tipi is case-insensitive.*

## Invoking templates

Once you have defined a template using `def`, you can *invoke* it by writing its name as a tag:

    {{ food }} // ==> "Lasagne"

    {{ person name="Chris" url="darkrock.co.uk" }} // ==> "Chris has a web site at darkrock.co.uk"

## Passing blocks using `this`

For more verbose invocations, you can pass a block of text as an argument using the `this` built-in:

    {{# def center}}
      <p style="text-align: center">
        {{ this }}
      </p>
    {{/ def }}

    {{# center }}
      Lots of text...
    {{/ center }}

Tags in the argument are expanded *before* it is passed to the template. This makes the semantics similar to regular programming languages. For example, the following templates and function calls are semantically similar:

    {{#x}}{{y}}{{/x}}

    x(y())

## Passing named blocks using `bind`

You can pass multiple named blocks as argument using the `bind` built-in:

    {{# def page sidebar article }}
      <p class="sidebar">{{ sidebar }}</p>
      <p class="article">{{ article }}</p>
    {{/ def }}

    {{# page }}
      {{# bind sidebar }}
        Long sidebar definition goes here ...
      {{/ bind }}
      {{# bind article }}
        Long article definition goes here ...
      {{/ bind }}
    {{/ center }}

This is similar to named arguments in Scala function calls. Note, however, that the arguments must be declared in the opening tag of the template, otherwise `bind` calls will be ignored. This is to stop the injection of values into a template it isn't expecting.

As with `this`-style arguments, `bind` blocks are expanded before they are passed to the template. For example, the following templates and function call pseudo-code are semantically similar:

    {{#x}}
      {{#bind a}}{{y}}{{/bind}}
      {{#bind b}}{{z}}{{/bind}}
    {{/x}}

    x(
      a = y(),
      z = b()
    )

While it is possible to mix normal, `this` and `bind` arguments, we recommend you stick to one kind of argument for each template you write. Otherwise things can become confusing.

##Environment Capture

When defining a template, Tipi requires you to denote all incoming values you wish to be dynamic in the parameter list. Any values that aren't specified in the parameter list will be bound to the surrounding environment at the point of definition:

	{{def Version=1.0}}
	
	{{#def DisplayFooter message}}
		<div class="footer">{{Version}} - {{message}}</div>
	{{/def}}
	
	{{DisplayFooter message="Thanks for visiting, have a great day"}} // => <div class="footer">1.0 - Thanks for visiting, have a great day</div>

If the `Version` def was not provided, or provided below the `DisplayFooter` def, `{{version}}` would have evaluated to an empty string.

##Template Inception

Tipi allows the passing of one template as an argument into another:

	{{#def dynamic_list_item value="Test Value"}}
		<li> {{value}} </li>
	{{/def}}
	
	{{#def list list_item="<li>No template</li>"}}
	<ol>
		{{list_item value="Chris"}}
		{{list_item value="Dave"}}
		{{list_item value="Tipi"}}
	</ol>
	{{/def}}
	
	{{list list_item=dynamic_list_item}}

Due to lazy evaluation of parameters being passed into a template, templates can be passed in and evaluated in place. In the above example, Tipi will invoke `dynamic_list_item` when ever `list_item`. This opens up all sorts of templating opporunities allowing list and layout templates to need not care about specifics of inidivdual item layout.

# Running Tipi from Objective-C

First, create a `TPTemplateParser` object, making sure to reference the file to parse:

    #import "Tipi.h"

    TPTemplateParser *tipi = [TPTemplateParser parserForFile:inputPath];

To evaluate the template into an NSString:

    NSString *expansion = [tipi expansion];

If you wish to provide a set of values into the template expasion you need to provide an NSDictionary and call `expansionUsingEnvironment:`

    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:...., nil];
	NSString *expansion = [tipi expansionUsingEnvironment:environment];

Currently it is possible to provide two different types of values:

 - Simple string value. Set the value to be the string you wish the value to expand to and the key to be the tag name you want to refernce.
 - A Objective-C block. The block must return an NSString object. The block takes a node within the template and the current environment. If you supply a block, it is the job of the supplied block to evaluate the `childNodes` attached the `node`. This can easily be done by either invoking the `TPTemplateNode` method `expansionUsingEnvironment:`, or the NSArray method `tp_templateNodesExpandedUsingEnvironment:` which will call `expansionUsingEnvironment:` on each node within the array and return the concatenated string.
	
		[environment setObject:[^NSString*( TPTemplateNode *node, NSMutableDictionary *environment ) {
			return [NSString stringWithFormat:@"This is the expansion: %@", [node.childNodes tp_templateNodesExpandedUsingEnvironment:environment]];
		} copy] forKey:key];
	
	In future versions this mechanism of providing custom nodes will be made cleaner.

# How it works

## Parsing

Tipi parses these tags into a DOM tree, where each branch is a block and each leaf is a text node. For example, the document:

    {{# person name="Chris" url="http://www.hiddenmemory.co.uk" }}
      {{# occupation }}Software Developer{{/ occupation }]
      {{# hobbies }}Kitesurfing, mountain biking{{/ hobbies }}
    {{/ person }}

would be parsed as follows:

 - block "person" (name = "Chris", url="http://www.hiddenmemory.co.uk")
    - block "occupation"
       - text "Software Developer"
    - block "hobbies"
       - text "Kitesurfing, mountain biking"

## Expansion

Once Tipi has parsed the document, it *expands* the DOM tree, invoking all the templates it can to produce the final document.

Expansion involves a pre-order walk of the tree within the context of an *environment* object. The environment stores any templates and template data that Tipi might need to process tags in the document:

 - Whenever Tipi encounters a *text* node, it echoes it straight to
   the output.

 - Whenever Tipi encounters a *block* node, it tries to find a template of
   the same name.

   If Tipi finds a matching template, it invokes it to expand the node,
   and then starts walking the resulting tree. If there isn't a matching
   template, Tipi leaves the block as-is and starts walking its children.

   In addition to expanding part of the tree, templates are also able to add
   new items to the environment. These new items are then available for Tipi
   to use when it is expanding later blocks in the tree.

## Rendering

After expansion, Tipi *renders* the final DOM tree by removing any remaining tags and returning the remaining text content.

# To do

Tipi is a work in progress.

#Other Versions

 - Objective-C - <https://github.com/hiddenmemory/Tipi/>
 - Scala - <https://github.com/davegurnell/tipi/>

# Licence

Copyright 2011-12 [Dave Gurnell] and [hiddenMemory]

All rights reserved.
 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 - Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 - Neither the name of the Tipi software nor the names of its contributors may
   be used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

# Acknowledgements

This product includes software developed by:

 - David Loren Parsons - <http://www.pell.portland.or.us/~orc>
 - Jonathan 'Wolf' Rentzsch - <https://github.com/rentzsch/markdownlive>


[Dave Gurnell]: http://boxandarrow.com
[Chris Ross]: http://darkrock.co.uk
[Untyped]: http://untyped.com
[hiddenMemory]: http://www.hiddenmemory.co.uk
[Mustache]: http://mustache.github.com