import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/utils/utils.dart';

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

  TextSpan _buildClickableTextSpan(
      {required String text, required String url}) {
    return TextSpan(
      text: text,
      style: Typography.body3.merge(const TextStyle(
        color: DarkTheme.mainRed,
      )),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          openUrl(url: url);
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: DarkTheme.generalWhite,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: DarkTheme.mainBlack,
        // padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              CupertinoIcons.arrow_left,
              size: 24,
              color: DarkTheme.generalWhite,
            ),
          ),
        ),
        middle: Text(
          "О приложении",
          style: Typography.heading2
              .merge(const TextStyle(color: DarkTheme.generalWhite)),
          textAlign: TextAlign.center,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: const Image(
                      width: 280,
                      height: 180,
                      image: AssetImage('assets/images/1024.png'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Мониторинг обменных пунктов в Казахстане',
                      textAlign: TextAlign.center,
                      style: Typography.body2.merge(
                        const TextStyle(
                          color: DarkTheme.mainGrey,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Информация по курсам валют в обменных пунктах предоставляется ',
                            style: Typography.body3.merge(
                                const TextStyle(color: DarkTheme.mainGrey)),
                          ),
                          _buildClickableTextSpan(
                            text: '«TOO Cityinfo.kz»',
                            url: 'https://www.cityinfo.kz',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: DarkTheme.lightBg,
                    ),
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Версия приложения',
                            style: Typography.body3.merge(
                              const TextStyle(
                                color: DarkTheme.lightSecondary,
                              ),
                            ),
                          ),
                        ),
                        Text(
                            "v${_packageInfo.version} (${_packageInfo.buildNumber})"),
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(bottom: 8),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(8),
                  //     color: DarkTheme.lightBg,
                  //   ),
                  //   alignment: Alignment.centerLeft,
                  //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Container(
                  //         margin: EdgeInsets.only(bottom: 4),
                  //         child: Text(
                  //           'Разработка',
                  //           style: Typography.body3.merge(
                  //             TextStyle(
                  //               color: DarkTheme.lightSecondary,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Text("Roman Sadoyan"),
                  //     ],
                  //   ),
                  // ),
                  // Container(
                  //   margin: EdgeInsets.only(bottom: 32),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(8),
                  //     color: DarkTheme.lightBg,
                  //   ),
                  //   alignment: Alignment.centerLeft,
                  //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Container(
                  //         margin: EdgeInsets.only(bottom: 4),
                  //         child: Text(
                  //           'Дизайн',
                  //           style: Typography.body3.merge(
                  //             TextStyle(
                  //               color: DarkTheme.lightSecondary,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Text("Dmitry Avrov"),
                  //     ],
                  //   ),
                  // ),

                  // Container(
                  //   child: RichText(
                  //     textAlign: TextAlign.center,
                  //     text: TextSpan(
                  //       children: [
                  //         TextSpan(
                  //           text:
                  //               'По вопросам размещения информации пишите на почту ',
                  //           style: Typography.body3.merge(TextStyle(
                  //               color: DarkTheme.darkSecondary)),
                  //         ),
                  //         _buildClickableTextSpan(
                  //           text: 'info@cityinfo.kz',
                  //           url: 'mailto:info@cityinfo.kz',
                  //         ),
                  //         TextSpan(
                  //           text: ' или в WhatsApp  ',
                  //           style: Typography.body3.merge(TextStyle(
                  //               color: DarkTheme.darkSecondary)),
                  //         ),
                  //         _buildClickableTextSpan(
                  //           text: '+7-777-646-13-55',
                  //           url: 'https://wa.me/77776461355',
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
