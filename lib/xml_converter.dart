library tentacle_response_formatter.XmlConverter;

import 'package:xml/xml.dart';

/**
 * Creates an XML String from a given simple data structure
 * consisting of [String], [num], [bool], [Map] and [List].
 * [Map] and [List] are iterated recursively all other types
 * are added as text nodes calling toString.
 */
class XmlConverter {

  /**
   * Convert method takes data a returns it as XML [String]
   */
  String convert([dynamic data]) {
    var buffer = new StringBuffer();
    toXml(data).writePrettyTo(buffer, 0, '   ');
    return buffer.toString();
  }

  /**
   * Converts given data into an [XmlElement].
   */
  XmlElement toXml([dynamic data]) {
    return new XmlElement(
        new XmlName('response'), const <XmlAttribute>[], _createNode(data));
  }

  // internal recursive converter
  List<XmlNode> _createNode(dynamic data) {
    if (data == null) return <XmlNode>[];

    if (data is Iterable) {
      return data
          .map((item) => new XmlElement(
              new XmlName('item'), const <XmlAttribute>[], _createNode(item)))
          .toList();
    }

    if (data is Map) {
      return data.keys
          .map((name) => new XmlElement(new XmlName(name),
              const <XmlAttribute>[], _createNode(data[name])))
          .toList();
    }

    return [new XmlText(data.toString())];
  }

  factory XmlConverter() {
    if (instance == null) {
      instance = new XmlConverter._create();
    }
    return instance;
  }

  // singleton instance
  static XmlConverter instance;
  XmlConverter._create();
}
