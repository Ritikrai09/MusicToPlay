import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/model/settings.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintainanceWidget extends StatelessWidget {
  const MaintainanceWidget({super.key,required this.value});
  final SettingModel value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
  child: SizedBox(
    
    width: size(context).width,
    child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(Img.logo,width: 100, height: 100),
            const TheLogo(width: 60,height: 60),
            const SizedBox(height: 24),
            Image.asset('asset/Images/Temp/maintain.png',width: 200,height: 200),
          Text(value.maintainanceTitle.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'QuickSand',
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
              value.maintainanceShortText
                  .toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'QuickSand',
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
                    const SizedBox(height: 32),
                  Button(
                    onTap:() async {
                      await launchUrl(Uri.parse("mailto:${allSettings.value.supportEmail}"));
                    },
                    tittle: "${allSettings.value.supportEmail}",
                      style: const TextStyle(
                          fontFamily: 'QuickSand',
                          fontSize: 16,
                          color: Colors.white,
                          // decorationColor:Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold
                        )
      
             ), const SizedBox(height: 12),
        ],
      ),
    ),
  ),
);
  }
}