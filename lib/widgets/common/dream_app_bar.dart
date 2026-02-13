import 'package:flutter/material.dart';
import 'package:dreamweaver/config/theme.dart';

class DreamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  const DreamAppBar({
    Key? key,
    this.title = '',
    this.leading,
    this.actions,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
      ),
      centerTitle: centerTitle,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DreamTheme.primary.withOpacity(0),
                DreamTheme.accent.withOpacity(0.5),
                DreamTheme.primary.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
