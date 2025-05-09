import 'package:roster_system/main.dart';

class Cell extends UI {
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
      tipBuilder: (_, __, ___) => data.text(),
      child: FTappable(
        child: data.text(
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        onPress: onPressed,
      ),
    );
  }
}
