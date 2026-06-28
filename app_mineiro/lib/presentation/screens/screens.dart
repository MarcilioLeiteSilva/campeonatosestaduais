import 'dart:async';

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:app_mineiro/helpers/helpers.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../logic/cubits/setting/setting_cubit.dart';
import '../widgets/widgets.dart';
import 'package:app_mineiro/services/data_loader.dart';
import 'package:app_mineiro/api/events_api.dart';
import 'package:app_mineiro/api/leagues_api.dart';
import 'package:app_mineiro/api/clubs_api.dart';
import 'package:app_mineiro/api/news_api.dart';

part 'splash.dart';
part 'user/welcome.dart';
part 'user/login.dart';
part 'user/register.dart';
part 'user/profile.dart';

part 'user/follow.dart';
part 'user/follow/teams.dart';
part 'user/follow/notification.dart';
part 'user/follow/leagues.dart';
part 'user/rest_pass.dart';

part 'home/fixture.dart';
part 'home/favourite.dart';
part 'home/watch.dart';
part 'home/news.dart';
part 'home/home.dart';
part 'home/account.dart';
part 'home/live.dart';
part 'home/search.dart';

part 'fixture/fixt_details.dart';
part 'fixture/info.dart';
part 'fixture/summary.dart';
part 'fixture/stats.dart';
part 'fixture/report.dart';
part 'fixture/lienups.dart';
part 'fixture/table.dart';
part 'fixture/h2h.dart';

part 'profile/league.dart';
part 'profile/team.dart';

part 'news/news_content.dart';
part 'news/watch_content.dart';

part 'settings/about_scora.dart';
part 'settings/edit_info.dart';
part 'settings/general.dart';
part 'settings/help_center.dart';
part 'settings/notification.dart';
part 'settings/security.dart';
