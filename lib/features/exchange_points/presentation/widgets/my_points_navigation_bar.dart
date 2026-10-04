import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';

class MyPointsNavigationBar extends CupertinoNavigationBar {
  
  MyPointsNavigationBar({
    super.key,
    required String? userEmail,
    required Future<void> Function() onSignOut,
    required VoidCallback onAdd,
  }) : super(
         automaticallyImplyLeading: false,
         backgroundColor: AppColors.background,
         leading: Builder(
           builder: (context) {
             return GestureDetector(
               child: Icon(
               CupertinoIcons.square_arrow_right,
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
             Text("Мои обменные пункты", style: AppTypography.headline),
             if (userEmail != null)
               Builder(
                 builder: (context) => Text(
                   userEmail,
                   style: AppTypography.footnote.copyWith(
                     color: AppColors.secondaryLabel.resolveFrom(context),
                   ),
                 ),
               ),
           ],
         ),
         trailing: Builder(
           builder: (context) {
             return GestureDetector(
           onTap: onAdd,
               child: Icon(
             CupertinoIcons.add_circled,
             size: 24.0,
           ),
             );
           },
         ),
       );
}
