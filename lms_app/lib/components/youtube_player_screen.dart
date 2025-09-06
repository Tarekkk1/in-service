// import 'package:flutter/material.dart';
// import 'package:lms_app/utils/custom_cached_image.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class YoutubePlayerScreen extends StatefulWidget {
//   const YoutubePlayerScreen({super.key, required this.videoUrl, this.thumbnail});

//   final String videoUrl;
//   final String? thumbnail;

//   @override
//   State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
// }

// class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     final String? id = YoutubePlayer.convertUrlToId(widget.videoUrl);
//     _controller = _controller = YoutubePlayerController(
//       initialVideoId: id ?? '',
//       flags: const YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: YoutubePlayerBuilder(
//           player: YoutubePlayer(
//             controller: _controller,
//             thumbnail: widget.thumbnail != null ? CustomCacheImage(imageUrl: widget.thumbnail, radius: 0) : null,
//           ),
//           builder: (context, player) {
//             return Stack(
//               alignment: Alignment.center,
//               children: [
//                 player,
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: SafeArea(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 10, top: 10),
//                       child: IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: const Icon(Icons.close, color: Colors.white, size: 28),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             );
//           }),
//     );
//   }
// }
