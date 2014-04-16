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
    return toXml(data).toString();
  }

  /**
   * Converts given data into an [XmlElement].
   */
  XmlElement toXml([dynamic data]) {
    return _createNode(new XmlElement('response'), data);
  }

  // internal recursive converter
  XmlElement _createNode(XmlElement parent, dynamic data) {
    if(data == null) return parent;

    if(data is Iterable) {
      data.forEach((item) {
        var child = _createNode(new XmlElement('item'), item);
        parent.addChild(child);
      });
      return parent;
    }

    if(data is Map) {
      data.forEach((name, value) {
        parent.addChild(_createNode(new XmlElement(name), value));
      });
      return parent;
    }

    parent.addChild(new XmlText(data.toString()));
    return parent;
  }

  factory XmlConverter() {
    if(instance == null) {
      instance = new XmlConverter._create();
    }
    return instance;
  }

  // singleton instance
  static XmlConverter instance;
  XmlConverter._create();
}
