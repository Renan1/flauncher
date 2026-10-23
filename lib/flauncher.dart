/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


import 'package:flauncher/custom_traversal_policy.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/apps_grid.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/launcher_alternative_view.dart';
import 'package:flauncher/widgets/focus_aware_app_bar.dart';
import 'package:flauncher/widgets/sky_background.dart';
import 'package:flauncher/perfil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models/category.dart';

class FLauncher extends StatelessWidget {
  const FLauncher();

  @override
  Widget build(BuildContext context) => FocusTraversalGroup(
    policy: RowByRowTraversalPolicy(),
    child: Stack(
      children: [
        Consumer<WallpaperService>(
          builder: (_, wallpaperService, __) => _wallpaper(context, wallpaperService)
        ),
        Consumer<LauncherState>(
          builder: (_, state, child) => Visibility(
            child: child!,
            replacement: const Center(
              child: AlternativeLauncherView()
            ),
            visible: state.launcherVisible
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: FocusAwareAppBar(),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Consumer<AppsService>(
                builder: (context, appsService, _) {
                  if (appsService.initialized) {
                    return SingleChildScrollView(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_greeting(context), _sections(appsService.launcherSections)]
                    ));
                  }
                  else {
                    return _emptyState(context);
                  }
                }
              )
            )
          )
        )
      ]
    )
  );

  Widget _sections(List<LauncherSection> sections) => Column(
    children: sections.map((section) {
      final Key sectionKey = Key(section.id.toString());
      final Widget categoryWidget;

      if (section is LauncherSpacer) {
        return SizedBox(key: sectionKey, height: section.height.toDouble());
      }

      Category category = section as Category;
      switch (category.type) {
        case CategoryType.row:
          categoryWidget = CategoryRow(
              key: sectionKey,
              category: category,
              applications: category.applications
          );
        case CategoryType.grid:
          categoryWidget = AppsGrid(
              key: sectionKey,
              category: category,
              applications: category.applications
          );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: categoryWidget
      );
    }).toList(),
  );

  Widget _greeting(BuildContext context) {
    const shadows = [Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 8)];
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      // Reconstrói a cada minuto para a saudação acompanhar o horário
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(minutes: 1)),
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(saudacao(DateTime.now()), style: textTheme.displaySmall!.copyWith(color: Colors.white, shadows: shadows)),
            const SizedBox(height: 4),
            Text(subtitulo, style: textTheme.titleLarge!.copyWith(color: Colors.white70, shadows: shadows)),
          ]
        )
      )
    );
  }

  Widget _wallpaper(BuildContext context, WallpaperService wallpaperService) {
    if (wallpaperService.wallpaper != null) {
      final physicalSize = MediaQuery.sizeOf(context);
      return Image(
        image: wallpaperService.wallpaper!,
        key: const Key("background"),
        fit: BoxFit.cover,
        height: physicalSize.height,
        width: physicalSize.width
      );
    }
    else {
      return const SkyBackground(key: Key("background"));
    }
  }

  Widget _emptyState(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(localizations.loading, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
