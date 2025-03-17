import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/feedback_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_inputs.dart';
import '../../widgets/utility_widgets.dart';
import '../../utils/app_utils.dart';

class FeedbackFormScreen extends StatefulWidget {
  final String queueId;

  const FeedbackFormScreen({
    super.key,
    required this.queueId,
  });

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _canSubmit = true;

  @override
  void initState() {
    super.initState();
    _checkCanSubmitFeedback();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkCanSubmitFeedback() async {
    try {
      final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      final canSubmit = await feedbackProvider.canSubmitFeedback(
        int.parse(widget.queueId),
      );

      setState(() {
        _canSubmit = canSubmit;
      });

      if (!canSubmit && mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Anda sudah memberikan penilaian untuk antrian ini',
          isError: true,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.toString(),
          isError: true,
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      CustomSnackBar.show(
        context: context,
        message: 'Silakan berikan penilaian bintang',
        isError: true,
      );
      return;
    }

    try {
      final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      await feedbackProvider.submitFeedback(
        queueId: int.parse(widget.queueId),
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Terima kasih atas penilaian Anda!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.toString(),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Berikan Penilaian',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bagaimana pelayanan kami?',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                'Berikan penilaian dan masukan Anda untuk membantu kami meningkatkan pelayanan',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Rating Stars
              Center(
                child: Column(
                  children: [
                    RatingBar.builder(
                      initialRating: _rating.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 48,
                      unratedColor: AppColors.divider,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: AppColors.warning,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _rating > 0
                          ? AppUtils.getRatingText(_rating)
                          : 'Ketuk bintang untuk memberi nilai',
                      style: AppTextStyles.subtitle1.copyWith(
                        color: _rating > 0
                            ? AppUtils.getRatingColor(_rating)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Comment Field
              CustomTextField(
                label: 'Komentar (Opsional)',
                hint: 'Berikan komentar atau saran Anda...',
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // Submit Button
              PrimaryButton(
                text: 'Kirim Penilaian',
                onPressed: _handleSubmit,
                isLoading: feedbackProvider.loading,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
