import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/widgets/list_tile_value.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_in_page.dart'
    show SignInPage;
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/my_points_page.dart'
    show MyPointsPage;
import 'package:provider/provider.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  static const routeName = '/about';

  @override
  State<AboutPage> createState() => _AboutPage();
}

class _AboutPage extends State<AboutPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final secondaryLabel = AppColors.secondaryLabel.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("О приложении")),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Column(
            children: [
              const Image(
                width: 280,
                height: 180,
                image: AssetImage('assets/images/1024.png'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Мониторинг обменных пунктов в Казахстане',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Информация по курсам валют в обменных пунктах предоставляется «TOO Cityinfo.kz»',
                      textAlign: TextAlign.center,
                      style: AppTypography.subheadline.copyWith(
                        color: secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoListSection.insetGrouped(
                margin: sectionMargin,
                hasLeading: false,
                children: [
                  CupertinoListTile(
                    title: const Text('Версия приложения'),
                    additionalInfo: ListTileValue(
                      "v${_packageInfo.version} (${_packageInfo.buildNumber})",
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text('Источник данных'),
                    additionalInfo: const ListTileValue('Cityinfo.kz'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => openUrl(url: 'https://www.cityinfo.kz'),
                  ),
                ],
              ),
              // The way into the cabinet for the few who need it, not advertised elsewhere.
              CupertinoListSection.insetGrouped(
                margin: sectionMargin,
                hasLeading: false,
                children: [
                  CupertinoListTile(
                    title: const Text('Для обменных пунктов'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.pushNamed(
                      context,
                      isAuthenticated
                          ? MyPointsPage.routeName
                          : SignInPage.routeName,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
