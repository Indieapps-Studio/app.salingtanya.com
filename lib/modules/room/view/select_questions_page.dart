import 'package:app_salingtanya/modules/room/view/detail_room_page.dart';
import 'package:app_salingtanya/modules/top_level_providers.dart';
import 'package:app_salingtanya/utils/extensions/widget_extension.dart';
import 'package:app_salingtanya/widgets/list_category/view/list_question_category_widget.dart';
import 'package:app_salingtanya/widgets/list_question/widget/create_question_widget.dart';
import 'package:app_salingtanya/widgets/list_question/widget/list_question_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectQuestionsPage extends StatelessWidget {
  const SelectQuestionsPage({Key? key, required this.roomId}) : super(key: key);

  final String roomId;

  Future _onSubmitted(BuildContext context, WidgetRef ref) async {
    final selectedQuestions = ref.watch(selectedQuestionsProvider);

    FocusScope.of(context).unfocus();

    await ref
        .read(updateDetailRoomProvider.notifier)
        .updateQuestions(roomId, selectedQuestions);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('rooms.select_questions').tr(),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isHasAnySelected =
                  ref.watch(selectedQuestionsProvider).isNotEmpty;

              final updateQuestions = ref.watch(updateDetailRoomProvider);

              if (isHasAnySelected) {
                return updateQuestions.maybeWhen(
                  orElse: () => IconButton(
                    onPressed: () => _onSubmitted(context, ref),
                    icon: const Icon(Icons.check),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: () {
          final controller = TextEditingController();
          CreateQuestionWidget(controller: controller)
              .showCustomDialog<void>(context);
        },
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: const Text(
                  'rooms.questions_by_category',
                  style: TextStyle(fontSize: 24),
                ).tr(),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 16),
              sliver: ListQuestionCategoryWidget(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: const Text(
                  'dashboard.popular_questions',
                  style: TextStyle(fontSize: 24),
                ).tr(),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 16),
              sliver: ListQuestionWidget(isPopular: true, isSelectable: true),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'rooms.latest_added_questions',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 16),
              sliver: ListQuestionWidget(
                isPopular: false,
                isGrid: true,
                isSelectable: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
