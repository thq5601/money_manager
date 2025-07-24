import 'package:flutter/material.dart';
import 'package:money_manager/features/profile/profile.dart';
import 'package:money_manager/widgets/bottom_navigation_bar.dart';
import 'package:money_manager/core/theme/app_colors.dart';
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
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/bloc/home/home_bloc.dart';

final currencyFormatVND = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatefulWidget {
  const _HomeScreenView({super.key});

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView>
    with TickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late AnimationController _pageAnimationController;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  GlobalKey _analyticsScreenKey = GlobalKey();
  Timer? _searchDebounce;
  bool _isSearching = false;
  StreamSubscription? _budgetsSub;
  StreamSubscription? _txSub;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
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
    if (!_pageAnimationController.isCompleted) {
      _pageAnimationController.forward();
    }
    _setupRealtimeBudgetWarningListener();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    _budgetsSub?.cancel();
    _txSub?.cancel();
    super.dispose();
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
    final bloc = context.read<HomeBloc>();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      bloc.add(const HomeBudgetWarningsUpdated([]));
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
    bloc.add(HomeBudgetWarningsUpdated(warnings));
  }

  void _onTabTapped(int index) {
    final bloc = context.read<HomeBloc>();
    bloc.add(HomeTabChanged(index));
    setState(() {
      _isSearching = false;
    });
    _pageAnimationController.reset();
    _pageAnimationController.forward();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    context.read<HomeBloc>().add(const HomeSearchChanged(''));
  }

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(
        initialCategories: context.read<HomeBloc>().state.selectedCategories,
        initialType: context.read<HomeBloc>().state.selectedType,
      ),
    );
    if (result != null) {
      context.read<HomeBloc>().add(
        HomeFilterChanged(
          (result['categories'] as Set<String>?) ?? {},
          result['type'],
        ),
      );
    }
  }

  void _refreshAnalytics() {
    setState(() {
      _analyticsScreenKey = GlobalKey();
    });
  }

  void _showBudgetWarningsDialog(List<dynamic> warnings) {
    if (warnings.isEmpty) return;
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
              itemCount: warnings.length,
              separatorBuilder: (_, __) => const Divider(height: 18),
              itemBuilder: (context, i) {
                final w = warnings[i];
                final color = w.percent >= 1.0 ? Colors.red : Colors.orange;
                final format = currencyFormatVND;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.13),
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

  Widget _buildAppBar(HomeState state) {
    return CustomAppBar(
      title: _getAppBarTitle(state.currentIndex),
      actions: _getAppBarActions(state),
      isSearching: _isSearching,
      searchController: _searchController,
      onSearchChanged: () {
        _searchDebounce?.cancel();
        _searchDebounce = Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.read<HomeBloc>().add(
              HomeSearchChanged(_searchController.text),
            );
          }
        });
      },
      onStopSearch: _stopSearch,
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
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

  List<Widget> _getAppBarActions(HomeState state) {
    if (state.currentIndex == 1) {
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
    if (state.currentIndex == 2) {
      return [
        IconButton(
          onPressed: _refreshAnalytics,
          icon: const Icon(Icons.refresh),
          color: AppColors.textSecondary,
        ),
      ];
    }
    // Notifications for dashboard
    if (state.currentIndex == 0) {
      return [
        Stack(
          children: [
            IconButton(
              onPressed: state.budgetWarnings.isNotEmpty
                  ? () => _showBudgetWarningsDialog(state.budgetWarnings)
                  : null,
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.textSecondary,
            ),
            if (state.budgetWarnings.isNotEmpty)
              const Positioned(
                right: 8,
                top: 8,
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ];
    }
    return const [];
  }

  Widget _buildBody(HomeState state) {
    switch (state.currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return TransactionScreen(
          searchQuery: state.searchQuery,
          selectedCategories: state.selectedCategories,
          selectedType: state.selectedType,
        );
      case 2:
        return AnalyticsScreen(key: _analyticsScreenKey);
      case 3:
        return const ProfileScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.only(top: 0, bottom: 24),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _DashboardBudgetPlanningButton(),
        ),
        DashboardScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(state),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildBody(state),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton:
              state.currentIndex == 3 || state.currentIndex == 2
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
                  },
                  backgroundColor: AppColors.green,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
          bottomNavigationBar: FloatingBottomNavigationBar(
            currentIndex: state.currentIndex,
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

// Extracted widget for const usage
class _DashboardBudgetPlanningButton extends StatelessWidget {
  const _DashboardBudgetPlanningButton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: [
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
    );
  }
}
