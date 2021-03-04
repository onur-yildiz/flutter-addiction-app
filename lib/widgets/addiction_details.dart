import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quittle/extensions/string_extension.dart';

import 'package:quittle/models/addiction.dart';
import 'package:quittle/widgets/duration_counter.dart';
import 'package:intl/intl.dart';

class AddictionDetails extends StatefulWidget {
  const AddictionDetails({
    @required this.addictionData,
  });

  final Addiction addictionData;

  @override
  _AddictionDetailsState createState() => _AddictionDetailsState();
}

class _AddictionDetailsState extends State<AddictionDetails> {
  double notUsedCount;
  Duration abstinenceTime;
  String quitDateFormatted;

  @override
  void initState() {
    notUsedCount = widget.addictionData.notUsedCount;
    abstinenceTime = widget.addictionData.abstinenceTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    quitDateFormatted = DateFormat.yMMMd(local.localeName)
        .format(widget.addictionData.quitDateTime);
    final consumptionType = ((widget.addictionData.consumptionType == 1)
            ? local.hour(
                notUsedCount.toInt(),
              )
            : local.times(
                notUsedCount.toInt(),
              ))
        .capitalizeWords();

    return DefaultTextStyle(
      style: TextStyle(
        color: Theme.of(context).hintColor,
        fontWeight: FontWeight.bold,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 8.0,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(local.startDate.capitalizeWords()),
                Text(quitDateFormatted),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(local.duration.capitalizeWords()),
                DurationCounter(duration: abstinenceTime),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(local.dailyUse.capitalizeWords()),
                Text(
                  (widget.addictionData.dailyConsumption % 1 == 0
                          ? widget.addictionData.dailyConsumption
                              .toStringAsFixed(0)
                          : widget.addictionData.dailyConsumption.toString()) +
                      ' ' +
                      consumptionType,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
