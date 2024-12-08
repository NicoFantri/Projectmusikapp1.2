import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/app/data/model/track.dart';
import 'package:musicapp/app/modules/home/views/widgets/animated_widget.dart';
import 'package:musicapp/app/modules/home/views//widgets/button_widget.dart';
import 'package:musicapp/app/modules/home/views/widgets/custom_cached_image.dart';
import 'package:musicapp/app/modules/home/views//widgets/custom_text.dart';
import 'package:musicapp/app/modules/home/views/widgets/fadingpageview/fadingpageview.dart';
import 'package:musicapp/app/data/utils/app_navigators.dart';
import 'package:musicapp/app/data/utils/music_storage.dart';

class PreviewScreen extends StatefulWidget {
  final List<Tracks> listTrack;

  const PreviewScreen({super.key, required this.listTrack});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  late FadingPageViewController _pageController;
  int index = 0;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _pageController = FadingPageViewController(0, widget.listTrack.length);
    await player.play(UrlSource(
        widget.listTrack.firstOrNull?.previewUrl ?? 'https://foo.com/bar.mp3'));
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  Widget _buildPreview(int index) {
    return Stack(
      children: [
        Hero(
          tag: widget.listTrack.firstOrNull?.album?.images?.firstOrNull?.url ??
              "",
          child: customCachedImage(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
              isRectangle: true,
              url:
                  widget.listTrack[index].album?.images?.firstOrNull?.url ?? "",
              isDrive: false,
              isBlack: true),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width / 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedCustomWidget(
                offset: const Offset(-0.3, 0),
                child: customCachedImage(
                  width: 75,
                  height: 75,
                  radius: 15,
                  isRectangle: true,
                  url:
                      widget.listTrack[index].album?.images?.firstOrNull?.url ??
                          "",
                  isDrive: false,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCustomWidget(
                      offset: const Offset(-0.3, 0),
                      child: CustomText(
                        text: widget.listTrack[index].name ?? "-",
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedCustomWidget(
                      offset: const Offset(-0.3, 0),
                      child: CustomText(
                        text: widget.listTrack[index].artists
                                ?.map((e) => e.name ?? "-")
                                .join(", ") ??
                            "-",
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedCustomWidget(
                      offset: const Offset(-0.3, 0),
                      child: CustomText(
                        text: formatMilliseconds(
                            widget.listTrack[index].durationMs ?? 0),
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int lastIndex = widget.listTrack.length - 1;
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onTapUp: (details) async {
              HapticFeedback.lightImpact();

              if (details.localPosition.dx <
                  ((screenWidth > 600
                          ? (screenWidth / ((screenWidth > 1028) ? 3 : 4))
                          : screenWidth) /
                      2)) {
                if (index > 0) {
                  await player.play(UrlSource(
                      widget.listTrack[index - 1].previewUrl ??
                          'https://foo.com/bar.mp3'));

                  setState(() {
                    index--;
                  });

                  _pageController.previous();
                }
              } else {
                if (index < lastIndex) {
                  await player.play(UrlSource(
                      widget.listTrack[index + 1].previewUrl ??
                          'https://foo.com/bar.mp3'));

                  setState(() {
                    index++;
                  });

                  _pageController.next();
                } else if (index == lastIndex) {
                  pageBack();
                }
              }
            },
            onVerticalDragEnd: (details) {
              pageBack();
            },
            child: FadingPageView(
              controller: _pageController,
              itemBuilder: (BuildContext context, int index) {
                return _buildPreview(index);
              },
            ),
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 4,
                  child: Row(
                    children: [
                      for (var i = 0; i < widget.listTrack.length; i++)
                        Expanded(
                          child: Row(
                            children: [
                              if (i != 0) const SizedBox(width: 3),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(
                                        begin: 0, end: i == index ? 1 : 0),
                                    duration: Duration(
                                        milliseconds: i == index ? 7500 : 0),
                                    curve: Curves.linear,
                                    onEnd: () async {
                                      if (i == lastIndex &&
                                          index == lastIndex) {
                                        pageBack();
                                      } else if (i == index && i != lastIndex) {
                                        await player.play(UrlSource(widget
                                                .listTrack[index + 1]
                                                .previewUrl ??
                                            'https://foo.com/bar.mp3'));

                                        setState(() {
                                          index++;
                                        });

                                        _pageController.next();
                                      }
                                    },
                                    builder: (BuildContext context,
                                        double value, Widget? child) {
                                      return LinearProgressIndicator(
                                        minHeight: 3,
                                        value: index > i ? 1 : value,
                                        backgroundColor: Colors.grey.shade300,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
