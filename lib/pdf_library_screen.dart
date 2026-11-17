import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfLibraryScreen extends StatefulWidget {
  const PdfLibraryScreen({super.key});

  @override
  State<PdfLibraryScreen> createState() => _PdfLibraryScreenState();
}

class _PdfLibraryScreenState extends State<PdfLibraryScreen> {
  static const Color _background = Color(0xFF101010);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _lightGold = Color(0xFFFFE7A3);
  static const Color _muted = Color(0xFFB9B2A2);

  static const String _pdfId = '1_BMLzgyBjEz5DulJJUQp6Q-HW1-_sfEu';
  static const String _pdfUrl =
      'https://drive.google.com/uc?export=download&id=$_pdfId';
  static const String _unlockKey = 'pdf_demo_unlocked_$_pdfId';

  static const MethodChannel _securityChannel = MethodChannel(
    'com.rakibkhan.chineseshikhi/pdf_security',
  );

  bool _demoUnlocked = false;
  bool _loadingUnlockState = true;

  @override
  void initState() {
    super.initState();
    unawaited(_setScreenSecure(true));
    unawaited(_loadDemoUnlock());
  }

  Future<void> _setScreenSecure(bool enabled) async {
    try {
      await _securityChannel.invokeMethod<void>(
        'setSecure',
        <String, dynamic>{'enabled': enabled},
      );
    } catch (_) {
      // Android channel না থাকলেও PDF Reader চালু থাকবে।
    }
  }

  Future<void> _loadDemoUnlock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlocked = prefs.getBool(_unlockKey) ?? false;

      if (!mounted) return;
      setState(() {
        _demoUnlocked = unlocked;
        _loadingUnlockState = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingUnlockState = false);
    }
  }

  Future<void> _activateDemoUnlock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_unlockKey, true);

      if (!mounted) return;
      setState(() => _demoUnlocked = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ডেমো আনলক হয়েছে। কোনো টাকা কাটা হয়নি।'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ডেমো আনলক সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'),
        ),
      );
    }
  }

  void _showPaymentInfo(String method) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          title: Text(
            '$method পেমেন্ট',
            style: const TextStyle(
              color: _lightGold,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'এখনো Merchant Account বা Payment Gateway সংযুক্ত করা হয়নি। '
            'এটি শুধু পরীক্ষার ডেমো। কোনো টাকা পাঠাবেন না এবং কোনো '
            'পেমেন্ট সম্পন্ন হয়েছে বলে ধরে নেবেন না।',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'বন্ধ করুন',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _background,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _activateDemoUnlock();
              },
              child: const Text(
                'ডেমো আনলক করুন',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentButton(String method) {
    return OutlinedButton(
      onPressed: () => _showPaymentInfo(method),
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightGold,
        side: const BorderSide(color: _gold),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      ),
      child: Text(
        method,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildLockedCard(int remainingPages) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 28),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _gold.withValues(alpha: 0.75)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_rounded,
            color: _gold,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'বাকি পৃষ্ঠাগুলো আনলক করুন',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _lightGold,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$remainingPagesটি পৃষ্ঠা এখন লক করা আছে।',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          const Text(
            'প্রতি PDF একবার আনলক করার ডেমো মূল্য',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 5),
          const Text(
            '৳১৯৯',
            style: TextStyle(
              color: _gold,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildPaymentButton('bKash'),
              _buildPaymentButton('Nagad'),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'ডেমো মোড: এখানে কোনো বাস্তব পেমেন্ট নেওয়া হচ্ছে না।',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _gold),
          SizedBox(height: 14),
          Text(
            'PDF লোড হচ্ছে...',
            style: TextStyle(color: _lightGold),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.redAccent,
              size: 46,
            ),
            const SizedBox(height: 12),
            const Text(
              'PDF খোলা যাচ্ছে না',
              style: TextStyle(
                color: _lightGold,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocument(PdfDocument document) {
    final totalPages = document.pages.length;
    final freePages = totalPages < 10 ? totalPages : 10;
    final visiblePages = _demoUnlocked ? totalPages : freePages;
    final showLock = !_demoUnlocked && totalPages > freePages;

    if (totalPages == 0) {
      return const Center(
        child: Text(
          'এই PDF-এ কোনো পৃষ্ঠা পাওয়া যায়নি।',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF202020),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _gold.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: _gold,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _demoUnlocked
                      ? 'ডেমো আনলক • $totalPages পৃষ্ঠা'
                      : 'ফ্রি পৃষ্ঠা: $freePages / $totalPages',
                  style: const TextStyle(
                    color: _lightGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              if (_demoUnlocked)
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.orangeAccent,
                  size: 19,
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 18),
            itemCount: visiblePages + (showLock ? 1 : 0),
            itemBuilder: (context, index) {
              if (showLock && index == visiblePages) {
                return _buildLockedCard(totalPages - freePages);
              }

              return Container(
                height: 620,
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 9,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: PdfPageView(
                  document: document,
                  pageNumber: index + 1,
                  maximumDpi: 180,
                  backgroundColor: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    unawaited(_setScreenSecure(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _lightGold,
        title: const Text(
          'PDF Library',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (_demoUnlocked)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Center(
                child: Text(
                  'DEMO',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loadingUnlockState
          ? _buildLoading()
          : PdfDocumentViewBuilder.uri(
              Uri.parse(_pdfUrl),
              loadingBuilder: (_) => _buildLoading(),
              errorBuilder: (context, error, stackTrace) => _buildError(error),
              builder: (context, document) {
                if (document == null) return _buildLoading();
                return _buildDocument(document);
              },
            ),
    );
  }
}
