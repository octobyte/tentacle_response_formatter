## Shelf Response Formatter ##
A small class that, given a [shelf](http://pub.dartlang.org/packages/shelf)
request and some simple data, will determine a correct response format (eg.:
Json or XML) and convert the data to the appropriate format.

This package is a fork of [tentacle_response_formatter](https://pub.dartlang.org/packages/tentacle_response_formatter).

### How to use ###
```dart
// ResponseFormatter is a Singleton so you will always get the same instance
// with
new ResponseFormatter formatter = new ResponseFormatter();

// Create a result from a shelf.Request and data
FormatResult result = formatter.formatResponse(request, {"message": "hello"});

// Body contains the generated response as String
print(result.body) // -> '{"message":"hello"}' or
    '<response><message>hello</message></response>' or 'hello'

// contentType is a suggestion to set as the HttpHeaders.CONTENT_TYPE in the
// shelf.Response you create
print(result.contentType) // -> "application/json" or "application/xml" or "text/plain"
```

### How is the response format detected ###
There are currently 3 values that influence the response format detection. They
are applied in the following order:

1. Format query param: "http://example.com/some?format=json" would force the
response to be converted to Json.
2. Format file extension: "http://example.com/some.xml" would force the response
to be converted to XML.
3. Accept Header: "accept: application/json, text/xml" would force the response
to be converted to Json.

Accept headers are used in the order they are defined. So first format has
precedence over second and so forth.

If no format can be detected that has a valid encoder registered the response is
encoded as String. If data contains a message field it is taken for String
response otherwise the result will be an empty String. The string formatter is
not a real formatter but rather a fallback. Read later on how to add your own
formatter and register it for content types.

### Add your own response formatter ###
You may want to add your own formatters or content-type mappings to the
formatter. To do so you have to provide a formatter function which takes dynamic
data and returns a String. Furthermore you have to provide a unique name and may
provide your custom content-types that should be handled by your formatter.
```dart
// Add a simple formatter for csv
formatter.registerFormatter("csv", "text/csv", (dynamic data) {
  return "Your CSV result here";
});
// Now ?format=csv, file.csv and accept header "text/csv" are formatted using
// your formatter

// Override additional accept-headers
formatter.registerFormatter("allmighty", "text/allmighty", (dynamic data) {
      return "allmighty response body";
}, ["application/json", "application/xhtml+xml", "*/*", "text/plain", "application/xml"]);

// Replace existing formatter
formatter.registerFormatter("json", "application/json", (dynamic data) {
  return "Your json result here";
});
// Json is now handled by your formatter including all accept-headers json was
// initially registered for
```

### License ###
Apache 2.0
