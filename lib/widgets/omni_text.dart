import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/default_color.dart';
import '../constants/style.dart';
import '../utils/helpers/language.dart';

class OmniText extends StatelessWidget {
  final String? text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final bool useTranslation;

  const OmniText({
    Key? key,
    this.text,
    this.size,
    this.color,
    this.weight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.useTranslation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Update language context
    Language.updateLanguageCode(context);
    
    final isEn = Language.currentLangCode == "en";
    final displayText = useTranslation && text != null ? text!.tr() : (text ?? '');
    
    final baseTextStyle = TextStyle(
      height: 1.6,
      fontSize: size ?? 15.2,
      color: color ?? DefaultColor.text,
      fontWeight: weight ?? FontWeight.normal,
      fontFamily: isEn ? Constant.enFont : Constant.khmerFont,
      overflow: overflow,
    );

    if (!isEn && displayText.isNotEmpty && displayText.contains('\n')) {
      final parts = displayText.split('\n');
      return Column(
        crossAxisAlignment: _getCrossAxisAlignment(textAlign),
        mainAxisSize: MainAxisSize.min,
        children: parts.map((part) => Text(
              part,
              textAlign: textAlign,
              maxLines: maxLines,
              softWrap: softWrap,
              style: baseTextStyle,
            )).toList(),
      );
    }

    return Text(
      displayText,
      textAlign: textAlign ?? TextAlign.left,
      maxLines: maxLines,
      softWrap: softWrap,
      style: baseTextStyle,
    );
  }

  CrossAxisAlignment _getCrossAxisAlignment(TextAlign? textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      case TextAlign.start:
      case TextAlign.left:
      case TextAlign.justify:
      default:
        return CrossAxisAlignment.start;
    }
  }
}

class OmniNumberText extends StatelessWidget {
  final String? text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const OmniNumberText({
    Key? key,
    this.text,
    this.size,
    this.color,
    this.weight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Language.updateLanguageCode(context);
    final isEn = Language.currentLangCode == "en";
    
    return Text(
      text ?? '',
      textAlign: textAlign ?? TextAlign.left,
      maxLines: maxLines,
      style: TextStyle(
        height: 1.6,
        fontSize: size ?? 15.2,
        color: color ?? DefaultColor.text,
        fontWeight: weight ?? FontWeight.normal,
        fontFamily: isEn ? Constant.enFont : Constant.enFont,
        overflow: overflow,
      ),
    );
  }
}
