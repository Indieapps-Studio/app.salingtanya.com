import 'dart:math';

import 'package:app_salingtanya/models/question.dart';
import 'package:app_salingtanya/models/question_category.dart';
import 'package:app_salingtanya/utils/constants.dart';
import 'package:app_salingtanya/utils/exceptions.dart';
import 'package:app_salingtanya/utils/wrappers/error_wrapper.dart';
import 'package:appwrite/appwrite.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionsRepository {
  final db = GetIt.I<Database>();

  Future createQuestion(String question, List<String> categoryIds) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await ErrorWrapper.guard(
      () => db.createDocument(
        collectionId: kQuestionsCollectionId,
        documentId: 'unique()',
        data: <String, dynamic>{
          'value': question,
          'category_ids': categoryIds,
          'created_at': now.toIso8601String(),
          'language': prefs.getString(kDefaultLanguage) ?? 'id'
        },
      ),
      onError: (e) => throw ExceptionWithMessage(e.toString()),
    );
  }

  Future<Question> getQuestion(String questionId) async {
    final result = await ErrorWrapper.guard(
      () => db.getDocument(
        collectionId: kQuestionsCollectionId,
        documentId: questionId,
      ),
      onError: (e) => throw ExceptionWithMessage(e.toString()),
    );

    return Question.fromJson(result.data);
  }

  Future<List<Question>> getQuestions({required bool isPopular}) async {
    final prefs = await SharedPreferences.getInstance();
    final result = await ErrorWrapper.guard(
      () => db.listDocuments(
        collectionId: kQuestionsCollectionId,
        queries: <dynamic>[
          Query.equal('language', prefs.getString(kDefaultLanguage) ?? 'id'),
          if (isPopular) Query.greaterEqual('used_count', 10),
        ],
        orderTypes: <String>['DESC'],
        orderAttributes: <String>[if (isPopular) 'used_count'],
      ),
      onError: (e) => throw ExceptionWithMessage(e.toString()),
    );

    return result.documents.map((e) => Question.fromJson(e.data)).toList();
  }

  Future<List<QuestionCategory>> getQuestionCategories() async {
    final result = await ErrorWrapper.guard(
      () => db.listDocuments(collectionId: kQuestionCategoriesCollectionId),
      onError: (e) => throw ExceptionWithMessage(e.toString()),
    );

    return result.documents
        .map((e) => QuestionCategory.fromJson(e.data))
        .toList();
  }

  String getRandomQuestionId(List<String> questionIds) {
    final random = Random();
    final index = random.nextInt(questionIds.length);

    return questionIds[index];
  }
}
