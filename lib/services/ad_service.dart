import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mangadive/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final _logger = Logger('AdService');
  InterstitialAd? _interstitialAd;
  final FirebaseService _firebaseService = FirebaseService();
  DateTime? _lastAdShownTime;
  static const Duration _adInterval = Duration(minutes: 15);

  // Khởi tạo AdMob
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _logger.info('AdMob initialized successfully');
      // Xóa thời gian hiển thị quảng cáo cuối cùng khi khởi động app
      await _clearLastAdTime();
    } catch (e) {
      _logger.severe('Failed to initialize AdMob: $e');
    }
  }

  // Xóa thời gian hiển thị quảng cáo cuối cùng
  Future<void> _clearLastAdTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastAdShownTime');
      _logger.info('Cleared last ad shown time');
    } catch (e) {
      _logger.severe('Failed to clear last ad shown time: $e');
    }
  }

  // Tải quảng cáo interstitial
  Future<void> loadInterstitialAd() async {
    try {
      _logger.info('Loading interstitial ad...');
      await InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _logger.info('Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            _logger.severe('Failed to load interstitial ad: $error');
          },
        ),
      );
    } catch (e) {
      _logger.severe('Error loading interstitial ad: $e');
    }
  }

  // Hiển thị quảng cáo nếu có thể
  Future<void> showInterstitialAd() async {
    try {
      // Kiểm tra xem người dùng có phải là premium không
      final isPremium = await _firebaseService.isUserPremium();
      _logger.info('User premium status: $isPremium');
      if (isPremium) {
        _logger.info('User is premium, skipping ad');
        return;
      }

      // Kiểm tra thời gian hiển thị quảng cáo cuối cùng
      final prefs = await SharedPreferences.getInstance();
      final lastAdTime = prefs.getInt('lastAdShownTime');
      if (lastAdTime != null) {
        final lastAdDateTime = DateTime.fromMillisecondsSinceEpoch(lastAdTime);
        final timeSinceLastAd = DateTime.now().difference(lastAdDateTime);
        _logger
            .info('Time since last ad: ${timeSinceLastAd.inMinutes} minutes');
        if (timeSinceLastAd < _adInterval) {
          _logger.info('Ad interval not reached yet, skipping ad');
          return;
        }
      }

      if (_interstitialAd != null) {
        _logger.info('Showing interstitial ad...');
        await _interstitialAd!.show();
        _interstitialAd = null;

        // Lưu thời gian hiển thị quảng cáo
        await prefs.setInt(
            'lastAdShownTime', DateTime.now().millisecondsSinceEpoch);
        _logger.info('Ad shown successfully, loading next ad...');

        // Tải quảng cáo mới
        loadInterstitialAd();
      } else {
        _logger.info('No ad available, loading new ad...');
        // Nếu chưa có quảng cáo, tải mới
        loadInterstitialAd();
      }
    } catch (e) {
      _logger.severe('Error showing interstitial ad: $e');
    }
  }

  // Giải phóng tài nguyên
  void dispose() {
    _interstitialAd?.dispose();
  }
}
