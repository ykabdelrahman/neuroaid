// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:neuroaid/src/features/stroke_assessment/cubit/stroke_assessment_cubit.dart';
// import 'package:neuroaid/src/features/stroke_assessment/cubit/stroke_assessment_state.dart';
// import 'package:neuroaid/src/features/stroke_assessment/services/stroke_assessment_service.dart';
// import '../../core/services/api_service.dart';

// /// Stroke Assessment Screen
// /// Interactive Yes/No questionnaire for stroke risk prediction
// ///
// /// This screen:
// /// - Displays ONE question at a time
// /// - Shows YES/NO buttons only
// /// - Automatically moves to next question on answer
// /// - Submits to backend after last question
// /// - Displays ONLY the risk category from backend
// class StrokeAssessmentScreen extends StatelessWidget {
//   const StrokeAssessmentScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) {
//         // Create service and cubit
//         final apiService = GetIt.instance.get<ApiService>();
//         final service = StrokeAssessmentService(apiService);
//         final cubit = StrokeAssessmentCubit(service);

//         // Auto-start the assessment
//         cubit.startAssessment();

//         return cubit;
//       },
//       child: const _StrokeAssessmentView(),
//     );
//   }
// }

// class _StrokeAssessmentView extends StatelessWidget {
//   const _StrokeAssessmentView();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Stroke Risk Assessment',
//           style: TextStyle(
//             color: Color(0xFF1E293B),
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: BlocBuilder<StrokeAssessmentCubit, StrokeAssessmentState>(
//         builder: (context, state) {
//           // Initial state - should not be visible as we auto-start
//           if (state is StrokeAssessmentInitial) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           // Questionnaire in progress
//           if (state is StrokeAssessmentInProgress) {
//             return _QuestionView(state: state);
//           }

//           // Submitting to backend
//           if (state is StrokeAssessmentSubmitting) {
//             return _LoadingView();
//           }

//           // Assessment completed
//           if (state is StrokeAssessmentCompleted) {
//             return _ResultView(state: state);
//           }

//           // Error occurred
//           if (state is StrokeAssessmentError) {
//             return _ErrorView(state: state);
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }

// /// Question View - Shows one question with YES/NO buttons
// class _QuestionView extends StatelessWidget {
//   final StrokeAssessmentInProgress state;

//   const _QuestionView({required this.state});

//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<StrokeAssessmentCubit>();
//     final questionText = cubit.getCurrentQuestionText();
//     final progress = state.progress;
//     final questionNumber = state.currentQuestionIndex + 1;
//     final totalQuestions = cubit.totalQuestions;

//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Progress indicator
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Question $questionNumber of $totalQuestions',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF64748B),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       '${(progress * 100).toInt()}%',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF3B82F6),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     minHeight: 8,
//                     backgroundColor: const Color(0xFFE2E8F0),
//                     valueColor: const AlwaysStoppedAnimation<Color>(
//                       Color(0xFF3B82F6),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 48),

//             // Question card
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(32),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 20,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Question icon
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF3B82F6).withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.help_outline,
//                         size: 40,
//                         color: Color(0xFF3B82F6),
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Question text
//                     Text(
//                       questionText,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1E293B),
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),

//             // YES/NO buttons
//             Row(
//               children: [
//                 // NO button
//                 Expanded(
//                   child: _AnswerButton(
//                     label: 'NO',
//                     color: const Color(0xFFEF4444),
//                     onPressed: () => cubit.answerQuestion(0),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 // YES button
//                 Expanded(
//                   child: _AnswerButton(
//                     label: 'YES',
//                     color: const Color(0xFF10B981),
//                     onPressed: () => cubit.answerQuestion(1),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Answer Button Widget
// class _AnswerButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final VoidCallback onPressed;

//   const _AnswerButton({
//     required this.label,
//     required this.color,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: color,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           height: 64,
//           alignment: Alignment.center,
//           child: Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Loading View - Shown while submitting to backend
// class _LoadingView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(
//             strokeWidth: 3,
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Analyzing your responses...',
//             style: TextStyle(
//               fontSize: 16,
//               color: Color(0xFF64748B),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Result View - Shows the risk assessment result
// class _ResultView extends StatelessWidget {
//   final StrokeAssessmentCompleted state;

//   const _ResultView({required this.state});

//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<StrokeAssessmentCubit>();

//     // Determine color based on risk level
//     Color getRiskColor() {
//       switch (state.riskLevel.toLowerCase()) {
//         case 'low':
//           return const Color(0xFF10B981);
//         case 'medium':
//         case 'moderate':
//           return const Color(0xFFF59E0B);
//         case 'high':
//           return const Color(0xFFEF4444);
//         default:
//           return const Color(0xFF64748B);
//       }
//     }

//     IconData getRiskIcon() {
//       switch (state.riskLevel.toLowerCase()) {
//         case 'low':
//           return Icons.check_circle_outline;
//         case 'medium':
//         case 'moderate':
//           return Icons.warning_amber_outlined;
//         case 'high':
//           return Icons.error_outline;
//         default:
//           return Icons.info_outline;
//       }
//     }

//     final riskColor = getRiskColor();
//     final riskIcon = getRiskIcon();

//     return SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Result card
//             Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 20,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   // Risk icon
//                   Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: riskColor.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(riskIcon, size: 50, color: riskColor),
//                   ),

//                   const SizedBox(height: 24),

//                   // Risk level badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: riskColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       state.riskLevel.toUpperCase(),
//                       style: TextStyle(
//                         color: riskColor,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Display message (ONLY from backend)
//                   Text(
//                     state.displayMessage,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1E293B),
//                       height: 1.5,
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Supportive closing sentence
//                   Text(
//                     'Remember, this assessment is for informational purposes only and does not replace professional medical advice.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: const Color(0xFF64748B),
//                       height: 1.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Recommendations section (if available)
//             if (state.recommendations.isNotEmpty) ...[
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 20,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Recommendations',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1E293B),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     ...state.recommendations
//                         .take(5)
//                         .map(
//                           (rec) => Padding(
//                             padding: const EdgeInsets.only(bottom: 12),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Icon(
//                                   Icons.check_circle,
//                                   size: 20,
//                                   color: Color(0xFF3B82F6),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     rec,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Color(0xFF475569),
//                                       height: 1.5,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],

//             // Action buttons
//             const SizedBox(height: 12),

//             OutlinedButton(
//               onPressed: () => Navigator.of(context).pop(),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: const Color(0xFF3B82F6),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 side: const BorderSide(color: Color(0xFF3B82F6)),
//               ),
//               child: const Text(
//                 'Back to Home',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Error View - Shows error message
// class _ErrorView extends StatelessWidget {
//   final StrokeAssessmentError state;

//   const _ErrorView({required this.state});

//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<StrokeAssessmentCubit>();

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 80, color: Color(0xFFEF4444)),
//             const SizedBox(height: 24),
//             const Text(
//               'Something went wrong',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1E293B),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               state.errorMessage,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: () => cubit.resetAssessment(),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF3B82F6),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32,
//                   vertical: 16,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Try Again',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
