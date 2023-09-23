import 'package:first_priority_app/controllers/account.dart';
import 'package:first_priority_app/controllers/school.dart';
import 'package:first_priority_app/dashboard/controller/MainDashboardController.dart';
import 'package:first_priority_app/more/account/account_screen.dart';
import 'package:first_priority_app/more/notifications_screen.dart';
import 'package:first_priority_app/more/settings/settings_screen.dart';
import 'package:first_priority_app/notifiers/theme_notifier.dart';
import 'package:first_priority_app/widgets/policy_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreItem {
  final String name;
  final Icon icon;
  final Function(BuildContext) action;

  MoreItem({
    this.name,
    this.icon,
    this.action,
  });
}

class MoreScreen extends StatelessWidget {
  MoreScreen({Key key}) : super(key: key);

  final _screens = [
    MoreItem(
      name: "Notifications",
      icon: Icon(Icons.notifications),
      action: (_) => Get.to(() => NotificationsScreen()),
    ),
    MoreItem(
      name: "Settings",
      icon: Icon(Icons.settings),
      action: (_) => Get.to(() => SettingsScreen()),
    ),
    MoreItem(
      name: "Account",
      icon: Icon(Icons.person),
      action: (_) => Get.to(() => AccountScreen()),
    ),
    if (Policy.validate(Policy.switchClub))
      MoreItem(
        name: "Switch Club",
        icon: Icon(Icons.swap_horiz),
        action: (_) async {
          final schoolController = Get.find<SchoolController>();
          final mainDashboardController = Get.find<MainDashboardController>();

          mainDashboardController.currentIndex.value = 0;
          await schoolController.setSchool(null);
        },
      ),
    MoreItem(
      name: "Website",
      icon: Icon(Icons.public),
      action: (context) async {
        final url = dotenv.env['WEBSITE_URL'];
        await canLaunch(url)
            ? await launch(url)
            : ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not launch $url'),
                ),
              );
      },
    ),
    MoreItem(
      name: "Logout",
      icon: Icon(Icons.logout),
      action: (context) async {
        final accountController = Get.find<AccountController>();
        final mainDashboardController = Get.find<MainDashboardController>();

        Provider.of<ThemeNotifier>(context, listen: false).setTheme(null);
        mainDashboardController.currentIndex.value = 0;
        await accountController.logout();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ListView.separated(
          shrinkWrap: true,
          itemCount: _screens.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: _screens[index].icon,
              title: Text(_screens[index].name),
              onTap: () async {
                _screens[index].action(context);
              },
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
        Container(
          margin: EdgeInsets.all(8),
          child: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("Loading...");
              }

              return Text("v${snapshot.data.version}");
            },
          ),
        )
      ],
    );
  }
}
