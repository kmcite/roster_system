import 'package:roster_system/main.dart';

class Cell extends StatelessWidget {
  final String data;

  final VoidCallback? onPressed;
  const Cell(
    this.data, {
    this.onPressed,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (_, __) => Text(data),
      child: FTappable(
        child: Text(
          data,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        onPress: onPressed,
      ),
    );
  }
}
