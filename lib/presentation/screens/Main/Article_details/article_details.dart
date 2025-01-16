import 'dart:io';
import 'dart:typed_data';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_audience_network/ad/interstitial_ad.dart' as facebook;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as google;
import 'package:html/parser.dart';
import 'package:just_audio/just_audio.dart' as just;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:blogit/Extensions/extension.dart';
import 'package:blogit/Utils/app_theme.dart';
import 'package:blogit/Utils/caurosal.dart';
import 'package:blogit/Utils/screen_timeout_display.dart';
import 'package:blogit/Utils/shimmer.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/main.dart';
import 'package:blogit/presentation/screens/Main/Home/Home_compo/trending_story.dart';
import 'package:blogit/presentation/screens/Settings/Setting_main/settings.dart';
import 'package:blogit/presentation/screens/fullscreen.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/presentation/screens/web_view.dart';
import 'package:blogit/presentation/widgets/loader.dart';
import 'package:blogit/presentation/widgets/nav_util.dart';
import 'package:blogit/presentation/widgets/text.dart';
import 'package:blogit/presentation/widgets/widgets.dart';

import '../../../../Utils/custom_toast.dart';
import '../../../../Utils/deep_link.dart';
import '../../../../Utils/tts.dart';
import '../../../../controller/repository.dart';
import '../../../../controller/user_controller.dart';
import '../../../../model/blog.dart';
import '../../../../model/comment.dart';
import '../../../widgets/banner_ads.dart';
import '../../../widgets/incite_video_player.dart';
import '../../../widgets/poll.dart';
import '../../../widgets/scrollable.dart';
import '../../Auth/Login/login.dart';
import '../../bookmarks.dart';
import '../Shared_component/comment_tile.dart';
import '../Shared_component/video_tile.dart';

enum TtsState { playing, stopped, paused, continued }

class ArticleDetails extends StatefulWidget {
  const ArticleDetails(
      {super.key,
      this.type,
      this.initial = false,
      required this.likes,
      this.action,
      this.index = 0,
      required this.blog,
      this.isCommentScroll = false});
  final Blog blog;
  final BlogAction? action;
  final int index;
  final BlogType? type;
  final String likes;
  final bool isCommentScroll, initial;

  @override
  _ArticleDetailsState createState() => _ArticleDetailsState();
}

class _ArticleDetailsState extends State<ArticleDetails>
    with WidgetsBindingObserver {
  TextEditingController controller = TextEditingController();

  bool isPostLoad = false;
  CommentModel comments = CommentModel();
  bool loadComments = currentUser.value.id != null ? true : false;
  final audioPlayer = AudioPlayer();
  just.AudioPlayer audioPlay = just.AudioPlayer();
  ScrollController scroll = ScrollController();

  bool load = false;
  late DateTime blogStartTime;
  bool isVolume = false;
  late Blog blog;
  late bool isTopPanel;

  GlobalKey commentKey = GlobalKey();

  google.InterstitialAd? _interstitialAd;

  bool isInterstialLoaded = false;

  final bool _isInterstitialAdLoaded = false;

  @override
  void initState() {
    blog = widget.blog;
    readOnly = widget.isCommentScroll == false;
    WidgetsBinding.instance.addObserver(this);
    blogStartTime = DateTime.now();

    ttsData = {"id": blog.id, "start_time": "", "end_time": ""};

    isTopPanel = widget.isCommentScroll;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // var isYoutube = (blog.videoUrl != null && blog.videoUrl!.isNotEmpty && (
      // widget.blog.videoUrl!.contains('youtube') || widget.blog.videoUrl!.contains('youtu.be') ));

      if (widget.blog.videoUrl != null && widget.blog.videoUrl!.isNotEmpty) {
        if (Platform.isAndroid) {
          ScreenTimeout().enableScreenAwake();
        }
        //  videocontroller = (isYoutube == true ?
        //  await CacheVideoController().playYoutubeVideo(url: widget.blog.videoUrl ?? "")
        // : VideoPlayerController.networkUrl(Uri.parse(widget.blog.videoUrl ?? ""))..initialize());
        //  setState(() {  });
      }
      if (Platform.isIOS) {
        await flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.ambient,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers
            ],
            IosTextToSpeechAudioMode.voicePrompt);
        await flutterTts.awaitSynthCompletion(true);
      }
      var provider = Provider.of<AppProvider>(context, listen: false);
      if (widget.action != null && widget.action == BlogAction.share) {
        ///WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
        await createDynamicLink(blog).then((value) async {
          Share.share("${allMessages.value.shareMessage} $value");
          provider.addShareData(null, blog.id as int);
        });
      }
      //   if(widget.initial == true){
      //     await blogDetail(blog.id.toString()).then((value) {
      //     blog = value;
      //     setState(() { });
      //   });
      //  }
      initTTS(provider);
      provider.addAdFrequency(1);
      // setState(() { });

      if (_isInterstitialAdLoaded == true &&
          allSettings.value.enableFbAds != '0' &&
          provider.adFrequency +
                  int.parse(allSettings.value.fbAdsFrequency.toString()) %
                      int.parse(allSettings.value.fbAdsFrequency.toString()) ==
              0) {
        facebook.InterstitialAd(
          Platform.isIOS == true
              ? allSettings.value.fbInterstitialIdIos ?? ''
              : allSettings.value.fbInterstitialIdAndroid ?? "",
        ).load();
        //setState(() {});
      } else {
        // debugPrint("Interstial Ad not yet loaded!");
      }

      if (provider.adFrequency %
              int.parse(allSettings.value.admobFrequency.toString() == '0'
                  ? '1'
                  : allSettings.value.admobFrequency.toString()) ==
          0) {
        createInterstitialAd(provider);
      }
      // if (widget.isCommentScroll==true) {
      //  focuscomment.addListener(() async{
      //  if (scroll.hasClients && focuscomment.hasFocus){
      //       scrollCommentPosition();
      //     }
      // });
      // }

      if (scroll.hasClients && widget.isCommentScroll == true) {
        scrollCommentPosition();
      }
      scroll.addListener(() {
        if (scroll.hasClients && isTopPanel == false && scroll.offset > 190) {
          setState(() {
            isTopPanel = true;
          });
        }
        if (scroll.hasClients && scroll.offset < 190) {
          if (isTopPanel == true) {
            setState(() {
              isTopPanel = false;
            });
          }
        }
      });
      provider.addviewData(blog.id!.toInt());
      if (currentUser.value.id != null) {
        await getComment(blog.id!.toInt()).then((value) {
          if (value != null) {
            loadComments = false;
            blog.comments = value;
            setState(() {});
          }
        }).onError((e, r) {
          loadComments = false;
          setState(() {});
        });
      }
      if (widget.action != null && widget.action == BlogAction.bookmark) {
        if (currentUser.value.id != null) {
          if (!provider.permanentIds.contains(blog.id)) {
            showCustomToast(
                context, allMessages.value.bookmarkSave ?? 'Bookmark Saved');
            provider.addBookmarkData(blog.id!.toInt());
          } else {
            showCustomToast(context,
                allMessages.value.bookmarkRemove ?? 'Bookmark Removed');
            provider.removeBookmarkData(blog.id!.toInt());
          }
          provider.setBookmark(blog: blog);
        } else {
          Navigator.pushNamed(context, '/LoginPage');
        }
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void deactivate() {
    if (widget.blog.videoUrl != null && widget.blog.videoUrl!.isNotEmpty) {
      ScreenTimeout().disableScreenAwake();
    }
    super.deactivate();
  }

  void scrollCommentPosition() {
    scroll.position
        .ensureVisible(commentKey.currentContext!.findRenderObject()!);
    Future.delayed(const Duration(milliseconds: 400), () {
      scroll.jumpTo(scroll.position.maxScrollExtent);
    });
  }

  Orientation orientation = Orientation.portrait;
  int presIndex = 0;
  String startTime = '';
  late Map<String, dynamic> ttsData;
  var ttsState;
  Uint8List? audioLoad;
  FlutterTts flutterTts = FlutterTts();
  FocusNode focuscomment = FocusNode();
  late bool readOnly;
  AppinioSocialShare appinioSocialShare = AppinioSocialShare();
  Future<Uint8List?> speech(String text) async {
    final response = await generateSpeech(
        text, blog.accentCode.toString(), 'en-GB-Neural2-A');
    setState(() {
      audioLoad = response;
      blog.audioData = audioLoad;
    });
    return audioLoad;
    // playLocal(data);
  }

  Future<void> setSpeechRate(double rate) async {
    await flutterTts
        .setSpeechRate(rate); // Set the speech rate using the FlutterTts plugin
  }

  Future createInterstitialAd(AppProvider proivder) async {
    // 'ca-app-pub-3940256099942544/1033173712'
    //  'ca-app-pub-3940256099942544/4411468910'
    allSettings.value.enableAds != '1'
        ? null
        : google.InterstitialAd.load(
            adUnitId: Platform.isAndroid
                ? allSettings.value.admobInterstitialIdAndroid ?? ''
                : allSettings.value.admobInterstitialIdIos ?? '',
            request: const google.AdRequest(),
            adLoadCallback: google.InterstitialAdLoadCallback(
              onAdLoaded: (google.InterstitialAd ad) {
                // Keep a reference to the ad so you can show it later.
                isInterstialLoaded = true;
                _interstitialAd = ad;
                _interstitialAd!.show();
                proivder.setAdFrequency(0);
                setState(() {});
              },
              onAdFailedToLoad: (google.LoadAdError error) {
                isInterstialLoaded = false;
                _interstitialAd!.dispose();
                setState(() {});
                // debugPrint('InterstitialAd failed to load: $error');
              },
            ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is resumed and visible
        break;
      case AppLifecycleState.inactive:
        // App is inactive and not receiving user input
        break;
      case AppLifecycleState.paused:
        stops();
        break;
      case AppLifecycleState.detached:
        // App is detached from any host and all resources have been released
        break;
      case AppLifecycleState.hidden:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  Future playLocal(Uint8List audioData) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (Platform.isAndroid) {
      Source source = BytesSource(audioData);
      audioPlayer.setPlaybackRate(0.833);
      await audioPlayer.play(
        source,
        volume: 1.0,
        mode: PlayerMode.mediaPlayer,
      );
    } else {
      playLocalAudio(audioData);
    }
  }

  Future<void> playLocalAudio(Uint8List tts) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = "${appDocDir.path}/tts_audio.wav";
    //  final files = await getCurrentUrl(filePath);
    final file = File.fromUri(Uri.parse(filePath));
    await file.writeAsBytes(tts);
    just.AudioSource source = just.AudioSource.file(file.path);
    await audioPlay.setAudioSource(source);
    await audioPlay.setSpeed(0.3);
    await Future.delayed(const Duration(milliseconds: 100));
    if (file.existsSync()) {
      await audioPlay.play();
    } else {
      // print('file not exists');
    }
  }

  UrlSource urlSourceFromBytes(Uint8List bytes,
      {String mimeType = "audio/wav"}) {
    return UrlSource(Uri.dataFromBytes(bytes, mimeType: mimeType).toString());
  }

  void stops() {
    setState(() {
      isVolume = false;
    });
    if (Platform.isIOS) {
      audioPlay.stop();
    } else {
      audioPlayer.stop();
    }
  }

  Future<void> init(String text, provider) async {
    bool isLanguageFound = false;
    var filterText = text.replaceAll(RegExp(r'[^\w\s,.]'), '');
    flutterTts.getLanguages.then((value) async {
      Iterable it = value;

      for (var element in it) {
        if (element.toString().contains(blog.accentCode.toString())) {
          flutterTts.setLanguage(element);
          flutterTts.setVoice(element);
          setSpeechRate(0.33);
          _playVoice(filterText, provider);
          isLanguageFound = true;
        }
      }
    });

    if (!isLanguageFound) {
      _playVoice(filterText, provider);
    }
  }

  void audioListener(AppProvider provider) {
    audioPlayer.onPlayerStateChanged.listen(
      (it) {
        switch (it) {
          case PlayerState.completed:
            setState(() {
              isVolume = false;
              var endTime = DateTime.now().toIso8601String();
              ttsData = {
                "id": blog.id,
                "start_time": startTime,
                "end_time": endTime
              };
              provider.addTtsData(
                  ttsData['id'], ttsData['start_time'], ttsData['end_time']);
            });
            break;
          default:
            break;
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ttsState == TtsState.stopped) {
        setState(() {
          isVolume = false;
        });
      }
      //  audioPlayer.onPlayerStateChanged.listen(
      //     (it) {
      //       switch (it) {
      //         case PlayerState.stopped:
      //           break;
      //         case PlayerState.completed:
      //           isVolume = true;
      //           setState(() {  });
      //           break;
      //         default:
      //           break;
      //       }
      //     },
      //);
    });
    super.didChangeDependencies();
  }

  _playVoice(text, provider) async {
    setState(() {
      ttsState == TtsState.playing;
      flutterTts.speak(text).then((value) {
        initTTS(provider);
      });

      isVolume = true;
    });
  }

  Future<void> initTTS(provider) async {
    flutterTts = FlutterTts();

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      stop();
      var endTime = DateTime.now().toIso8601String();
      ttsData = {"id": blog.id, "start_time": startTime, "end_time": endTime};
      provider!.addTtsData(
          ttsData['id'], ttsData['start_time'], ttsData['end_time']);
      setState(() {});
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        ttsState = TtsState.continued;
      });
    });

// Replace all occurrences of the comma with an empty string
  }

  Future stop() async {
    setState(() {
      ttsState == TtsState.stopped;
      flutterTts.stop();
      isVolume = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioPlayer.stop();
    if (Platform.isIOS) {
      audioPlay.stop();
    }
    if (widget.blog.videoUrl != null && widget.blog.videoUrl!.isNotEmpty) {
      ScreenTimeout().disableScreenAwake();
    }
    super.dispose();
  }

  String endTime = '';
  
  var startVideoAt = 0;

  @override
  Widget build(BuildContext context) {
    //  orientation = MediaQuery.of(context).orientation;
    var provider = Provider.of<AppProvider>(context, listen: false);
    var blogs2 = provider
        .blog!
        .categories![provider.categories.indexOf(blog.categoryName.toString())]
        .data!
        .blogs;
    var allNews = provider.allNewsBlogs;
    var myFeed = provider.feedBlogs;
    // var countLikes = provider.permanentlikesIds.contains(blog.id) ? blog.likes!.toInt()
    //       : blog.likes != null ? blog.likes!.toInt()-1 : 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomLoader(
        isLoading: load,
        child: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return SizedBox(
                height: size(context).height,
                width: size(context).width,
                child: yotubeplayer(context));
          } else {
            return SafeArea(
              top: blog.videoUrl != '' ? true : false,
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: scroll,
                    physics: orientation == Orientation.landscape
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    slivers: blog.title == null && blog.description == null
                        ? [
                            const SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  ShimmerLoader(
                                    count: 3,
                                  ),
                                ],
                              ),
                            )
                          ]
                        : [
                            SliverAppBar(
                              automaticallyImplyLeading: false,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              pinned: true,
                              elevation: 0,
                              scrolledUnderElevation: 0,
                              floating: blog.videoUrl != '' ? true : false,
                              flexibleSpace: FlexibleSpaceBar(
                                background: yotubeplayer(context),
                              ),
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: BackbUT(
                                    color: isTopPanel && dark(context) == false
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              actions: [
                                orientation == Orientation.landscape
                                    ? const SizedBox()
                                    : isTopPanel
                                        ? SizedBox(
                                            width: size(context).width / 2,
                                            child: iconpanel(
                                                context,
                                                provider,
                                                int.parse(
                                                    likeVisible(blog, provider)
                                                        .toString()),
                                                isDate: false))
                                        : const SizedBox(),
                                const SizedBox(width: 20)
                              ],
                              expandedHeight: blog.videoUrl != ''
                                  ? orientation == Orientation.landscape
                                      ? size(context).height
                                      : size(context).height * 0.27
                                  : blog.videoUrl != ''
                                      ? size(context).height * 0.27
                                      : size(context).width / 1.5,
                            ),
                            // SliverToBoxAdapter(
                            //   child: Row(
                            //     children: [

                            //     ],
                            //   ),
                            // ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 20.h),
                              sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                if (isTopPanel == false)
                                  iconpanel(
                                      context,
                                      provider,
                                      int.parse(likeVisible(blog, provider)
                                          .toString())),
                                SpaceUtils.ks12.height(),
                                Text(
                                  blog.title ??
                                      'Short Story is a Piece \nof Prose Fiction',
                                  style: FontStyleUtilities.h4(context,
                                      fontWeight: FWT.extrabold),
                                ),
                                SizedBox(
                                  height: 16.h,
                                ),
                              ])),
                            ),
                            SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 20.h),
                                sliver: SliverToBoxAdapter(
                                  child: Description(
                                      model: blog,
                                      // isExpanded: true,
                                      key: ValueKey("${blog.title}${blog.id}"),
                                      isVideoIncluded: true),
                                )),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 20.h),
                              sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                // SpaceUtils.ks30.height(),

                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 24.h, bottom: 12.h),
                                  child: Row(
                                    children: [
                                      InkResponse(
                                          radius: 22,
                                          onTap: () async {
                                            // if (await canLaunchUrl(Uri.parse('twitter://post?message=hello%20world')) ) {
                                            //   launchUrl(Uri.parse('twitter://post?message=hello%20world'));
                                            // } else {
                                            //    launchUrl(Uri.parse('market://details?id=com.twitter.android'));
                                            // }
                                            await intenUrlShare(context);
                                            provider.addShareData(
                                                ShareType.twitter,
                                                blog.id as int);
                                          },
                                          child: const SvgIcon(
                                            'asset/Images/Social/twitter.svg',
                                          )),
                                      SpaceUtils.ks16.width(),
                                      InkResponse(
                                          radius: 22,
                                          onTap: () async {
                                            intenUrlShareTelegram(context);
                                            provider.addShareData(
                                                ShareType.telegram,
                                                blog.id as int);
                                            // var url ='linkedin://';

                                            //     // Encode the text as a query parameter to pass to the LinkedIn app
                                            //     String encodedText = Uri.encodeComponent(url);
                                            //     url += "shareArticle?mini=true&title=${blog.title}";

                                            // if (await canLaunchUrl(Uri.parse('linkedin://')) ) {
                                            //   launchUrl(Uri.parse('linkedin://'));
                                            // } else {
                                            //   print('error to rediect');
                                            // }
                                          },
                                          child: const SvgIcon(
                                              'asset/Images/Social/telegram.svg',
                                              width: 30,
                                              height: 30)),
                                      SpaceUtils.ks16.width(),
                                      InkResponse(
                                          radius: 22,
                                          onTap: () async {
                                            intenUrlShareWhatsapp(context);
                                            provider.addShareData(
                                                ShareType.whatsapp,
                                                blog.id as int);
                                            // if (await canLaunchUrl(Uri.parse('whatsapp://send?text=${allMessages.value.shareMessage}')) ) {
                                            //   launchUrl(Uri.parse('whatsapp://send?text=${allMessages.value.shareMessage}'));
                                            // } else {
                                            //   print('error to rediect');
                                            // }
                                          },
                                          child: const SvgIcon(
                                              'asset/Images/Social/whats-app.svg')),
                                      SpaceUtils.ks16.width(),
                                      InkResponse(
                                          radius: 22,
                                          onTap: () async {
                                            intenUrlShareSMS(context);
                                            provider.addShareData(
                                                ShareType.mail, blog.id as int);
                                          },
                                          child: const SvgIcon(
                                              'asset/Images/Social/mail.svg')),
                                      SpaceUtils.ks16.width(),
                                      InkResponse(
                                          onTap: () async {
                                            createDynamicLink(blog)
                                                .then((value) async {
                                              Share.share(
                                                  "${allMessages.value.shareMessage} $value");
                                              provider.addShareData(
                                                  null, blog.id as int);
                                            });
                                          },
                                          radius: 24,
                                          child: Icon(
                                            Icons.share,
                                            size: 24,
                                            color: dark(context)
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      SpaceUtils.ks12.width(),
                                    ],
                                  ),
                                ),
                              ])),
                            ),

                            SliverPadding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                SizedBox(
                                  height: 16.h,
                                ),
                                blog.sourceLink == ''
                                    ? const SizedBox()
                                    : GestureDetector(
                                        ///radius: 22,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      CustomWebView(
                                                          url: blog.sourceLink
                                                              .toString())));
                                        },
                                        child: SizedBox(
                                          // decoration: BoxDecoration(
                                          //   border: Border(bottom: BorderSide(width: 1,color: appThemeModel.value.primaryColor.value))
                                          // ),
                                          child: Row(
                                            children: [
                                              Text(
                                                allMessages.value.source ??
                                                    'Source : ',
                                                style: FontStyleUtilities.t1(
                                                        context,
                                                        fontWeight:
                                                            FWT.semiBold)
                                                    .copyWith(),
                                              ),
                                              Text(
                                                '${blog.sourceName}',
                                                style: FontStyleUtilities.t1(
                                                        context,
                                                        fontWeight:
                                                            FWT.semiBold,
                                                        fontColor:
                                                            Theme.of(context)
                                                                .primaryColor)
                                                    .copyWith(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            Theme.of(context)
                                                                .primaryColor),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                if (blog.sourceLink != null &&
                                    blog.sourceLink!.isNotEmpty)
                                  SizedBox(
                                    height: 24.h,
                                  ),
                              ])),
                            ),
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  blog.question != null &&
                                          blog.isVotingEnable == 1
                                      ? BlogPoll(
                                          onChanged: (value) {},
                                          pollKey: GlobalKey(),
                                          model: blog)
                                      : const SizedBox(),
                                  if (blog.question != null &&
                                      blog.isVotingEnable == 1)
                                    SizedBox(height: 28.h),
                                ],
                              ),
                              // SignalOutlinedButton(tittle: 'Show This Article', onTap: () {}),
                            ),
                            // const SliverToBoxAdapter(
                            //   child: Divider(
                            //     height: 1,
                            //   ),
                            // ),

                            SliverToBoxAdapter(
                              child: Container(
                                width: size(context).width,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((widget.index > 0 &&
                                            widget.type == BlogType.feed) ||
                                        (widget.index > 0 &&
                                            widget.type == BlogType.category) ||
                                        (widget.index > 0 &&
                                            widget.type == BlogType.allnews))
                                      Expanded(
                                        flex: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            // Navigator.pop(context);
                                            NavigationUtil.to(
                                                context,
                                                ArticleDetails(
                                                    blog: widget.type ==
                                                            BlogType.feed
                                                        ? myFeed[
                                                            widget.index - 1]
                                                        : widget.type ==
                                                                BlogType.allnews
                                                            ? allNews[
                                                                widget.index -
                                                                    1]
                                                            : blogs2[
                                                                widget.index -
                                                                    1],
                                                    type: widget.type,
                                                    index: widget.index - 1,
                                                    likes: likeVisible(
                                                            blog, provider) ??
                                                        "0"));
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons
                                                      .chevron_left_rounded),
                                                  Text(
                                                      allMessages.value
                                                              .previousArticle ??
                                                          "",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                          )),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 6.0),
                                                  child: Text(
                                                      widget.type ==
                                                              BlogType.feed
                                                          ? myFeed[widget.index - 1]
                                                                  .title ??
                                                              ""
                                                          : widget.type ==
                                                                  BlogType
                                                                      .allnews
                                                              ? allNews[widget.index - 1]
                                                                      .title ??
                                                                  ""
                                                              : blogs2[widget.index -
                                                                          1]
                                                                      .title ??
                                                                  "",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    if ((widget.index < myFeed.length - 1 &&
                                            widget.type == BlogType.feed) ||
                                        (widget.index < blogs2.length - 1 &&
                                            widget.type == BlogType.category) ||
                                        (widget.index < allNews.length - 1 &&
                                            widget.type == BlogType.allnews))
                                      Expanded(
                                        flex: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            NavigationUtil.to(
                                                context,
                                                ArticleDetails(
                                                    blog: widget.type ==
                                                            BlogType.feed
                                                        ? myFeed[
                                                            widget.index + 1]
                                                        : widget.type ==
                                                                BlogType.allnews
                                                            ? allNews[
                                                                widget.index +
                                                                    1]
                                                            : blogs2[
                                                                widget.index +
                                                                    1],
                                                    type: widget.type,
                                                    index: widget.index + 1,
                                                    likes: likeVisible(
                                                            blog, provider) ??
                                                        "0"));
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                        allMessages.value
                                                                .nextArticle ??
                                                            "",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall!
                                                            .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                            )),
                                                    const Icon(Icons
                                                        .chevron_right_rounded),
                                                  ]),
                                              const SizedBox(height: 4),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 6.0),
                                                child: Text(
                                                    widget.type == BlogType.feed
                                                        ? myFeed[widget.index +
                                                                    1]
                                                                .title ??
                                                            ""
                                                        : widget.type ==
                                                                BlogType.allnews
                                                            ? allNews[widget
                                                                            .index +
                                                                        1]
                                                                    .title ??
                                                                ""
                                                            : blogs2[widget.index +
                                                                        1]
                                                                    .title ??
                                                                "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.end,
                                                    maxLines: 2,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (provider.blog != null &&
                                provider.blog!.categories != null &&
                                provider
                                        .blog!
                                        .categories![provider.categories
                                            .indexOf(
                                                blog.categoryName.toString())]
                                        .data!
                                        .blogs
                                        .length >
                                    1)
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  SizedBox(height: 12.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                    ),
                                    child: Text(
                                      allMessages.value.youmightalso ??
                                          'You might also like',
                                      style: FontStyleUtilities.h6(context,
                                          fontWeight: FWT.extrabold),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  SizedBox(
                                    width: size(context).width,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          SpaceUtils.ks20.width(),
                                          ...blogs2.map((e) {
                                            if (e.id == blog.id) {
                                              return const SizedBox();
                                            } else if (e.type == "quote") {
                                              return const SizedBox();
                                            } else {
                                              return VideosCard(
                                                  key: ValueKey(e.id), blog: e);
                                            }
                                          })

                                          //  Expanded(child: VideosCard(blog: provider.blog!.categories![provider.categories.indexOf(blog.categoryName)].data!.blogs[0])),
                                          //   SpaceUtils.ks16.width(),
                                          //  Expanded(child: VideosCard(blog : provider.blog!.categories![provider.categories.indexOf(blog.categoryName)].data!.blogs[1])),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24.h,
                                  ),
                                ]),
                              )
                            else
                              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                            loadComments
                                ? SliverToBoxAdapter(
                                    child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 5,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ))
                                : SliverPadding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    sliver: SliverList(
                                        key: ValueKey(blog.comments != null &&
                                                blog.comments!.data != null
                                            ? blog.comments!.data!.length
                                            : 21111),
                                        delegate: SliverChildListDelegate((blog
                                                            .comments ==
                                                        null ||
                                                    blog.comments!.data!
                                                        .isEmpty) &&
                                                loadComments == true
                                            ? [
                                                // Text(
                                                //   allMessages.value.commentHeader  ??  'Comments',
                                                //   style: FontStyleUtilities.h6(context,
                                                //       fontWeight: FWT.extrabold),
                                                // ),
                                                // SizedBox(
                                                //   height: 200,
                                                //   width: size(context).width,
                                                //   child: Center(child:  Column(
                                                //     mainAxisAlignment : MainAxisAlignment.center,
                                                //     children: [
                                                //       Icon(Icons.info_outline_rounded,
                                                //       color: dark(context) ? Colors.grey.shade300 : Colors.grey.shade400,size: 40),
                                                //       const SizedBox(height: 4),
                                                //       Text(  currentUser.value.id== null ?
                                                //     allMessages.value.pleaseloginComment  ??  'Please login to see comments' :
                                                //       allMessages.value.nocommentYet  ?? 'No Comments yet.',
                                                //      style: TextStyle(fontWeight: FontWeight.w600,
                                                //      color: dark(context) ? Colors.grey.shade300 : Colors.grey.shade500)),
                                                //       if(currentUser.value.id== null )
                                                //       const SizedBox(height:12),
                                                //     if(currentUser.value.id== null )
                                                //     TextButt(
                                                //       onTap: (){
                                                //         NavigationUtil.to(context,const Login());
                                                //       },
                                                //       text: allMessages.value.login ?? 'Login',
                                                //      )
                                                //     ],
                                                //   )))
                                              ]
                                            : [
                                                Builder(
                                                    key: ValueKey(
                                                        blog.comments != null
                                                            ? blog.comments!
                                                                .data!.length
                                                            : []),
                                                    builder: (context) {
                                                      return Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            allMessages.value
                                                                    .commentHeader ??
                                                                'Comments',
                                                            style: FontStyleUtilities.h6(
                                                                context,
                                                                fontWeight: FWT
                                                                    .extrabold),
                                                          ),
                                                          const Spacer(),
                                                        ],
                                                      );
                                                    }),
                                                SpaceUtils.ks16.height(),
                                                if (blog.comments != null)
                                                  ...blog.comments!.data!
                                                      .take(3)
                                                      .map((e) => CommentsTile(
                                                          key: ValueKey(e),
                                                          comments: e,
                                                          onChanged: (value) {
                                                            if (blog
                                                                .comments!.data!
                                                                .contains(
                                                                    value)) {
                                                              presIndex = blog
                                                                  .comments!
                                                                  .data!
                                                                  .indexOf(
                                                                      value);
                                                              blog.comments!
                                                                  .data!
                                                                  .remove(
                                                                      value);
                                                              setState(() {});
                                                            } else {
                                                              blog.comments!
                                                                  .data!
                                                                  .insert(
                                                                      presIndex,
                                                                      value);
                                                              setState(() {});
                                                            }
                                                          })),
                                                if (blog.comments != null &&
                                                    blog.comments!.data !=
                                                        null &&
                                                    blog.comments!.data!
                                                        .isNotEmpty &&
                                                    blog.comments!.data!
                                                            .length >
                                                        3)
                                                  InkWell(
                                                    onTap: () async {
                                                      await commentPage(
                                                          context, blog,
                                                          (val) async {
                                                        if (val != null) {
                                                          // Navigator.pop(context,true);
                                                          if (val == 'add') {
                                                            loadComments = true;
                                                            setState(() {});
                                                            await setComment(
                                                                    blog
                                                                            .comments!
                                                                            .data!
                                                                            .last
                                                                            .comment ??
                                                                        "",
                                                                    blog.id ??
                                                                        0)
                                                                .then(
                                                                    (e) async {
                                                              await getComment(blog
                                                                      .id!
                                                                      .toInt())
                                                                  .then(
                                                                      (value) async {
                                                                if (value !=
                                                                    null) {
                                                                  loadComments =
                                                                      false;
                                                                  blog.comments =
                                                                      value;
                                                                  setState(
                                                                      () {});
                                                                }
                                                              }).onError(
                                                                      (e, r) {
                                                                loadComments =
                                                                    false;
                                                                setState(() {});
                                                              });
                                                            }).onError((e, r) {
                                                              loadComments =
                                                                  false;
                                                              setState(() {});
                                                            });
                                                          }

                                                          // });
                                                        } else {
                                                          setState(() {});
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width:
                                                          size(context).width,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 12.h),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(allMessages.value
                                                                  .seeAll ??
                                                              'See all'),
                                                          const Icon(Icons
                                                              .chevron_right_outlined)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                SizedBox(
                                                  height: 20.h,
                                                ),
                                              ])),
                                  ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(left: 20.w, right: 12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    // allMessages.value.postComment ?? 'Post New Comment',
                                    //   style: FontStyleUtilities.h6(context,
                                    //       fontWeight: FWT.extrabold),
                                    // ),
                                    // SizedBox(
                                    //   height: 24.h,
                                    // ),
                                    Container(
                                      width: size(context).width,
                                      height: 65,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SizedBox(
                                              height: 50,
                                              child: MyTextField(
                                                key: widget.isCommentScroll ==
                                                        true
                                                    ? commentKey
                                                    : ValueKey('testfiedl'),
                                                hint: allMessages.value
                                                        .writeYourComment ??
                                                    'Comment',
                                                // maxHeight: 60.h,
                                                isCommentBox: false,
                                                readOnly: readOnly,
                                                onTapOutRead: () {
                                                  readOnly = true;
                                                  setState(() {});
                                                },
                                                onTap: () {
                                                  readOnly = false;
                                                  setState(() {});
                                                },
                                                focus: widget.isCommentScroll ==
                                                        true
                                                    ? focuscomment
                                                    : null,
                                                autoFocus:
                                                    widget.isCommentScroll ==
                                                        true,
                                                maxLines: 4,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 12),
                                                onChanged: (p0) {
                                                  setState(() {});
                                                },
                                                controller: controller,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          GestureDetector(
                                              onTap: currentUser.value.id ==
                                                      null
                                                  ? () {
                                                      NavigationUtil.to(context,
                                                          const Login());
                                                    }
                                                  : isPostLoad == true ||
                                                          controller
                                                              .text.isEmpty
                                                      ? () {}
                                                      : () async {
                                                          isPostLoad = true;
                                                          controller.text =
                                                              controller.text
                                                                  .trim();
                                                          setState(() {});
                                                          await setComment(
                                                                  controller
                                                                      .text,
                                                                  blog.id!
                                                                      .toInt())
                                                              .then(
                                                                  (value) async {
                                                            if (value[
                                                                    'success'] ==
                                                                false) {
                                                              showCustomToast(
                                                                  context,
                                                                  allMessages
                                                                          .value
                                                                          .commentNotPosted ??
                                                                      'Comment cannot be posted. Please try again.',
                                                                  title: allMessages
                                                                          .value
                                                                          .somethingWentWrong ??
                                                                      'Something went wrong!!',
                                                                  isSuccess:
                                                                      false,
                                                                  islogo: false,
                                                                  isBig: true,
                                                                  backColor:
                                                                      Colors
                                                                          .red);
                                                            } else {
                                                              showCustomToast(
                                                                  context,
                                                                  value[
                                                                      'message'],
                                                                  isBig: true,
                                                                  islogo: false,
                                                                  isSuccess:
                                                                      true,
                                                                  backColor: value[
                                                                              'message']
                                                                          .toString()
                                                                          .contains(
                                                                              "approval")
                                                                      ? Colors
                                                                          .yellow
                                                                          .shade700
                                                                      : Colors
                                                                          .green
                                                                          .shade700);
                                                              await getComment(blog
                                                                      .id!
                                                                      .toInt())
                                                                  .then(
                                                                      (value) {
                                                                if (value !=
                                                                    null) {
                                                                  loadComments =
                                                                      false;
                                                                  blog.comments =
                                                                      value;
                                                                  setState(
                                                                      () {});
                                                                }
                                                              });
                                                            }
                                                            controller.text =
                                                                '';
                                                            isPostLoad = false;
                                                            setState(() {});
                                                          });
                                                        },
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(Icons.send),
                                              )),
                                          const SizedBox(width: 8)
                                        ],
                                      ),
                                    ),

                                    // Button(tittle: isPostLoad  ?  'Posting...' : allMessages.value.postComment ?? 'Post Comment',
                                    //  onTap:  ),
                                    SizedBox(
                                      height: 60.h,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                  ),
                  if (orientation != Orientation.landscape &&
                      MediaQuery.of(context).viewInsets.bottom == 0)
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: allSettings.value.enableAds == '1'
                            ? Container(
                                key: const ValueKey('GoogleAds'),
                                width: size(context).width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: widget.index % 2 == 1
                                    ? FacebookAd(
                                        key: ValueKey('FbAds${widget.index}'),
                                        adUnitId: Platform.isIOS
                                            ? allSettings.value
                                                    .fbAdsPlacementIdIos ??
                                                ''
                                            : allSettings.value
                                                    .fbAdsPlacementIdAndroid ??
                                                '',
                                      )
                                    : BannerAds(
                                        key: ValueKey(
                                            "GoogleAds${widget.index}"),
                                        adUnitId: Platform.isIOS
                                            ? allSettings
                                                    .value.admobBannerIdIos ??
                                                ''
                                            : allSettings.value
                                                    .admobBannerIdAndroid ??
                                                '',
                                      ),
                              )
                            : const SizedBox())
                ],
              ),
            );
          }
        }),
      ),
      bottomNavigationBar:
          MediaQuery.of(context).viewInsets.bottom > 0 && readOnly == false
              ? SizedBox(
                  height: 10.h + MediaQuery.of(context).viewInsets.bottom,
                )
              : null,
    );
  }

  Stack yotubeplayer(BuildContext context) {
    return Stack(
      fit: blog.videoUrl != '' ? StackFit.loose : StackFit.expand,
      children: [
        blog.videoUrl != ''
            ? PlayAnyVideoPlayer(
              key: ValueKey(widget.blog.id),
                model: blog,
                isPlayCenter: true,
                startAt: startVideoAt,
                aspectRatio: 18/12,
                orientation: orientation,
                onDurationChange: (val){
                  startVideoAt = val;
                  setState(() { });
                },
                isCurrentlyOpened: true,
              )
            : blog.images != null && blog.images!.length > 1
                ? CaurosalSlider(model: blog)
                : InkResponse(
                    onTap: () {
                      focuscomment.unfocus();
                      Navigator.push(
                          context,
                          PagingTransform(
                              widget: FullScreen(
                                  index: 0,
                                  images: blog.images != null &&
                                          blog.images!.length > 1
                                      ? blog.images
                                      : null,
                                  image: blog.images != null &&
                                          blog.images!.isNotEmpty
                                      ? blog.images![0]
                                      : prefs!.getString('app_logo')),
                              slideUp: true));
                    },
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      height: blog.videoUrl != ''
                          ? size(context).height * 0.27
                          : null,
                      //padding:EdgeInsets.symmetric(horizontal: 24.h, vertical: 0.h),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          image: blog.images != null && blog.images!.isNotEmpty
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      blog.images != null &&
                                              blog.images!.isNotEmpty
                                          ? blog.images![0]
                                          : ''),
                                  fit: BoxFit.cover)
                              : DecorationImage(
                                  image: FileImage(File(
                                      prefs!.getString('app_logo') ?? "")))),
                    ),
                  ),
        // if(blog.videoUrl != '' && videocontroller == null)
        // Positioned.fill(child: ClipRRect(
        //   borderRadius:BorderRadius.circular(16),
        //   child: Container(
        //     color: Colors.black26,
        //     padding:const EdgeInsets.only(bottom:12),
        //     child: const Center(
        //       child: CircularProgressIndicator(),
        //     ),
        //   ),
        // ))
        // orientation == Orientation.landscape ? const SizedBox() : Positioned(
        //   bottom: 0,
        //   left: languageCode.value.pos == 'rtl' ? null : 20,
        //   right: languageCode.value.pos == 'rtl' ? 20 : null,
        //   child:)
      ],
    );
  }

  Widget iconpanel(BuildContext context, AppProvider providers, int countLikes,
      {isDate = true}) {
    return Consumer<AppProvider>(
        //key: Valueket,
        builder: (context, appProvider, child) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8),
        child: Row(
          children: [
            if (isDate == true)
              // Text(
              //   "${blog.scheduleDate!.day} ${getMonth(blog.scheduleDate!.month)} ${blog.scheduleDate!.year}",
              //   style: FontStyleUtilities.t3(context,
              //       fontColor:   dark(context) ? Colors.white: ColorUtil.themNeutral,
              //       fontWeight: FWT.semiBold),
              // )
              Container(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hexToRgb(blog.categoryColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  blog.categoryName ?? 'TRAVEL',
                  style: FontStyleUtilities.t4(context,
                      fontColor: Colors.white, fontWeight: FWT.semiBold),
                ),
              )
            else
              const SizedBox(),
            const Spacer(),
            Row(
              children: [
                LikeIcon(
                    key:
                        ValueKey(providers.permanentlikesIds.contains(blog.id)),
                    count: likeVisible(blog, providers) ?? '0',
                    inActiveColor: Theme.of(context).colorScheme.primary,
                    initialValue: providers.permanentlikesIds.contains(blog.id),
                    onChanged: (value) {
                      // appProvider.addLikeData(blog.id!.toInt());

                      appProvider.setlike(blog: blog);
                      // appProvider.getAnalyticData();
                      setState(() {});
                    }),
                const SizedBox(width: 8),
                Text(likeVisible(widget.blog, providers) ?? "0",
                    key: const ValueKey(1),
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            if (allSettings.value.isVoiceEnabled == true)
              SpaceUtils.ks24.width(),
            if (allSettings.value.isVoiceEnabled == true)
              InkResponse(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 1.25,
                            color: Theme.of(context).primaryColor)),
                    padding: const EdgeInsets.all(0.5),
                    child: isVolume
                        ? Icon(Icons.pause,
                            size: 24,
                            color: dark(context)
                                ? ColorUtil.themNeutral
                                : Theme.of(context).primaryColor)
                        : Icon(Icons.play_arrow_rounded,
                            size: 24,
                            color: dark(context)
                                ? ColorUtil.themNeutral
                                : Theme.of(context).primaryColor),
                  ),
                  onTap: () async {
                    if (allSettings.value.googleApikey != null &&
                        allSettings.value.isVoiceEnabled == true) {
                      if (isVolume == false) {
                        isVolume = true;
                        if (blog.audioData == null) {
                          await speech(
                                  parse(blog.description.toString()).body!.text)
                              .then((value) async {
                            if (value != null) {
                              playLocal(value);
                            }
                          });
                        } else {
                          playLocal(audioLoad ?? blog.audioData as Uint8List);
                        }
                      } else {
                        isVolume = true;
                        stops();
                      }
                      setState(() {});
                    } else {
                      if (isVolume == false) {
                        init(parse(blog.description.toString()).body!.text,
                            providers);
                        isVolume = true;
                        //if (startTime == '') {
                        startTime = DateTime.now().toIso8601String();
                        ttsData = {
                          "id": blog.id,
                          "start_time": startTime,
                          "end_time": endTime
                        };
                        setState(() {});

                        //  }
                      } else {
                        stop();
                        endTime = DateTime.now().toIso8601String();
                        ttsData = {
                          "id": blog.id,
                          "start_time": startTime,
                          "end_time": endTime
                        };
                        // if (startTime != '') {

                        //  }
                        providers.addTtsData(ttsData['id'],
                            ttsData['start_time'], ttsData['end_time']);
                        isVolume = false;
                      }
                    }

                    setState(() {});
                  }),
            SpaceUtils.ks24.width(),
            InkResponse(
              onTap: currentUser.value.id == null
                  ? () {
                      NavigationUtil.to(context, const Login());
                    }
                  : () {
                      if (appProvider.permanentIds.contains(blog.id)) {
                        showCustomToast(
                            context,
                            allMessages.value.bookmarkRemove ??
                                'Bookmark removed');
                        appProvider.removeBookmarkData(blog.id!.toInt());
                      } else {
                        showCustomToast(context,
                            allMessages.value.bookmarkSave ?? 'Bookmark saved');
                        appProvider.addBookmarkData(blog.id!.toInt());
                      }
                      appProvider.setBookmark(blog: blog);
                      setState(() {});
                    },
              child: !appProvider.permanentIds.contains(blog.id)
                  ? SvgIcon('asset/Icons/book_mark.svg',
                      width: 26,
                      height: 26,
                      color: Theme.of(context).colorScheme.primary)
                  : SvgIcon('asset/Icons/bookmark-fill.svg',
                      width: 26,
                      height: 26,
                      color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      );
    });
  }

  void unfocusListen() {
    focuscomment.unfocus();
  }

  Future intenUrlShareWhatsapp(BuildContext context) async {
    try {
      load = true;
      setState(() {});
      createDynamicLink(blog).then((value) async {
        load = false;
        setState(() {});
        if (Platform.isIOS) {
          openWhatsApp(
              "https://wa.me/?text=${allMessages.value.shareMessage} $value");
        } else {
          await appinioSocialShare.android.shareToWhatsapp(
              "${allMessages.value.shareMessage} $value", null);
        }
      });
    } catch (error) {
      load = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text('$error'),
        ),
      );
    }
  }

  Future<void> commentPage(
      BuildContext context, Blog blog, ValueChanged vals) async {
    BottomSheetWidget.bottom(
        context,
        key: blog.comments!.data!.length.toString(),
        CommentPopUP(
            blogData: blog,
            key: ValueKey(blog.comments!.data!.length),
            onChanged: vals),
        isComment: true,
        initialSize: 0.9,
        blogid: blog.id, onCommentAdd: (val) {
      blog.comments!.data!.add(val);
      setState(() {});
      vals('add');
    },
        title: allMessages.value.commentHeader ?? 'Comments',
        isScrollable: true);
  }

  Future intenUrlShareSMS(BuildContext context) async {
    try {
      load = true;
      setState(() {});
      createDynamicLink(blog).then((value) async {
        load = false;
        setState(() {});

        // -------------- mailto can't be tested on ios emulator. -------------

        final Uri params = Uri(
          scheme: 'mailto',
          path: currentUser.value.email,
          query: encodeQueryParameters({
            'subject': "${blog.title}",
            'body': "${allMessages.value.shareMessage} $value"
          }), //add subject and body here
        );

        if (await canLaunchUrl(params)) {
          await launchUrl(params);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).cardColor,
              content: Text('Could not launch mail',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: dark(context) ? Colors.white : Colors.black)),
            ),
          );
          throw 'Could not launch';
        }
        // await SocialShare.shareSms(
        //    value
        // );
      });
    } catch (error) {
      load = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text('$error'),
        ),
      );
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future intenUrlShareTelegram(BuildContext context) async {
    try {
      load = true;
      setState(() {});
      createDynamicLink(blog).then((value) async {
        load = false;
        setState(() {});
        if (Platform.isIOS) {

           await appinioSocialShare.iOS.shareToTelegram(
              "${allMessages.value.shareMessage}\n$value");
          // openWhatsApp(
          //     "https://telegram.me/share/url?url=${allMessages.value.shareMessage}\n$value");
        } else {
          // if (Platform.isAndroid) {
            await appinioSocialShare.android.shareToTelegram(
              "${allMessages.value.shareMessage}\n$value",null);
          // } 
        }
      });
    } catch (error) {
      load = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text('$error'),
        ),
      );
    }
  }

  Future intenUrlShare(BuildContext context) async {
    try {
      load = true;
      setState(() {});
      createDynamicLink(blog).then((value) async {
        load = false;
        setState(() {});

        if (Platform.isIOS) {
          final tags =
              (blog.blogSubCategory != null && blog.blogSubCategory!.isNotEmpty
                      ? blog.blogSubCategory
                      : [blog.categoryName])!
                  .map((t) => '#$t ')
                  .join(' ');

          var captionText = "\n$tags";
          openWhatsApp(
              "https://twitter.com/intent/tweet?url=${blog.title}\n\n$captionText\n\n");
        } else {
          await appinioSocialShare.android.shareToTwitter(
            "${blog.title}\n ${blog.categoryName ?? ''}\n $value \n${allMessages.value.shareMessage}", null);
        }
      });
    } catch (error) {
      load = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text('$error'),
        ),
      );
    }
  }
}

class CommentPopUP extends StatefulWidget {
  const CommentPopUP(
      {super.key, required this.blogData, required this.onChanged});
  final Blog blogData;
  final ValueChanged<String?> onChanged;

  @override
  State<CommentPopUP> createState() => _CommentPopUPState();
}

class _CommentPopUPState extends State<CommentPopUP> {
  late Blog blog;

  int presIndex = 0;

  @override
  void initState() {
    blog = widget.blogData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CommentModel?>(
        future: getComment(widget.blogData.id ?? 0),
        key: ValueKey(blog.comments != null && blog.comments!.data != null
            ? blog.comments!.data!.length
            : 0),
        builder: (context, AsyncSnapshot<CommentModel?> snapshot) {
          List<Comment> comments =
              snapshot.data != null ? snapshot.data!.data ?? [] : [];
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Divider(
                height: 20,
                indent: 16,
                thickness: 1,
                endIndent: 16,
              ),
              const SizedBox(height: 12),
              if (snapshot.hasData &&
                  snapshot.data!.data != null &&
                  snapshot.data!.data!.isNotEmpty)
                ...List.generate(comments.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CommentsTile(
                        comments: comments[index],
                        isPopup: true,
                        onChanged: (value) async {
                          if (comments.contains(value)) {
                            presIndex = comments.indexOf(value);
                            comments.remove(value);
                            blog.comments!.data!.remove(value);
                            await deleteComment(value.id!.toInt());
                            widget.onChanged('remove');
                            setState(() {});
                          } else {
                            comments.insert(presIndex, value);
                            blog.comments!.data!.add(value);
                            // widget.onChanged(null);
                            setState(() {});
                          }
                        }),
                  );
                })
              else if (snapshot.connectionState == ConnectionState.waiting)
                Container(
                    alignment: Alignment.center,
                    height: size(context).height / 1.75,
                    child: const CircularProgressIndicator())
              else
                Container(
                    alignment: Alignment.center,
                    height: size(context).height / 1.75,
                    child: Text(
                        allMessages.value.nocommentYet ?? 'No Comments yet',
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            color: dark(context)
                                ? Colors.grey.shade200
                                : Colors.grey.shade700))),
            ],
          );
        });
  }
}
