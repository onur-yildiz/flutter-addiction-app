import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quittle/extensions/string_extension.dart';
import 'package:quittle/main.dart';
import 'package:quittle/models/addiction.dart';
import 'package:quittle/providers/addictions_provider.dart';
import 'package:quittle/providers/settings_provider.dart';
import 'package:quittle/screens/create_addiction_screen.dart';
import 'package:quittle/util/achievement_constants.dart';
import 'package:quittle/util/quotes_constants.dart';
import 'package:quittle/widgets/addiction_item_card.dart';
import 'package:quittle/widgets/settings_view.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;

class AddictionsScreen extends StatefulWidget {
  static const routeName = '/addictions';

  @override
  _AddictionsScreenState createState() => _AddictionsScreenState();
}

class _AddictionsScreenState extends State<AddictionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<void> _fetchData() async {
    await Provider.of<AddictionsProvider>(context, listen: false)
        .fetchAddictions();
    return Provider.of<SettingsProvider>(context, listen: false)
        .fetchSettings();
  }

  _setProgNotifTasks(List<Addiction> addictions) {
    if (Provider.of<SettingsProvider>(context, listen: false)
        .receiveProgressNotifs) {
      for (var addiction in addictions) {
        if (addiction.level < getAchievementDurations.length - 1) {
          Workmanager.registerPeriodicTask(
            addiction.id,
            'progress-notification',
            inputData: {
              'id': addiction.id,
              'locale': AppLocalizations.of(context).localeName,
            },
            frequency: Duration(minutes: 15),
            existingWorkPolicy: ExistingWorkPolicy.replace,
          );
        } else {
          Workmanager.cancelByUniqueName(addiction.id);
        }
      }
    }
  }

  void _setDailyQuoteNotification() {
    final today = DateTime.now();
    final tomorrowMorning =
        DateTime(today.year, today.month, (today.day + 1), 9, 0, 0);
    final timeTillTomorrowMorning = tomorrowMorning.difference(today);
    if (Provider.of<SettingsProvider>(context, listen: false)
        .receiveQuoteNotifs) {
      Workmanager.registerPeriodicTask(
        'quote-notification',
        'quote-notification',
        inputData: {
          'locale': AppLocalizations.of(context).localeName,
        },
        initialDelay: timeTillTomorrowMorning,
        frequency: Duration(days: 1),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
    } else {
      Workmanager.cancelByUniqueName('quote-notification');
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: Consumer<AddictionsProvider>(
        child: FloatingActionButton(
          heroTag: 'newAddiction',
          onPressed: () {
            Navigator.of(context).pushNamed(CreateAddictionScreen.routeName);
          },
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: 'New',
          child: Icon(Icons.add),
        ),
        builder: (_, addictionsData, child) {
          return addictionsData.addictions.length == 0
              ? SizedBox()
              : SizedBox(
                  child: child,
                );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Builder(
        builder: (context) => BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                color: Theme.of(context).primaryColor,
                tooltip: 'Menu',
                icon: Icon(Icons.menu),
              ),
            ],
          ),
        ),
      ),
      drawer: SettingsView(),
      body: FutureBuilder(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.error != null) {
              return Center(
                child: Text(local.genericErrorMessage.capitalizeFirstLetter()),
              );
            }
            _setDailyQuoteNotification();
            return Consumer<AddictionsProvider>(
                builder: (ctx, addictionsData, child) {
              _setProgNotifTasks(addictionsData.addictions);
              return RefreshIndicator(
                onRefresh: () async {
                  await addictionsData.fetchAddictions();
                },
                child: addictionsData.addictions.length > 0
                    ? ListView.builder(
                        itemCount: addictionsData.addictions.length,
                        itemBuilder: (ctx, index) {
                          return AddictionItem(
                            addictionData: addictionsData.addictions[index],
                          );
                        },
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(CreateAddictionScreen.routeName);
                        },
                        splashColor: Theme.of(context).accentColor,
                        child: Container(
                          height: deviceSize.height,
                          width: deviceSize.width,
                          child: Center(
                            child: SizedBox.fromSize(
                              size: Size.square(deviceSize.width * .5),
                              child: FloatingActionButton(
                                heroTag: 'newAddiction',
                                elevation: 0,
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Theme.of(context).canvasColor,
                                child: Icon(
                                  Icons.add,
                                  size: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      .fontSize,
                                ),
                                onPressed: null,
                              ),
                            ),
                          ),
                        ),
                      ),
              );
            });
          }
        },
      ),
    );
  }
}
