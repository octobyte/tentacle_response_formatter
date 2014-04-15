library tentacle_response_formatter.formatter;
import 'package:shelf/shelf.dart' as shelf;
import 'package:xml/xml.dart';
import 'dart:convert';

typedef String Formatter(dynamic data);

class ResponseFormatter {

  /**
   * Map of accept headers to response formats.
   */
  Map<String, String> acceptMappings = {
      "application/xml": "xml",
      "application/xhtml+xml": "xml",
      "text/html": "xml",
      "application/json": "json",
      "text/json": "json",
      "*/*": "text"
  };

  /**
   * Map of response formats to formatter functions.
   */
  Map<String, Formatter> formatterMappings = {
      "xml": xmlFormatter, "json": jsonFormatter, "text": textFormatter
  };

  /**
   * Singleton constructor
   */
  factory ResponseFormatter() {
    if(instance == null) {
      instance = new ResponseFormatter._create();
    }
    return instance;
  }

  // private constructor
  ResponseFormatter._create();
  static ResponseFormatter instance;

  /**
   *
   */
  String formatResponse(shelf.Request request, dynamic data) {
    var format = findTargetFormat(request);
    return formatterMappings[format](data);
  }

  /**
   * Given a [shelf.Request] this method tries to find the best format in which to
   * return the response body to the client. It first looks for a format param in
   * the requests query string (eg.: /path?format=json).
   *
   * If no query param is present or no [Formatter] could be found for the format
   * the method looks for a file extension with a known format (eg.: /path.xml).
   *
   * Lastly all the accept headers of the request are checked if one is present in
   * accept mappings.
   *
   * If no response formatter could be found the response format is switched to text.
   */
  String findTargetFormat(shelf.Request request) {
    String path = request.requestedUri.path;
    String queryFormat = request.requestedUri.queryParameters['format'];
    String acceptHeaders = request.headers['accept'];

    // from query string format param
    if(queryFormat != null && formatterMappings.containsKey(queryFormat)) {
      return queryFormat;
    }

    // from path file extension
    if(path.lastIndexOf('.') != -1 && path.lastIndexOf('.')+1 < path.length) {
      var fileFormat = path.substring(
          path.lastIndexOf('.')+1
      );
      if(formatterMappings.containsKey(fileFormat)) {
        return fileFormat;
      }
    }

    // from accept header
    List<String> accepts = _parseAcceptHeaders(request.headers['accept']);
    String accepted = accepts.firstWhere((accept) => acceptMappings.containsKey(accept));
    return acceptMappings[accepted];
  }

  /**
   * Parses the accept headers of a request into a String list.
   */
  List<String> _parseAcceptHeaders(String accepts) {
    if(!(accepts is String)) return ["*/*"];

    List<String> result = [];
    List<String> acceptList = accepts.split(',');

    acceptList.forEach((accept) {
      if(accept.contains(';q=')) {
        accept = accept.substring(0, accept.indexOf(';'));
      }
      result.add(accept);
    });
    if(result.length < 1) result.add("*/*");
    return result;
  }

}

/**
 * Encodes the response data as Json
 */
String jsonFormatter(data) {
  return JSON.encode(data);
}

/**
 *
 */
String xmlFormatter(data, [XmlElement el]) {
  XmlElement root = new XmlElement('response');

  if(data is Iterable) {
    data.forEach((item) {

    });
  }

  if(data is Map) {

  }



  return "<response/>";
}

XmlElement createChildNode(XmlElement node) {

}

/**
 * Simple fallback text formatter looking for a message field in the
 * response data.
 */
String textFormatter(data) {
  if(data is Map && data.containsKey("message")) {
    return data["message"];
  }
  return "";
}