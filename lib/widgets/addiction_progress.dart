import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quit_addiction_app/extensions/string_extension.dart';
import 'package:flutter_quit_addiction_app/models/addiction.dart';
import 'package:flutter_quit_addiction_app/providers/settings_provider.dart';
import 'package:flutter_quit_addiction_app/widgets/target_duration_indicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddictionProgress extends StatelessWidget {
  const AddictionProgress({
    Key key,
    @required this.addictionData,
  }) : super(key: key);

  final Addiction addictionData;

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final local = AppLocalizations.of(context);
    final consumptionType = (addictionData.consumptionType == 1)
        ? local.hour(addictionData.notUsedCount.toInt())
        : local.times(addictionData.notUsedCount.toInt());

    return Container(
      height: deviceHeight * .25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                flex: 1,
                child: Text(local.level.capitalizeWords() + '1'),
              ),
              Flexible(
                flex: 3,
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6.fontSize,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                  child: addictionData.unitCost == 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(local.savedFor.capitalizeFirstLetter()),
                            Text(
                              addictionData.consumptionType == 0
                                  ? addictionData.notUsedCount
                                      .toStringAsFixed(2)
                                  : addictionData.notUsedCount
                                          .toStringAsFixed(0) +
                                      ' ' +
                                      consumptionType,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              local.moneySaved.capitalizeWords(),
                            ),
                            Consumer<SettingsProvider>(
                              builder: (_, settings, _ch) => Text(
                                NumberFormat.currency(
                                  name: settings.currency,
                                  symbol: settings.currency,
                                ).format(
                                  addictionData.unitCost *
                                      addictionData.notUsedCount,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          TargetDurationIndicator(duration: addictionData.abstinenceTime),
        ],
      ),
    );
  }
}
