import 'dart:core';

import 'package:hipsters_ponto_tech/webfeed_modified/rss_category.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/rss_cloud.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/rss_image.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/rss_item.dart';
import 'package:hipsters_ponto_tech/webfeed_modified/util/helpers.dart';
import 'package:xml/xml.dart';

class RssFeed {
  final String title;
  final String author;
  final String description;
  final String link;
  final List<RssItem> items;
  final RssImage image;
  final String lastBuildDate;
  final String language;
  final String generator;
  final String copyright;
  final String docs;
  final String managingEditor;
  final String rating;
  final String webMaster;
  final int ttl;

  RssFeed({
    this.title,
    this.author,
    this.description,
    this.link,
    this.items,
    this.image,
    this.lastBuildDate,
    this.language,
    this.generator,
    this.copyright,
    this.docs,
    this.managingEditor,
    this.rating,
    this.webMaster,
    this.ttl,
  });

  factory RssFeed.parse(String xmlString) {
    var document = parse(xmlString);
    XmlElement channelElement;
    try {
      channelElement = document.findAllElements("channel").first;
    } on StateError {
      throw ArgumentError("channel not found");
    }

    return RssFeed(
      title: findElementOrNull(channelElement, "title")?.text,
      author: findElementOrNull(channelElement, "author")?.text,
      description: findElementOrNull(channelElement, "description")?.text,
      link: findElementOrNull(channelElement, "link")?.text,
      items: channelElement.findElements("item").map((element) {
        return RssItem.parse(element);
      }).toList(),
      image: RssImage.parse(findElementOrNull(channelElement, "image")),
      lastBuildDate: findElementOrNull(channelElement, "lastBuildDate")?.text,
      language: findElementOrNull(channelElement, "language")?.text,
      generator: findElementOrNull(channelElement, "generator")?.text,
      copyright: findElementOrNull(channelElement, "copyright")?.text,
      docs: findElementOrNull(channelElement, "docs")?.text,
      managingEditor: findElementOrNull(channelElement, "managingEditor")?.text,
      rating: findElementOrNull(channelElement, "rating")?.text,
      webMaster: findElementOrNull(channelElement, "webMaster")?.text,
      ttl: int.tryParse(findElementOrNull(channelElement, "ttl")?.text ?? "0"),
    );
  }
}
