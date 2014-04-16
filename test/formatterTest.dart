library tentacle_response_formatter.test.formatter;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:tentacle_response_formatter/formatter.dart';
import 'dart:convert';

void main() {

  String BASE_URL = "http://www.test.io";
  shelf.Request createShelfRequest(String method, String path, [Map<String, String>headers]) {
    Uri uri = Uri.parse(BASE_URL + path);
    if(headers == null) {
      headers = {'accept': '*/*'};
    }
    return new shelf.Request(method, uri, headers: headers);
  }

  ResponseFormatter formatter = new ResponseFormatter();

  shelf.Request defaultRequest = createShelfRequest('GET', '/asdf/qwer', {'Accept': 'audio/*; q=0.2, audio/basic'});
  shelf.Request strangeRequest = createShelfRequest('GET', '/asdf/qwer');
  shelf.Request queryFormatXml = createShelfRequest('GET', '/asdf/qwer?format=xml');
  shelf.Request queryFormatJson = createShelfRequest('GET', '/asdf/qwer?format=json');
  shelf.Request fileFormatXml = createShelfRequest('GET', '/asdf/qwer.xml');
  shelf.Request fileFormatJson = createShelfRequest('GET', '/asdf/qwer.json');
  shelf.Request chromeGetRequest = createShelfRequest('GET', '/asdf/qwer&format=xml', {'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'});


  group("formatResponse", () {
    test("is function", () {
      expect(formatter.formatResponse is Function, isTrue);
    });

    test("returns empty text message for nothing found", () {
      expect(formatter.formatResponse(defaultRequest, {}), equals(""));
    });

    test("returns text message from response data", () {
      expect(formatter.formatResponse(defaultRequest, {"message": "hello"}), equals("hello"));
    });

    test("returns json response from map data", () {
      var data = {"a":"b", "c":["a", "b", "c"]};
      var queryJsonString = formatter.formatResponse(queryFormatJson, data);
      var fileJsonString = formatter.formatResponse(fileFormatJson, data);
      expect(queryJsonString, equals(fileJsonString));
      expect(data, equals(JSON.decode(queryJsonString)));
    });

    test("returns json response from array", () {
      var data = [{"a": 1}, {"a": 2}, {"a": 3}];
      var queryJsonString = formatter.formatResponse(queryFormatJson, data);
      var fileJsonString = formatter.formatResponse(fileFormatJson, data);
      expect(queryJsonString, equals(fileJsonString));
      expect(data, equals(JSON.decode(queryJsonString)));
    });

    test("returns text response from strange request", () {
      expect(formatter.formatResponse(strangeRequest, null) is String, isTrue);
    });

  });

  group("findTargetFormat", () {

    test("is function", () {
      expect(formatter.findTargetFormat is Function, isTrue);
    });

    test("takes request and returns string", () {
      expect(formatter.findTargetFormat(defaultRequest) is String, isTrue);
    });

    test("returns xml from browser format query param", () {
      expect(formatter.findTargetFormat(queryFormatXml), equals("xml"));
    });

    test("returns json from browser format query param", () {
      expect(formatter.findTargetFormat(queryFormatJson), equals("json"));
    });

    test("returns text from no formatter for browser format query param", () {
      expect(formatter.findTargetFormat(defaultRequest), equals("text"));
    });

    test("returns json from url file extension .json", () {
      expect(formatter.findTargetFormat(fileFormatJson), equals("json"));
    });

    test("returns xml from url file extension .xml", () {
      expect(formatter.findTargetFormat(fileFormatXml), equals("xml"));
    });

    test("returns xml from browser accept header", () {
      expect(formatter.findTargetFormat(chromeGetRequest), equals("xml"));
    });

    test("returns text from strange audio request", () {
      expect(formatter.findTargetFormat(strangeRequest), equals("text"));
    });

  });

}