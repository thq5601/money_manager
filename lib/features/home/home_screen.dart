import 'package:flutter/material.dart';
import 'package:money_manager/features/profile/profile.dart';
import 'package:money_manager/widgets/bottom_navigation_bar.dart';

import 'package:money_manager/core/services/sign_up_service.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:money_manager/widgets/empty_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard/dashboard_screen.dart';
import 'package:money_manager/features/transactions/transaction_screen.dart';
import 'package:money_manager/features/transactions/add_transaction_screen.dart';
import 'package:money_manager/features/analytics/analytics_screen.dart';
import 'dart:ui';
import 'widgets/filter_dialog.dart';
import 'widgets/custom_app_bar.dart';
import 'package:money_manager/core/widgets/category_icon.dart';
import 'package:money_manager/core/utils/format.dart';
import 'package:intl/intl.dart';
import 'dart:async';

final currencyFormatVND = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final SignUpService _authService = SignUpService();
  late int _currentIndex;
  late Animation<double> _fadeAnimation;
  bool _isSearching = false;
  late AnimationController _pageAnimationController;
  final TextEditingController _searchController = TextEditingController();
  // --- Search & Filter State ---
  String _searchQuery = '';

  // Budget warning state
  List<_BudgetWarning> _budgetWarnings = [];
  bool _loadingBudgetWarnings = false;

  // Change selectedCategory to a Set for multi-select
  Set<String> _selectedCategories = {};

  DateTime _selectedMonth = DateTime.now();
  String? _selectedType; // 'Income' or 'Expense'
  late Animation<Offset> _slideAnimation;
  // Firestore listeners
  StreamSubscription? _budgetsSub;
  StreamSubscription? _txSub;
  String? _currentUserId;

  @override
  void dispose() {
    _budgetsSub?.cancel();
    _txSub?.cancel();
    _pageAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageAnimationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pageAnimationController.forward();
    _setupRealtimeBudgetWarningListener();
  }

  Future<void> _setupRealtimeBudgetWarningListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_currentUserId == user.uid) return; // Already listening
    _currentUserId = user.uid;
    _budgetsSub?.cancel();
    _txSub?.cancel();
    // Listen to budgets
    _budgetsSub = FirebaseFirestore.instance
        .collection('budgets')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((_) => _fetchBudgetWarnings());
    // Listen to transactions
    _txSub = FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((_) => _fetchBudgetWarnings());
    // Initial fetch
    await _fetchBudgetWarnings();
  }

  Future<void> _fetchBudgetWarnings() async {
    setState(() {
      _loadingBudgetWarnings = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _budgetWarnings = [];
        _loadingBudgetWarnings = false;
      });
      return;
    }
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final budgetsSnap = await FirebaseFirestore.instance
        .collection('budgets')
        .where('userId', isEqualTo: user.uid)
        .get();
    final txSnap = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where(
          'dateCreated',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where(
          'dateCreated',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
        )
        .get();
    final Map<String, double> spentByCategory = {};
    for (final doc in txSnap.docs) {
      final data = doc.data();
      final category = data['category'] as String?;
      final amount = (data['amount'] ?? 0).toDouble();
      if (category != null && amount < 0) {
        spentByCategory[category] =
            (spentByCategory[category] ?? 0) + amount.abs();
      }
    }
    final List<_BudgetWarning> warnings = [];
    for (final doc in budgetsSnap.docs) {
      final data = doc.data();
      final category = data['category'] as String?;
      final limit = (data['limit'] ?? 0).toDouble();
      if (category != null && limit > 0) {
        final spent = spentByCategory[category] ?? 0;
        final percent = spent / limit;
        if (percent >= 0.8) {
          warnings.add(
            _BudgetWarning(
              category: category,
              spent: spent,
              limit: limit,
              percent: percent,
            ),
          );
        }
      }
    }
    setState(() {
      _budgetWarnings = warnings;
      _loadingBudgetWarnings = false;
    });
  }

  // Expose a static method to refresh budget warnings from outside

  void refreshBudgetWarnings() => _fetchBudgetWarnings();

  void _showBudgetWarningsDialog() {
    if (_budgetWarnings.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Budget Warnings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 340,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _budgetWarnings.length,
              separatorBuilder: (_, __) => const Divider(height: 18),
              itemBuilder: (context, i) {
                final w = _budgetWarnings[i];
                final color = w.percent >= 1.0 ? Colors.red : Colors.orange;
                final format = currencyFormatVND;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.13),
                      child: CategoryIcon(category: w.category, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.category[0].toUpperCase() +
                                w.category.substring(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            w.percent >= 1.0
                                ? 'Above limit!'
                                : 'Reached more than 80% of limit',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Expensed: ${format.format(w.spent)} / ${format.format(w.limit)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
      _selectedCategories.clear();
      _selectedType = null;
    });
    if (index == 0) _fetchBudgetWarnings();
    _pageAnimationController.reset();
    _pageAnimationController.forward();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(
        initialCategories: _selectedCategories,
        initialType: _selectedType,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategories = (result['categories'] as Set<String>?) ?? {};
        _selectedType = result['type'];
      });
    }
  }

  // --- Transaction Filtering Logic ---

  Widget _buildAppBar() {
    return CustomAppBar(
      title: _getAppBarTitle(),
      actions: _getAppBarActions(),
      isSearching: _currentIndex == 1 && _isSearching,
      searchController: _searchController,
      onSearchChanged: () {
        setState(() {
          _searchQuery = _searchController.text;
        });
      },
      onStopSearch: _stopSearch,
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Transactions';
      case 2:
        return 'Analytics';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  List<Widget> _getAppBarActions() {
    if (_currentIndex == 1) {
      return [
        IconButton(
          onPressed: _startSearch,
          icon: const Icon(Icons.search),
          color: AppColors.textSecondary,
        ),
        IconButton(
          onPressed: _showFilterDialog,
          icon: const Icon(Icons.filter_list),
          color: AppColors.textSecondary,
        ),
      ];
    }
    switch (_currentIndex) {
      case 0:
        // Notification button with badge
        return [
          Stack(
            children: [
              IconButton(
                onPressed: _budgetWarnings.isNotEmpty
                    ? _showBudgetWarningsDialog
                    : null,
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textSecondary,
              ),
              if (_budgetWarnings.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return TransactionScreen(
          searchQuery: _searchQuery,
          selectedCategories: _selectedCategories,
          selectedType: _selectedType,
        );
      case 2:
        return const AnalyticsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.only(top: 0, bottom: 24),
      children: [
        // Budget Planning Glass Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.of(context).pushNamed('/budget-planning');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.green,
                          size: 32,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Budget Planning',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Recent Transactions Card removed
        // Dashboard content
        DashboardScreen(),
      ],
    );
  }

  // RecentTransactionsCard is now a separate widget

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for auth state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(),
                // Body Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildBody(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _currentIndex == 3 || _currentIndex == 2
              ? null
              : FloatingActionButton(
                  heroTag: 'main-fab',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(),
                      ),
                    );
                    // TODO: Refresh transactions after adding
                  },
                  backgroundColor: AppColors.green,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
          bottomNavigationBar: FloatingBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }
}

// Helper class for budget warnings
class _BudgetWarning {
  final String category;
  final double spent;
  final double limit;
  final double percent;
  _BudgetWarning({
    required this.category,
    required this.spent,
    required this.limit,
    required this.percent,
  });
}
