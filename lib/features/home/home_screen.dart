import 'package:flutter/material.dart';
import 'package:money_manager/features/profile/profile_screen.dart';
import 'package:money_manager/widgets/bottom_navigation_bar.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_manager/features/home/dashboard/dashboard_screen.dart';
import 'package:money_manager/features/transactions/transaction_screen.dart';
import 'package:money_manager/features/transactions/add_transaction_screen.dart';
import 'package:money_manager/features/analytics/analytics_screen.dart';
import 'package:money_manager/features/home/widgets/filter_dialog.dart';
import 'package:money_manager/features/home/widgets/custom_app_bar.dart';
import 'package:money_manager/widgets/appbar_actions.dart';
import 'package:money_manager/widgets/budget_warning_dialog.dart';
import 'package:money_manager/widgets/dashboard_budget_planning_button.dart';
import 'package:money_manager/core/models/budget_warning.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/bloc/home/home_bloc.dart';

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
  const _HomeScreenView();

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView>
    with SingleTickerProviderStateMixin {
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
    final List<BudgetWarning> warnings = [];
    for (final doc in budgetsSnap.docs) {
      final data = doc.data();
      final category = data['category'] as String?;
      final limit = (data['limit'] ?? 0).toDouble();
      if (category != null && limit > 0) {
        final spent = spentByCategory[category] ?? 0;
        final percent = spent / limit;
        if (percent >= 0.8) {
          warnings.add(
            BudgetWarning(
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
    BudgetWarningDialog.show(context, warnings);
  }

  Widget _buildAppBar(HomeState state) {
    return CustomAppBar(
      title: _getAppBarTitle(state.currentIndex),
      actions: AppBarActions.getActions(
        currentIndex: state.currentIndex,
        onStartSearch: _startSearch,
        onShowFilterDialog: _showFilterDialog,
        onRefreshAnalytics: _refreshAnalytics,
        budgetWarnings: state.budgetWarnings,
        onShowBudgetWarningsDialog: _showBudgetWarningsDialog,
      ),
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
          child: DashboardBudgetPlanningButton(),
        ),
        DashboardScreen(),
      ],
    );
  }

  // ...existing code...
  // ...existing code...

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
              (state.currentIndex == 3 || state.currentIndex == 2)
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

// ...existing code...
