library tentacle_response_formatter.XmlConverter;
import 'package:xml/xml.dart';

class XmlConverter {

  String convert([dynamic data]) {
    XmlElement root = _createNode(new XmlElement('response'), data);
    return root.toString();
  }

  XmlElement _createNode(XmlElement parent, dynamic data) {
    if(data == null) return parent;

    if(data is String || data is num || data is bool) {
      parent.addChild(new XmlText(data.toString()));
      return parent;
    }

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

  static XmlConverter instance;
  XmlConverter._create();
}
