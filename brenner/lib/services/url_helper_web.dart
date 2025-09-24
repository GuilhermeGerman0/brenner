// lib/services/url_helper_web.dart
import 'dart:html' as html;

class UrlHelper {
  String getHost() => html.window.location.hostname ?? '';
  String getPort() => html.window.location.port ?? '';
  String getHash() => html.window.location.hash ?? '';
}