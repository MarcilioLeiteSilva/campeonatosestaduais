part of '../screens.dart';

class WatchContentScreen extends StatefulWidget {
  final VideoModel video;

  const WatchContentScreen({super.key, required this.video});

  @override
  State<WatchContentScreen> createState() => _WatchContentScreenState();
}

class _WatchContentScreenState extends State<WatchContentScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    
    // Forçar orientação paisagem (Landscape) ao entrar na tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Ocultar barras do sistema para tela cheia imersiva
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initializePlayer();
  }

  String? _getVideoId(String url) {
    final regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(7)?.length == 11) ? match.group(7) : null;
  }

  Future<void> _initializePlayer() async {
    final videoId = _getVideoId(widget.video.url);
    if (videoId == null) {
      print("ID do vídeo inválido para URL: ${widget.video.url}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL de vídeo inválida.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    final yt = YoutubeExplode();
    try {
      // Obter o manifesto dos streams do YouTube
      final manifest = await yt.videos.streams.getManifest(videoId);
      
      // Obter o stream muxado (áudio + vídeo) com melhor qualidade (maior tamanho de arquivo)
      final streamInfo = manifest.muxed.reduce((curr, next) => 
          curr.size.totalBytes > next.size.totalBytes ? curr : next);
      
      _videoPlayerController = VideoPlayerController.networkUrl(streamInfo.url);
      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        fullScreenByDefault: true,
        showControlsOnInitialize: true,
        placeholder: const Center(
          child: CircularProgressIndicator(color: AppColor.primary),
        ),
      );
    } catch (e) {
      print("Erro ao carregar transmissão do YouTube: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível carregar o vídeo.')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      yt.close();
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    
    // Restaurar orientação para retrato (Portrait) ao sair da tela
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Restaurar as barras do sistema
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = _chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: isInitialized
                ? Chewie(
                    controller: _chewieController!,
                  )
                : const CircularProgressIndicator(color: AppColor.primary),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: ClipOval(
                child: Material(
                  color: Colors.black.withOpacity(0.6),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
