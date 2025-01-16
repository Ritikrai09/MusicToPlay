import 'package:blogit/Utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:blogit/Utils/utils.dart';

class SignalOutlinedButton extends StatelessWidget {
  const SignalOutlinedButton({
    super.key,
    required this.tittle,
    required this.onTap,
    this.textColor,
  });

  final String tittle;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        
          border: Border.all(width: 1.5, color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).primaryColor),
      child: SizedBox(
        child: MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Center(
            child: Text(
              tittle,
              style: FontStyleUtilities.t2(context,
                  fontWeight: FWT.extrabold,
                  fontColor: textColor ?? (isWhiteRange(Theme.of(context).primaryColor) ? Colors.black : Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
