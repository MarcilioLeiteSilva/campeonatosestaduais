import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pattern_formatter/date_formatter.dart';
import 'package:app_mineiro/helpers/helpers.dart';
import 'package:app_mineiro/models/leagues.dart';
import 'package:app_mineiro/models/events.dart';
import 'package:app_mineiro/models/news.dart';
import 'package:app_mineiro/models/teams.dart';

import '../../logic/cubits/setting/setting_cubit.dart';
import 'package:app_mineiro/api/leagues_api.dart';
import 'package:app_mineiro/api/events_api.dart';
import 'package:app_mineiro/api/clubs_api.dart';

part 'user.dart';
part 'home.dart';
part 'fixture.dart';
part 'search.dart';
part 'events.dart';
part 'lienups.dart';
part 'competetion.dart';
part 'news.dart';
part 'team.dart';
part 'account.dart';
part 'drawer.dart';

