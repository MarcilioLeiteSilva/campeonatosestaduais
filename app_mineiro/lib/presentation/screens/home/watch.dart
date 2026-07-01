part of '../screens.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  bool _isLoading = false;

  Future<void> _refreshVideos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await VideosApi.loadFromPocketBase();
    } catch (e) {
      print("Erro ao atualizar vídeos: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text("Watch"),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () => context.pushNamed(screenSearch),
              icon: SvgPicture.asset(
                Assets.searchLine,
                color: Colors.white,
                height: 25,
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColor.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            tabs: [
              Tab(text: "Módulo 1"),
              Tab(text: "Módulo 2"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVideoList(context, '629'),
            _buildVideoList(context, '619'),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList(BuildContext context, String leagueId) {
    final videos = VideosApi.vListVideos.where((v) => v.leagueId == leagueId).toList();

    if (_isLoading) {
      return Center(
        child: LoadingAnimationWidget.twoRotatingArc(
          color: AppColor.primary,
          size: 40,
        ),
      );
    }

    if (videos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshVideos,
        color: AppColor.primary,
        backgroundColor: AppColor.card,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: context.height * 0.25),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  Gap(15),
                  Text(
                    'Nenhum vídeo disponível no momento!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(5),
                  Text(
                    'Puxe para atualizar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshVideos,
      color: AppColor.primary,
      backgroundColor: AppColor.card,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return _VideoCard(video: videos[index]);
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          context.pushNamed(screenWatchContent, extra: video);
        },
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        video.thumbnail,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColor.info,
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_fill_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primary.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          video.channelName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      _formatVideoDate(video.date),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColor.hint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatVideoDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr).toLocal();
      final difference = DateTime.now().difference(parsed);

      if (difference.inDays > 0) {
        if (difference.inDays == 1) {
          return "Ontem";
        }
        return "${difference.inDays} dias atrás";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} horas atrás";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} minutos atrás";
      }
      return "Agora mesmo";
    } catch (_) {
      return dateStr;
    }
  }
}
