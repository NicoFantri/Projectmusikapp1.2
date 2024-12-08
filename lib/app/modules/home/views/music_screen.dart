import 'dart:developer';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:musicapp/app/data/model/artist.dart';
import 'package:musicapp/app/data/model/artist_album.dart';
import 'package:musicapp/app/data/model/track.dart';
import 'package:musicapp/app/data/repository/music_repo.dart';
import 'package:musicapp/app/data/repository/user_repo.dart';
import 'package:musicapp/app/modules/home/views/preview_screen.dart';
import 'package:musicapp/app/modules/home/views/widgets/custom_back_button.dart';
import 'package:musicapp/app/modules/home/views/widgets/custom_cached_image.dart';
import 'package:musicapp/app/modules/home/views/widgets/custom_text.dart';
import 'package:musicapp/app/data/utils/app_navigators.dart';
import 'package:musicapp/app/data/utils/music_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

class MusicScreen extends StatefulWidget {
  final Artist artist;
  const MusicScreen({super.key, required this.artist});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  bool isLoading = false;
  ArtistAlbumResponse? _artistAlbumResponse;
  List<Tracks> listTrack = [];
  List<Artist> relatedArtist = [];

  bool isSnap = false;
  bool isAnimate = false;

  final ScrollController _scrollController = ScrollController();
  final DraggableScrollableController _draggableScrollableController =
  DraggableScrollableController();

  String? description;

  final player = AudioPlayer();
  String? idPlayer;

  List<Tracks> selectedAlbumTrack = [];
  double? valuePreview = 1;

  @override
  void initState() {
    super.initState();
    init();
    _scrollController.addListener(snapScroll);
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    _scrollController.removeListener(snapScroll);
    _scrollController.dispose();
    _draggableScrollableController.dispose();
  }

  AppBar dummyAppBar = AppBar(
    title: const CustomText(
      text: "-",
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  );
  double offset = 0;
  double titleOffset = 0;
  double opacityBorder = 0;
  Future<void> snapScroll() async {
    final double maxTitleOffset = 300 -
        (dummyAppBar.preferredSize.height +
            MediaQuery.viewPaddingOf(context).top);
    const double snapThreshold = 10;

    offset = _scrollController.hasClients ? _scrollController.offset : 0;
    titleOffset = maxTitleOffset;
    opacityBorder = (offset / titleOffset).clamp(0, 1);

    if ((offset - titleOffset).abs() < snapThreshold) {
      await _snapToPosition(titleOffset);
    } else if ((offset - (titleOffset + 260)).abs() < snapThreshold) {
      await _snapToPosition(titleOffset + 260);
    } else if (!isSnap) {
      isSnap = true;
    }
  }

  Future<void> _snapToPosition(double targetOffset) async {
    if (isSnap && !isAnimate) {
      isSnap = false;
      isAnimate = true;
      await _scrollController.animateTo(targetOffset,
          duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
      isAnimate = false;
    }
  }

  Future<void> init() async {
    await MusicRepo.getArtistAlbums(widget.artist.id ?? "").then((value) {
      if (value[0] == 200) {
        if (mounted) {
          setState(() {
            _artistAlbumResponse = value[1] as ArtistAlbumResponse?;
          });
        }
      }
    });

    await MusicRepo.getArtistTopTrack(widget.artist.id ?? "").then((value) {
      if (mounted) {
        setState(() {
          listTrack = value;
        });
      }
    });

    await MusicRepo.getArtists().then((value) {
      if (mounted) {
        setState(() {
          relatedArtist = value;
        });
      }
    });

    CacheArtist? cacheArtist = MusicStorage.cacheArtist
        .firstWhereOrNull((e) => e.id == widget.artist.id);

    if (cacheArtist != null) {
      if (mounted) {
        setState(() {
          description = cacheArtist.about;
        });
      }
    } else {
      await UserRepo.generateContent(
          text:
          "Tell me about artist ${widget.artist.name ?? ""}, for more information genre is ${widget.artist.genres?.join(", ") ?? ""} and album is ${_artistAlbumResponse?.items?.map((e) => e.name).toList().join(", ")} and music is ${listTrack.map((e) => e.name).toList().join(", ")} in one paragraph so user can easy to read it")
          .then((value) async {
        if (mounted) {
          setState(() {
            description = value;
          });
        }

        await MusicStorage.addArtistAbout(
            CacheArtist(id: widget.artist.id, about: value));
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor
            .withOpacity(opacityBorder),
        title: Opacity(
          opacity: opacityBorder,
          child: CustomText(
            text: widget.artist.name ?? "-",
            fontSize: 18,
            fontWeight: FontWeight.w700,
            padding: EdgeInsets.only(top: 16 - (16 * opacityBorder)),
          ),
        ),
        leading: const CustomBackButton(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LikeButton(
              size: 30,
              isLiked: MusicStorage.favouriteArtist.contains(widget.artist.id),
              circleColor: const CircleColor(
                  start: Colors.purple, end: Colors.deepPurple),
              bubblesColor: const BubblesColor(
                dotPrimaryColor: Colors.purple,
                dotSecondaryColor: Colors.deepPurple,
              ),
              onTap: (isLiked) async {
                HapticFeedback.lightImpact();

                if (isLiked) {
                  await MusicStorage.removeFavourite(widget.artist.id ?? "");
                } else {
                  await MusicStorage.addFavourite(widget.artist.id ?? "");
                }

                log(isLiked.toString());
                log(MusicStorage.favouriteArtist.toString());

                return !isLiked;
              },
              likeBuilder: (isLiked) {
                return Icon(
                  Icons.favorite_rounded,
                  color: isLiked ? Colors.red : Colors.white,
                  size: 30,
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Hero(
            tag: widget.artist.images?.firstOrNull?.url ?? "",
            child: customCachedImage(
              width: double.infinity,
              height: (300 - (offset > 0 ? offset : 0)).clamp(
                      dummyAppBar.preferredSize.height +
                          MediaQuery.viewPaddingOf(context).top,
                      300) +
                  (offset < 0 ? (offset * -1) : 0),
              isRectangle: true,
              url: widget.artist.images?.firstOrNull?.url ?? "",
              isDrive: false,
              isBlack: true,
            ),
          ),
          NotificationListener(
            onNotification: (notification) {
              if (mounted) {
                setState(() {});
              }
              return true;
            },
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  child: CustomText(
                    text: widget.artist.name ?? "",
                    fontSize: 40 +
                        (_scrollController.hasClients
                            ? ((-1 * _scrollController.offset) / 40)
                                .clamp(0, 20)
                            : 0),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 16),
                    if (listTrack.isNotEmpty &&
                        !listTrack.any((e) => e.previewUrl == null))
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();

                          setState(() {
                            valuePreview = null;
                          });

                          await Future.delayed(
                              const Duration(milliseconds: 750));

                          await pageOpenWithResult(
                              PreviewScreen(listTrack: listTrack));

                          setState(() {
                            valuePreview = 1;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Hero(
                                    tag: listTrack.firstOrNull?.album?.images
                                            ?.firstOrNull?.url ??
                                        "",
                                    child: customCachedImage(
                                      width: 36,
                                      height: 36,
                                      radius: 100,
                                      isRectangle: true,
                                      url: listTrack.firstOrNull?.album?.images
                                              ?.firstOrNull?.url ??
                                          "",
                                      isDrive: false,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                        value: valuePreview),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              const CustomText(
                                text: "Top Track Preview",
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ),



                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: "Top Track",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          padding: EdgeInsets.only(left: 16),
                        ),
                        const SizedBox(height: 4),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: listTrack.length,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              var track = listTrack[index];

                              return TrackPreview(
                                tracks: track,
                                player: player,
                                idPlayer: idPlayer,
                                isAlbum: true,
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      idPlayer = track.id;
                                    });
                                  }
                                },
                                onEnd: () {
                                  if (mounted) {
                                    setState(() {
                                      idPlayer = null;
                                    });
                                  }
                                },
                              );
                            }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "About ${widget.artist.name ?? "-"}",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            text:
                                "${NumberFormat("#,##0", "en_US").format(widget.artist.followers?.total ?? 0)} monthly listeners",
                            overflow: TextOverflow.ellipsis,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            text: description ?? "-",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: "Related Artist",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          padding: EdgeInsets.only(left: 16),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                              itemCount: relatedArtist.length,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                var artist = relatedArtist[index];

                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: index == 0 ? 16 : 0, right: 16),
                                  child: GestureDetector(
                                    onTap: () async {
                                      HapticFeedback.lightImpact();

                                      if (mounted) {
                                        setState(() {
                                          idPlayer = null;
                                          player.stop();
                                        });
                                      }

                                      await pageOpenWithResult(
                                          MusicScreen(artist: artist));

                                      setState(() {});
                                    },
                                    child: Stack(
                                      children: [
                                        customCachedImage(
                                          width: 150,
                                          height: 150,
                                          radius: 25,
                                          isRectangle: true,
                                          url:
                                              artist.images?.firstOrNull?.url ??
                                                  "",
                                          isDrive: false,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            MusicStorage.favouriteArtist
                                                    .contains(artist.id)
                                                ? SizedBox(
                                                    width: 150,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 6,
                                                                  top: 6),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            child:
                                                                BackdropFilter(
                                                              filter: ImageFilter
                                                                  .blur(
                                                                      sigmaX:
                                                                          10.0,
                                                                      sigmaY:
                                                                          10.0),
                                                              child: Container(
                                                                width: 35,
                                                                height: 35,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        5,
                                                                        5,
                                                                        5,
                                                                        3),
                                                                color: Colors
                                                                    .grey
                                                                    .shade800
                                                                    .withOpacity(
                                                                        0.5),
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .favorite_rounded,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(25),
                                                      bottomRight:
                                                          Radius.circular(25)),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 10.0, sigmaY: 10.0),
                                                child: Container(
                                                  width: 150,
                                                  height: 40,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  color: Colors.grey.shade800
                                                      .withOpacity(0.5),
                                                  alignment: Alignment.center,
                                                  child: CustomText(
                                                    text: artist.name ?? "",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 16 + MediaQuery.viewPaddingOf(context).bottom),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getAlbumTrack(String albumId) async {
    final result = await MusicRepo.getAlbumTrack(albumId);
    if (result[0] == 200) {
      TracksResponse tracksResponse = result[1];
      setState(() {
        selectedAlbumTrack = tracksResponse.items ?? [];
      });
    }
  }

  Future<void> showAlbum(Albums? selectedAlbum) async {
    player.stop();
    ScrollController controller = ScrollController();
    bool isOpen = true;
    bool initial = true;
    String? aboutAlbum;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        enableDrag: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            if (initial) {
              initial = false;

              if (selectedAlbumTrack.isEmpty) {
                getAlbumTrack(selectedAlbum?.id ?? "").then((value) async {
                  if (mounted) {
                    setState(() {});
                  }

                  CacheArtist? cacheAlbum = MusicStorage.cacheAlbum
                      .firstWhereOrNull((e) => e.id == selectedAlbum?.id);

                  if (cacheAlbum != null) {
                    if (mounted) {
                      setState(() {
                        aboutAlbum = cacheAlbum.about;
                      });
                    }
                  } else {
                    await UserRepo.generateContent(
                            text:
                                "Tell me about album ${selectedAlbum?.name ?? ""} by ${selectedAlbum?.artists?.map((e) => e.name).toList().join(", ") ?? ""}, for more information genre is ${widget.artist.genres?.join(", ") ?? ""} and music is ${selectedAlbumTrack.map((e) => "${e.name ?? ""} by ${e.artists?.map((r) => r.name).toList().join(", ") ?? ""}").toList().join(", ")} release on ${formatDate("d MMMM y", date: selectedAlbum?.releaseDate)} in one paragraph so user can easy to read it")
                        .then((valueAbout) async {
                      if (mounted) {
                        setState(() {
                          aboutAlbum = valueAbout;
                        });
                      }

                      await MusicStorage.addAlbumAbout(CacheArtist(
                          id: selectedAlbum?.id, about: valueAbout));
                    });
                  }
                });
              }
            }

            bool isDark =
                MediaQuery.of(context).platformBrightness == Brightness.dark;

            return NotificationListener(
              onNotification: (notification) {
                if (controller.offset < -125 && isOpen) {
                  isOpen = false;
                  pageBack();
                }

                return true;
              },
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.75,
                child: ListView(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        customCachedImage(
                          width: MediaQuery.sizeOf(context).width / 2,
                          height: MediaQuery.sizeOf(context).width / 2,
                          radius: 20,
                          isRectangle: true,
                          url: selectedAlbum?.images?.firstOrNull?.url ?? "",
                          isDrive: false,
                        ),
                        const SizedBox(height: 10),
                        CustomText(
                          text: selectedAlbum?.name ?? "",
                          overflow: TextOverflow.clip,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.center,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                        ),
                        const SizedBox(height: 2),
                        CustomText(
                          text: selectedAlbum?.artists
                                  ?.map((e) => e.name ?? "")
                                  .toList()
                                  .join(", ") ??
                              "-",
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        CustomText(
                          text:
                              "${selectedAlbum?.totalTracks ?? 0} songs, ${Duration(milliseconds: selectedAlbumTrack.fold(0, (int sum, e) => sum + (e.durationMs ?? 0))).inMinutes} minutes",
                          overflow: TextOverflow.ellipsis,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const CustomText(
                      text: "List Track",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      padding: EdgeInsets.only(left: 16),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedAlbumTrack.length,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var track = selectedAlbumTrack[index];

                          return TrackPreview(
                            tracks: track,
                            player: player,
                            idPlayer: idPlayer,
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  idPlayer = track.id;
                                });
                              }
                            },
                            onEnd: () {
                              if (mounted) {
                                setState(() {
                                  idPlayer = null;
                                });
                              }
                            },
                          );
                        }),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "About ${selectedAlbum?.name ?? "-"}",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            text: formatDate("EEEE, d MMMM y",
                                date: selectedAlbum?.releaseDate),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            text: aboutAlbum ?? "-",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: 16 + MediaQuery.viewPaddingOf(context).bottom),
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() => setState(() {
          idPlayer = null;
          selectedAlbumTrack.clear();
          player.stop();
        }));
  }
}

class TrackPreview extends StatefulWidget {
  final Tracks tracks;
  final AudioPlayer player;
  final String? idPlayer;
  final Function() onTap;
  final Function() onEnd;
  final EdgeInsets? padding;
  final bool? isAlbum;

  const TrackPreview(
      {super.key,
      required this.tracks,
      required this.player,
      this.idPlayer,
      required this.onTap,
      required this.onEnd,
      this.padding,
      this.isAlbum});

  @override
  State<TrackPreview> createState() => _TrackPreviewState();
}

class _TrackPreviewState extends State<TrackPreview> {
  Duration? _duration;
  Duration? _position;

  @override
  Widget build(BuildContext context) {
    widget.player.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.completed) {
        widget.onEnd();
      }
    });

    widget.player.onPositionChanged.listen((event) {
      if (mounted) {
        if (event != _duration) {
          setState(() => _position = event);
        }
      }
    });

    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();

        if (widget.tracks.previewUrl != null) {
          if (widget.idPlayer == widget.tracks.id) {
            if (widget.player.state == PlayerState.playing) {
              await widget.player.pause();
            } else {
              await widget.player.resume();
            }
          } else {
            widget.onTap();

            await widget.player.play(UrlSource(
                widget.tracks.previewUrl ?? 'https://foo.com/bar.mp3'));
            widget.player.getDuration().then((value) => _duration = value);
          }
        }
      },
      child: Padding(
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                (widget.tracks.album?.images?.isNotEmpty ?? false)
                    ? customCachedImage(
                        width: 50,
                        height: 50,
                        radius: 10,
                        isRectangle: true,
                        url:
                            widget.tracks.album?.images?.firstOrNull?.url ?? "",
                        isDrive: false,
                        isBlack: widget.idPlayer == widget.tracks.id,
                      )
                    : Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: CustomText(
                            text: (widget.tracks.trackNumber ?? 0).toString())),
                if (widget.idPlayer == widget.tracks.id)
                  Center(
                      child: Container(
                          width:
                              (widget.tracks.album?.images?.isNotEmpty ?? false)
                                  ? 50
                                  : 30,
                          height:
                              (widget.tracks.album?.images?.isNotEmpty ?? false)
                                  ? 50
                                  : 30,
                          padding:
                              (widget.tracks.album?.images?.isNotEmpty ?? false)
                                  ? const EdgeInsets.all(14)
                                  : EdgeInsets.zero,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: widget.player.state == PlayerState.playing ||
                                    widget.player.state == PlayerState.paused
                                ? ((_position?.inMilliseconds ?? 1) /
                                        (_duration?.inMilliseconds ?? 1))
                                    .clamp(0, 1)
                                : null,
                          )))
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: widget.tracks.name ?? "",
                    overflow: TextOverflow.clip,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  CustomText(
                    text: (widget.isAlbum ?? false)
                        ? (widget.tracks.album?.name ?? "-")
                        : (widget.tracks.artists
                                ?.map((e) => e.name ?? "")
                                .toList()
                                .join(", ") ??
                            "-"),
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
