import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';

class MyPointsNavigationBar extends CupertinoNavigationBar {
  
  MyPointsNavigationBar({
    super.key,
    required String? userEmail,
    required Future<void> Function() onSignOut,
    required VoidCallback onAdd,
    required Color themePrimaryColor,
  }) : super(
         automaticallyImplyLeading: false,
         backgroundColor: AppDynamicColors.lightBg,
         leading: Builder(
           builder: (context) {
             return GestureDetector(
               child: Icon(
               CupertinoIcons.square_arrow_right,
                  color: themePrimaryColor,
               size: 24.0,
             ),
             onTap: () {
               showCupertinoModalPopup(
                 context: context,
                 builder: (context) => CupertinoActionSheet(
                   title: Text('Профиль пользователя'),
                   message: Text(userEmail ?? 'Не авторизован'),
                   actions: [
                     CupertinoActionSheetAction(
                       onPressed: () async {
                         Navigator.pop(context);
                         await onSignOut();
                       },
                       isDestructiveAction: true,
                       child: Text('Выйти'),
                     ),
                   ],
                   cancelButton: CupertinoActionSheetAction(
                     child: Text(
                       'Отмена',
                     ),
                     onPressed: () {
                       Navigator.pop(context);
                     },
                   ),
                 ),
               );
             },
             );
           },
         ),
         middle: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Text("Мои обменные пункты", style: Typography.heading2),
             if (userEmail != null)
               Text(
                 userEmail,
                 style: TextStyle(fontSize: 12, color: DarkTheme.darkSecondary),
               ),
           ],
         ),
         trailing: Builder(
           builder: (context) {
             return GestureDetector(
           onTap: onAdd,
               child: Icon(
             CupertinoIcons.add_circled,
             color: themePrimaryColor,
             size: 24.0,
           ),
             );
           },
         ),
       );
}
