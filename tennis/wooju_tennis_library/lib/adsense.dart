import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class AdsenseAdWidget extends StatefulWidget {
  final String adSlotId;
  final double width;
  final double height;

  const AdsenseAdWidget({
    Key? key,
    required this.adSlotId,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<AdsenseAdWidget> createState() => _AdsenseAdWidgetState();
}

class _AdsenseAdWidgetState extends State<AdsenseAdWidget> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'adsense-ad-${DateTime.now().microsecondsSinceEpoch}';

    // HTML 요소 생성 및 등록
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final container = html.DivElement()
          ..id = _viewId
          ..style.width = '${widget.width}px'
          ..style.height = '${widget.height}px';

        final insElement = html.Element.tag('ins')
          ..className = 'adsbygoogle'
          ..style.display = 'block'
          ..style.width = '${widget.width}px'
          ..style.height = '${widget.height}px'
          // !!!! 게시자 ID 수정 !!!!
          ..setAttribute('data-ad-client', 'ca-pub-2598779635969436') // <- 실제 AdSense 게시자 ID로 교체 완료
          // !!!! 게시자 ID 수정 끝 !!!!
          ..setAttribute('data-ad-slot', widget.adSlotId) // 슬롯 ID는 위젯 매개변수로 받음
          ..setAttribute('data-ad-format', 'auto')
          ..setAttribute('data-full-width-responsive', 'true');

        container.append(insElement);

        // AdSense 코드 실행 (JS interop 사용)
        // 약간의 지연 후 push 실행 (DOM 요소가 완전히 준비된 후 실행하기 위함)
        js.context.callMethod('setTimeout', [
          js.allowInterop(() {
            try {
              // window.adsbygoogle 이 정의되어 있는지 확인 후 push 호출
              js.context['adsbygoogle'] = js.context['adsbygoogle'] ?? js.JsArray();
              (js.context['adsbygoogle'] as js.JsArray).callMethod('push', [js.JsObject.jsify({})]);
            } catch (e) {
              print('Error pushing adsbygoogle: $e');
            }
          }),
          300 // 약간의 지연 시간 (필요에 따라 조절)
        ]);

        return container;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}