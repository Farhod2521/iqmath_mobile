import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../generated/l10n.dart';

class FilterBtmSheet extends StatefulWidget {
  const FilterBtmSheet({Key? key}) : super(key: key);

  @override
  State<FilterBtmSheet> createState() => _FilterBtmSheetState();
}

class _FilterBtmSheetState extends State<FilterBtmSheet> {
  var _selectedFilterName = '';

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return SafeArea(
      minimum: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localization.filter,
                style: context.textStyle.fontSize18FontWeight700,
              ),
              SizedBox.fromSize(
                size: const Size.square(24),
                child: SvgPicture.asset(
                  Assets.svgCrossSmall,
                  color: context.color.blackWhiteColor,
                ),
              ),
            ],
          ),
          const Gap(30),
          Expanded(
            child: ListView.separated(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filters[index].name,
                    style: context.textStyle.fontSize16FontWeight700,
                  ),
                  const Gap(16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    children: List.generate(
                      filters[index].filters.length,
                      (innerIndex) => FilterItemWidget(
                        name: filters[index].filters[innerIndex].name,
                        isSelected: _selectedFilterName ==
                            filters[index].filters[innerIndex].name,
                        onTap: () {
                          setState(() {
                            _selectedFilterName =
                                filters[index].filters[innerIndex].name;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              separatorBuilder: (_, __) => const Gap(30),
              itemCount: filters.length,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(localization.apply),
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: context.color.bg1,
              foregroundColor: context.color.primaryColor1,
              side: BorderSide(
                color: context.color.primaryColor1,
              ),
            ),
            child: Text(localization.clear),
          ),
        ],
      ),
    );
  }
}

class FilterItemWidget extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterItemWidget(
      {Key? key,
      required this.name,
      required this.isSelected,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? context.color.primaryColor1 : null,
              border: isSelected
                  ? null
                  : Border.all(
                      color: context.color.blackWhiteColor,
                    ),
            ),
            child: Text(
              name,
              style: context.textStyle.fontSize14FontWeight500.copyWith(
                color: isSelected ? context.color.bg1 : context.color.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final filters = <CategoryFilter>[
  CategoryFilter("Сортировать", [
    FilterItem("Рейтингу"),
    FilterItem("Популярности"),
    FilterItem("Новые"),
    FilterItem("Рекомендуемые"),
    FilterItem("Открыто сейчас"),
  ]),
  CategoryFilter("Кухни", [
    FilterItem("Все"),
    FilterItem("Азиатское"),
    FilterItem("Национальное"),
    FilterItem("Европейское"),
    FilterItem("Уйгурское"),
    FilterItem("Итальянское"),
    FilterItem("Французское"),
  ]),
  CategoryFilter("Средний чек", [
    FilterItem("до 500 000 сум"),
    FilterItem("от 1 000 000 сум"),
    FilterItem("от 2 000 000 сум"),
    FilterItem("от 5 000 000 сум"),
  ]),
];

class CategoryFilter {
  final String name;
  final List<FilterItem> filters;

  CategoryFilter(this.name, this.filters);
}

class FilterItem {
  final String name;

  FilterItem(this.name);
}
