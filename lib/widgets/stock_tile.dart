
import 'package:flutter/material.dart';
import '../models/stock_model.dart';

class StockTile extends StatefulWidget {
  final Stock stock;

  const StockTile({super.key, required this.stock});

  @override
  State<StockTile> createState() => _StockTileState();
}

class _StockTileState extends State<StockTile>
    with SingleTickerProviderStateMixin {
  Color? _flashColor;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_animationController);
  }

  @override
  void didUpdateWidget(covariant StockTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.stock.ticker == oldWidget.stock.ticker &&
        !widget.stock.isAnomalous && !oldWidget.stock.isAnomalous) {
      if (widget.stock.price > oldWidget.stock.price) {
        _flash(Colors.green.withValues(alpha: 0.3));
      } else if (widget.stock.price < oldWidget.stock.price) {
        _flash(Colors.red.withValues(alpha: 0.3));
      }
    }
  }

  void _flash(Color color) {
    _colorAnimation = ColorTween(
      begin: color,
      end: Colors.transparent,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          color: _colorAnimation.value,
          child: ListTile(
            leading: Icon(
              Icons.trending_up,
              color: widget.stock.isAnomalous ? Colors.orange : null,
            ),
            title: Text(
              widget.stock.ticker,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.stock.isAnomalous ? Colors.orange : null,
              ),
            ),
            subtitle: Text(
              '\$ ${widget.stock.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.stock.isAnomalous ? Colors.orange : Colors.black87,
              ),
            ),
            trailing: widget.stock.isAnomalous
                ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: Colors.red, size: 20),
                SizedBox(width: 4),
                Text(
                  "SUSPECT",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
                : null,
          ),
        );
      },
    );
  }
}