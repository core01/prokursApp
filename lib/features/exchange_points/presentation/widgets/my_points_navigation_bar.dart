import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';

class MyPointsNavigationBar extends CupertinoNavigationBar {
  MyPointsNavigationBar({
    super.key,
    required String? userEmail,
    required Future<void> Function() onSignOut,
    required VoidCallback onAdd,
  }) : super(
         automaticallyImplyLeading: false,
         backgroundColor: DarkTheme.lightBg,
         leading: Builder(
           builder: (context) => GestureDetector(
             child: const Icon(
               CupertinoIcons.square_arrow_right,
               color: DarkTheme.generalBlack,
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
                       style: TextStyle(color: DarkTheme.generalBlack),
                     ),
                     onPressed: () {
                       Navigator.pop(context);
                     },
                   ),
                 ),
               );
             },
           ),
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
         trailing: GestureDetector(
           onTap: onAdd,
           child: const Icon(
             CupertinoIcons.add_circled,
             color: DarkTheme.generalBlack,
             size: 24.0,
           ),
         ),
       );
}
