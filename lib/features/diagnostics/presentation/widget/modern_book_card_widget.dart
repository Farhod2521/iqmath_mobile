//
// import 'dart:ui';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../../data/models/subject.dart';
//
// class ModernBookCard extends StatefulWidget {
//   final Subject subject;
//   final VoidCallback onTap;
//
//   const ModernBookCard({
//     super.key,
//     required this.subject,
//     required this.onTap,
//   });
//
//   @override
//   State<ModernBookCard> createState() => _ModernBookCardState();
// }
//
// class _ModernBookCardState extends State<ModernBookCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   List<Color> _getProgressGradient(int progress) {
//     if (progress == 0) {
//       return [const Color(0xFF8E8E93), const Color(0xFF636366)];
//     } else if (progress < 30) {
//       return [const Color(0xFFFF6B6B), const Color(0xFFFF3B30)];
//     } else if (progress < 60) {
//       return [const Color(0xFFFFB444), const Color(0xFFFF9500)];
//     } else if (progress < 90) {
//       return [const Color(0xFFFFD60A), const Color(0xFFFFCC00)];
//     } else {
//       return [const Color(0xFF34C759), const Color(0xFF30B350)];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = widget.subject.imageUz.isNotEmpty
//         ? 'https://api.iqmath.uz${widget.subject.imageUz}'
//         : '';
//     final progress = widget.subject.progressPercent.toInt();
//     final progressGradient = _getProgressGradient(progress);
//
//     return GestureDetector(
//       onTapDown: (_) => _controller.forward(),
//       onTapUp: (_) {
//         _controller.reverse();
//         widget.onTap();
//       },
//       onTapCancel: () => _controller.reverse(),
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           decoration: BoxDecoration(
//             color: CupertinoColors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 20,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Image with progress ring overlay
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.all(12),
//                   child: Stack(
//                     children: [
//                       // Book image
//                       Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           boxShadow: [
//                             BoxShadow(
//                               color: progressGradient[0].withOpacity(0.25),
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(14),
//                           child: imageUrl.startsWith('http')
//                               ? Image.network(
//                             imageUrl,
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: double.infinity,
//                             loadingBuilder: (context, child, progress) {
//                               if (progress == null) return child;
//                               return Center(
//                                 child: CupertinoActivityIndicator(
//                                   radius: 12,
//                                 ),
//                               );
//                             },
//                             errorBuilder: (context, error, stackTrace) {
//                               return _buildFallbackIcon();
//                             },
//                           )
//                               : _buildFallbackIcon(),
//                         ),
//                       ),
//
//                       // Circular progress indicator - top right
//                       if (widget.subject.hasTakenDiagnostic)
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: _buildCircularProgress(progress, progressGradient),
//                         )
//                       else
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: _buildNewBadge(),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // Subject info
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//                 child: Column(
//                   children: [
//                     // Class badge
//                     Container(
//                       height: 32,
//                       margin: const EdgeInsets.only(bottom: 8),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: progressGradient,
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                         boxShadow: [
//                           BoxShadow(
//                             color: progressGradient[0].withOpacity(0.35),
//                             blurRadius: 10,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.subject.className,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700,
//                             color: CupertinoColors.white,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // Progress bar (horizontal)
//                     if (widget.subject.hasTakenDiagnostic)
//                       _buildLinearProgressBar(progress, progressGradient),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCircularProgress(int progress, List<Color> colors) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(30),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: CupertinoColors.white.withOpacity(0.95),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: CupertinoColors.white.withOpacity(0.5),
//               width: 2,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.15),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 width: 48,
//                 height: 48,
//                 child: CircularProgressIndicator(
//                   value: 1.0,
//                   strokeWidth: 4,
//                   backgroundColor: const Color(0xFFE5E5EA),
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     Color(0xFFE5E5EA),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 48,
//                 height: 48,
//                 child: TweenAnimationBuilder<double>(
//                   duration: const Duration(milliseconds: 800),
//                   curve: Curves.easeOutCubic,
//                   tween: Tween<double>(
//                     begin: 0.0,
//                     end: progress / 100,
//                   ),
//                   builder: (context, value, child) {
//                     return CircularProgressIndicator(
//                       value: value,
//                       strokeWidth: 4,
//                       strokeCap: StrokeCap.round,
//                       backgroundColor: Colors.transparent,
//                       valueColor: AlwaysStoppedAnimation<Color>(colors[0]),
//                     );
//                   },
//                 ),
//               ),
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '$progress',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w900,
//                       color: colors[0],
//                       height: 1,
//                     ),
//                   ),
//                   Text(
//                     '%',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: colors[0].withOpacity(0.7),
//                       height: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNewBadge() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: CupertinoColors.activeBlue,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: CupertinoColors.white.withOpacity(0.3),
//               width: 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Icon(
//                 CupertinoIcons.sparkles,
//                 size: 14,
//                 color: CupertinoColors.white,
//               ),
//               SizedBox(width: 4),
//               Text(
//                 'Yangi',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: CupertinoColors.white,
//                   letterSpacing: 0.3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLinearProgressBar(int progress, List<Color> colors) {
//     return Container(
//       height: 8,
//       margin: const EdgeInsets.only(top: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE5E5EA),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(4),
//         child: TweenAnimationBuilder<double>(
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeOutCubic,
//           tween: Tween<double>(
//             begin: 0.0,
//             end: progress / 100,
//           ),
//           builder: (context, value, child) {
//             return Stack(
//               children: [
//                 FractionallySizedBox(
//                   widthFactor: value,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: colors,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFallbackIcon() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             const Color(0xFF007AFF).withOpacity(0.15),
//             const Color(0xFF0051D5).withOpacity(0.05),
//           ],
//         ),
//       ),
//       child: Center(
//         child: Icon(
//           CupertinoIcons.book_fill,
//           size: 48,
//           color: const Color(0xFF007AFF).withOpacity(0.4),
//         ),
//       ),
//     );
//   }
// }