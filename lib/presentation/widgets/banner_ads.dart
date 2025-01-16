import 'package:easy_audience_network/easy_audience_network.dart' as facebook;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as google;


class BannerAds extends StatefulWidget {
  const BannerAds({super.key, this.adUnitId = ''});

  final String adUnitId;

  @override
  State<BannerAds> createState() => _BannerAdsState();
}

class _BannerAdsState extends State<BannerAds> {
  late google.BannerAd myBanner;
  bool isBannerLoaded = false;

  @override
  void initState() {
      myBannerAd();
    super.initState();
  }

  void myBannerAd() async {
    myBanner = google.BannerAd(
      adUnitId: widget.adUnitId != '' ? widget.adUnitId : '',
      size: google.AdSize.banner,
      request: const google.AdRequest(),
      listener: google.BannerAdListener(onAdLoaded: (ad) {
        myBanner = ad as google.BannerAd;
        isBannerLoaded = true;
        setState(() {});
      }, onAdFailedToLoad: (ad, error) {
        setState(() {
          isBannerLoaded = false;
        });
        ad.dispose();
      }),
    );
    await myBanner.load();
  }

  @override
  void dispose() {
      myBanner.dispose();
      super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var size2 = MediaQuery.of(context).size;
    // var isDark = Theme.of(context).brightness == Brightness.dark;
    return isBannerLoaded
        ? Container(
            alignment: Alignment.center,
            width: size2.width,
            height: myBanner.size.height.toDouble(),
            color: Theme.of(context).cardColor,
            child: google.AdWidget(ad: myBanner)
          )
        : Container(
            width: size2.width,
            color: Theme.of(context).cardColor,
            alignment: Alignment.center,
            height: 40,
            child: const SizedBox(),
          );
  }
}



class FacebookAd extends StatefulWidget {
  const FacebookAd({super.key, this.adUnitId = ''});

  final String adUnitId;

  @override
  State<FacebookAd> createState() => _FacebookAdState();
}

class _FacebookAdState extends State<FacebookAd> {

  late Widget facebookAd;
  bool isBannerLoaded = false;

  @override
  void initState() {
 
    facebookAds();
    super.initState();
  }


   facebookAds() {
    facebookAd = facebook.BannerAd(
      placementId: "IMG_16_9_APP_INSTALL#${widget.adUnitId}", //testid
      bannerSize: facebook.BannerSize.STANDARD,
      keepAlive:true,
      listener: facebook.BannerAdListener(
          onError: (code, message) =>
              print('banner ad error\ncode: $code\nmessage:$message'),
          onLoaded: () {
            isBannerLoaded=true;
           setState(() { });
          },
        ),
     
    );
  }

  @override
  Widget build(BuildContext context) {
    var size2 = MediaQuery.of(context).size;
    // var isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
            alignment: Alignment.center,
            width: size2.width,
            height: 50,
            color: Theme.of(context).cardColor,
            child: isBannerLoaded
                ? facebookAd
                : const SizedBox(
                  child: Text('Facebook Ads',style: TextStyle(
                    fontSize: 16
                  )),
                ),
          );
        // : Container(
          //   width: size2.width,
          //   color: Theme.of(context).cardColor,
          //   alignment: Alignment.center,
          //   height: 40,
          //   child: const SizedBox(),
          // );
  }
}
