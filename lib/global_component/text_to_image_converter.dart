import 'dart:async';
import 'dart:ui' as ui;
import 'package:ci_dong/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class TextToImageConverter {
  ///文本转换成图片
  static Future<Uint8List?> generateImage(
      BuildContext context, String text) async {
    // Create a RenderRepaintBoundary
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();

    // Get the FlutterView
    final FlutterView currentView = View.of(context);

    // Create a ViewConfiguration
    final ViewConfiguration viewConfiguration = ViewConfiguration(
      size: const Size(300, 300), // Set an appropriate size for your content
      devicePixelRatio: currentView.devicePixelRatio,
    );

    // Create a RenderView and specify the view field
    final RenderView renderView = RenderView(
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: boundary,
      ),
      configuration: viewConfiguration,
      view: currentView,
    );

    // Create a PipelineOwner and attach the RenderView to it
    final PipelineOwner pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;

    // Create a new build owner
    // final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    // Attach the RenderView to the render tree
    renderView.prepareInitialFrame();

    // Create the text box and attach to the repaint boundary
    final RenderBox textBox = _createRenderBoxWithText(text);
    boundary.child = textBox;

    // Ensure the render tree is laid out and painted before capturing the image
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    try {
      // Convert boundary to Image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      appLogger.e("Error generating image: $e");
      return null;
    }
  }

  // Helper method to create a RenderBox with the Text content
  static RenderBox _createRenderBoxWithText(String text) {
    final TextSpan span = TextSpan(
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Color(0xFF052D84),
      ),
      text: text,
    );

    final TextPainter textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final RenderBox textBox = RenderDecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: RenderConstrainedBox(
        additionalConstraints: BoxConstraints(
          minWidth: textPainter.width,
          minHeight: textPainter.height,
        ),
        child: RenderParagraph(
          span,
          textDirection: TextDirection.ltr,
        ),
      ),
    );

    return textBox;
  }
}
