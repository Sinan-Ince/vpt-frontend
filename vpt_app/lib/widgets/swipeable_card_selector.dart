import 'package:flutter/material.dart';

/// Yatayda kaydırılabilir, ortadaki kart öne çıkan (büyüyen/opak),
/// yanlardakiler geride kalan (küçülen/soluklaşan) bir seçici.
class SwipeableCardSelector<T> extends StatefulWidget {
  final List<T> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double height;

  const SwipeableCardSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.itemBuilder,
    this.height = 200,
  });

  @override
  State<SwipeableCardSelector<T>> createState() =>
      _SwipeableCardSelectorState<T>();
}

class _SwipeableCardSelectorState<T> extends State<SwipeableCardSelector<T>> {
  late PageController _controller;
  late double _page;

  @override
  void initState() {
    super.initState();
    _page = widget.selectedIndex.toDouble();
    _controller = PageController(
      viewportFraction: 0.42,
      initialPage: widget.selectedIndex,
    );
    _controller.addListener(_handlePageScroll);
  }

  void _handlePageScroll() {
    if (!_controller.hasClients) return;
    setState(() {
      _page = _controller.page ?? _page;
    });
  }

  @override
  void didUpdateWidget(covariant SwipeableCardSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items) &&
        _controller.hasClients &&
        widget.selectedIndex != _controller.page?.round()) {
      _controller.jumpToPage(widget.selectedIndex);
      _page = widget.selectedIndex.toDouble();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handlePageScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: widget.onSelected,
        itemBuilder: (context, index) {
          final distance = (index - _page).abs().clamp(0.0, 1.0);
          final scale = 1.0 - (distance * 0.28);
          final opacity = (1.0 - (distance * 0.65)).clamp(0.35, 1.0);

          return Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: widget.itemBuilder(context, widget.items[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
