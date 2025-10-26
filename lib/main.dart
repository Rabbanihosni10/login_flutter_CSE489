import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const VangtiChaiApp());
}

class VangtiChaiApp extends StatelessWidget {
  const VangtiChaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VangtiChai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const VangtiChaiHome(),
    );
  }
}

class VangtiChaiHome extends StatefulWidget {
  const VangtiChaiHome({super.key});

  @override
  State<VangtiChaiHome> createState() => _VangtiChaiHomeState();
}

class _VangtiChaiHomeState extends State<VangtiChaiHome> with SingleTickerProviderStateMixin {
  int _amount = 0;
  final List<int> _denominations = [500, 100, 50, 20, 10, 5, 2, 1];
  Map<int, int> _change = {};
  List<int> _history = [];
  bool _showHistory = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _computeChange();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _appendDigit(int d) {
    HapticFeedback.lightImpact();
    _animController.forward().then((_) => _animController.reverse());
    setState(() {
      if (_amount <= 99999999) {
        _amount = _amount * 10 + d;
        _computeChange();
      }
    });
  }

  void _clearAmount() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_amount > 0) {
        _history.insert(0, _amount);
        if (_history.length > 10) _history.removeLast();
      }
      _amount = 0;
      _computeChange();
    });
  }

  void _backspace() {
    HapticFeedback.lightImpact();
    setState(() {
      _amount = _amount ~/ 10;
      _computeChange();
    });
  }

  void _computeChange() {
    int remaining = _amount;
    final Map<int, int> map = {};
    for (var d in _denominations) {
      int count = remaining ~/ d;
      map[d] = count;
      remaining = remaining - count * d;
    }
    _change = map;
  }

  int _getTotalNotes() {
    return _change.values.fold(0, (sum, count) => sum + count);
  }

  Widget _buildKeypadButton(String label, VoidCallback onTap, {bool isSpecial = false}) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide >= 600;
    final buttonSize = isTablet ? 28.0 : 24.0;

    return ScaleTransition(
      scale: label == '⌫' ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
      child: Material(
        color: isSpecial ? Colors.orange.shade400 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: buttonSize,
                  fontWeight: FontWeight.w600,
                  color: isSpecial ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final buttons = [
      ('1', () => _appendDigit(1), false),
      ('2', () => _appendDigit(2), false),
      ('3', () => _appendDigit(3), false),
      ('4', () => _appendDigit(4), false),
      ('5', () => _appendDigit(5), false),
      ('6', () => _appendDigit(6), false),
      ('7', () => _appendDigit(7), false),
      ('8', () => _appendDigit(8), false),
      ('9', () => _appendDigit(9), false),
      ('C', _clearAmount, true),
      ('0', () => _appendDigit(0), false),
      ('⌫', _backspace, true),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final btn = buttons[index];
        return _buildKeypadButton(btn.$1, btn.$2, isSpecial: btn.$3);
      },
    );
  }

  Widget _buildDisplay() {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide >= 600;
    final fontSize = isTablet ? 42.0 : 32.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, const Color.fromARGB(255, 63, 185, 173)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Taka:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_history.isNotEmpty)
                IconButton(
                  icon: Icon(
                    _showHistory ? Icons.history : Icons.history_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => _showHistory = !_showHistory);
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '৳ ${_formatAmount(_amount)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.right,
          ),
          if (_amount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Total Notes: ${_getTotalNotes()}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget _buildChangeTable() {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide >= 600;
    final fontSize = isTablet ? 18.0 : 16.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.teal.shade600),
                const SizedBox(width: 8),
                Text(
                  'Change Breakdown',
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Note (৳)',
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Count',
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._denominations.map((d) {
              final count = _change[d] ?? 0;
              final total = d * count;
              final hasValue = count > 0;
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: hasValue ? Colors.teal.shade50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasValue ? Colors.teal.shade200 : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '৳ $d',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
                          color: hasValue ? Colors.teal.shade800 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
                          color: hasValue ? Colors.teal.shade800 : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hasValue ? '৳ $total' : '-',
                        style: TextStyle(
                          fontSize: fontSize - 2,
                          fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                          color: hasValue ? Colors.teal.shade700 : Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: Colors.teal.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Recent History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _history.clear());
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No history yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...List.generate(_history.length, (index) {
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    radius: 18,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    '৳ ${_formatAmount(_history[index])}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore, size: 20),
                    onPressed: () {
                      setState(() {
                        _amount = _history[index];
                        _computeChange();
                        _showHistory = false;
                      });
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;
    final isTablet = mq.size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VangtiChai - Change Calculator'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
          child: isLandscape
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (_showHistory && _history.isNotEmpty) ...[
                              _buildHistory(),
                              const SizedBox(height: 12),
                            ],
                            _buildChangeTable(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDisplay(),
                          const SizedBox(height: 12),
                          Expanded(child: _buildKeypad()),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDisplay(),
                    const SizedBox(height: 12),
                    if (_showHistory && _history.isNotEmpty) ...[
                      _buildHistory(),
                      const SizedBox(height: 12),
                    ] else ...[
                      Expanded(child: SingleChildScrollView(child: _buildChangeTable())),
                      const SizedBox(height: 12),
                    ],
                    _buildKeypad(),
                  ],
                ),
        ),
      ),
    );
  }
}