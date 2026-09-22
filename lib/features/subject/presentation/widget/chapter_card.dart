import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/topic_card.dart';

import '../../data/models/chapter_model.dart';

class ChapterCard extends StatefulWidget {
  final ChapterModel chapter;
  final String subjectName;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.subjectName,
  });

  @override
  State<ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<ChapterCard> {
  bool _isPressed = false;

  void _handleTap() {
    ChapterTopicsSheet.show(
      context,
      widget.chapter,
      widget.subjectName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _handleTap();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: _isPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // widget.chapter.nameUz,
                                    BaseFunctions.getLanguageText(
                                      languageCode: state.appLocale,
                                      uz: widget.chapter.nameUz,
                                      ru: widget.chapter.nameRu,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.black,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        widget.chapter.progress > 0
                                            ? CupertinoIcons
                                                .checkmark_circle_fill
                                            : CupertinoIcons.circle,
                                        size: 16,
                                        color: widget.chapter.progress > 0
                                            ? widget.chapter.progressColor
                                            : CupertinoColors.systemGrey3,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${widget.chapter.progressPercent != 0.0 ? widget.chapter.progressPercent : 0}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: widget.chapter.progress > 0
                                              ? widget.chapter.progressColor
                                              : CupertinoColors.systemGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                CupertinoIcons.chevron_right,
                                size: 18,
                                color: CupertinoColors.systemGrey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress bar - har doim ko'rinadi
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F2F7),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (widget.chapter.progress / 100).clamp(0.0, 1.0),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: widget.chapter.progressColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// {
// "question": [
// {
// "index": 1,
// "question_id": 4649,
// "question_uz": "<p>Shunday son yozingki, unda quyidagi xona birliklari bo‘lsin:</p><p>5 ta yuz, 2 ta o‘n, 4 ta bir;</p>",
// "question_ru": "<p>Запишите число, имеющее следующие единицы измерения:</p><p>5 сотен, 2 десятка, 4 единицы.</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 2,
// "question_id": 4650,
// "question_uz": "<p>3 299 999 sonidan bitta ko‘p bo‘lgan natural sonni ayting</p>",
// "question_ru": "<p>Назовите натуральное число, которое на единицу больше 3299999.</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 3,
// "question_id": 4651,
// "question_uz": "<p>Shunday son yozingki, unda quyidagi xona birliklari bolsin:</p><p>3 ta yuz, 9 ta o‘n, 2 ta bir;</p>",
// "question_ru": "<p>Запишите число так, чтобы оно имело следующие единицы измерения:</p><p>8 тысяч, 3 сотни, 9 десятков, 2 единицы.</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 4,
// "question_id": 4652,
// "question_uz": "<p>Sonlarni o‘nli yozuv jadvalidan foydalanib raqamlar bilan yozing: uch ming to‘rt yuz qirq bir</p>",
// "question_ru": "<p>Запишите число в цифрах: три тысячи четыреста сорок один.</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 5,
// "question_id": 4653,
// "question_uz": "<p>Nurali&nbsp; cho‘ponda&nbsp;123&nbsp; ta,&nbsp; Sherali&nbsp;cho‘ponda&nbsp; esa&nbsp; undan&nbsp;45&nbsp; ta&nbsp; ko‘p&nbsp;qo‘y&nbsp; bor.&nbsp;</p><p>Ikkala cho‘ponda jami nechta qo‘y bor?</p>",
// "question_ru": "<p>У пастуха Нурали 123 овцы, а у пастуха Шерали на 45 овец больше. Сколько овец у обоих пастухов?</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 6,
// "question_id": 4657,
// "question_uz": "<p>Raqamlar bilan yozing:</p><p>102 mlrd;&nbsp;&nbsp;</p>",
// "question_ru": "<p>Напишите цифрами:</p><p>102 миллиарда;</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 7,
// "question_id": 4658,
// "question_uz": "<p>Raqamlar bilan yozing:</p><p>12 mlrd 203 mln 2 ming.</p>",
// "question_ru": "<p>Напишите цифрами:</p><p>12 миллиардов 203 миллиона 2 тысячи.</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 8,
// "question_id": 4660,
// "question_uz": "<p>Ifodaning qiymatini toping:&nbsp;</p><p>2*2+2+2+2+2+2*2</p>",
// "question_ru": "<p>Найдите значение выражения:&nbsp;</p><p>2*2+2+2+2+2+2*2</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 9,
// "question_id": 4661,
// "question_uz": "<p>Do‘konda har biri 2000 so‘mdan &nbsp;7 ta qoshiq va har biri 1500 so‘mdan 10 ta sanchqi sotib oldi. Hammasi bo‘lib necha so‘m</p>",
// "question_ru": "<p>В магазине было куплено 7 ложек по 2000 сумов каждая и 10 вилок по 1500 сумов каждая. Сколько всего заплатили?</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 10,
// "question_id": 4663,
// "question_uz": "<p>Kolibri qushi bir daqiqada o'rtacha 240 marta nafas olsa, sekundda necha marta nafas oladi?</p>",
// "question_ru": "<p>Если колибри дышит в среднем 240 раз в минуту, сколько раз в секунду она дышит?</p>",
// "answer": false,
// "answer_text": "\\(12\\)"
// },
// {
// "index": 11,
// "question_id": 4654,
// "question_uz": "<p>Shahardan Obod qishlog‘igacha bo‘lgan yo‘l 23 km&nbsp; bo lib,&nbsp; u shahardan Ozod qishlog‘igacha&nbsp; bo‘lgan&nbsp;yo‘ldan&nbsp; 4&nbsp; km&nbsp;uzun.&nbsp; Shahardan&nbsp; Ozod&nbsp;qishlog‘igacha bo‘lgan yo‘l necha kilometr?</p>",
// "question_ru": "<p>Длина дороги от города до села Абад составляет 23 км, что на 4 км длиннее дороги от города до села Озод. Определите длинну дороги от города до деревни Озод.</p>",
// "answer": false,
// "sub_answers": [
// "12"
// ]
// },
// {
// "index": 12,
// "question_id": 4655,
// "question_uz": "<p>Avtobusda 46 ta yo‘lovchi bor edi. Bekatda 4 kishi avtobusdan tushdi, 8 kishi esa avtobusdan chiqdi. Shundan so‘ng avtobusda nechta yo‘lovchi bo‘ldi&nbsp;</p>",
// "question_ru": "<p>В автобусе находились 46 пассажиров. На вокзале из автобуса вышли 4 человека и зашли 8 человек. Сколько человек стало в автобусе.</p>",
// "answer": false,
// "sub_answers": [
// "12"
// ]
// },
// {
// "index": 13,
// "question_id": 4656,
// "question_uz": "<p>To‘g‘ri to‘rtburchakning bo‘yi 25 sm, eni 20 sm. Uning peremetrini toping.</p>",
// "question_ru": "<p>Высота прямоугольника 25 см, ширина 20 см. Найдите его периметр</p>",
// "answer": false,
// "sub_answers": [
// "12"
// ]
// },
// {
// "index": 14,
// "question_id": 4659,
// "question_uz": "<p>MATEMATIKA va&nbsp;INFORMATKA so‘zlarida nechta umumiy harf bor?</p>",
// "question_ru": "<p>Сколько общих букв в словах МАТЕМАТИКА и ИНФОРМАТИКА?</p>",
// "answer": false,
// "sub_answers": [
// "12"
// ]
// },
// {
// "index": 15,
// "question_id": 4662,
// "question_uz": "<p>Kalendarda 2023-yil ko'rsatilgan. Ma'lumki, uning raqamlari yig'indisi 7 ga teng. Yana qancha vaqtdan keyin shunday yil keladi?</p>",
// "question_ru": "<p>На календаре указан 2023 год. Известно, что сумма его чисел равна 7. Через сколько лет наступит такой же год?</p>",
// "answer": false,
// "sub_answers": [
// "12"
// ]
// }
// ],
// "result": [
// {
// "total_answers": 15,
// "correct_answers": 0,
// "score": 0.0
// }
// ],
// "info": {
// "topic": {
// "id": 385
// },
// "chapter": {
// "id": 9
// },
// "subject": {
// "id": 2
// }
// },
// "level": 1
// }
