import 'package:flutter/material.dart';
import 'package:money_manager/core/widgets/bottom_navigation_bar.dart';

import 'package:money_manager/feature/profile/profile.dart';
import 'package:money_manager/core/services/sign_up_service.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:money_manager/core/widgets/empty_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final SignUpService _authService = SignUpService();
  DateTime _selectedMonth = DateTime.now();

  late AnimationController _pageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageAnimationController.reset();
    _pageAnimationController.forward();
  }

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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO: Implement add new action
            },
            backgroundColor: AppColors.green,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
            elevation: 4,
            shape: const CircleBorder(),
          ),
          bottomNavigationBar: FloatingBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _getAppBarTitle(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          ..._getAppBarActions(),
        ],
      ),
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
      default:
        return '';
    }
  }

  List<Widget> _getAppBarActions() {
    switch (_currentIndex) {
      case 0:
        return [
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
            },
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textSecondary,
          ),
        ];
      case 1:
        return [
          IconButton(
            onPressed: () {
              // TODO: Implement search
            },
            icon: const Icon(Icons.search),
            color: AppColors.textSecondary,
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement filters
            },
            icon: const Icon(Icons.filter_list),
            color: AppColors.textSecondary,
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
        return _buildTransactions();
      case 2:
        return _buildAnalytics();
      case 3:
        return const ProfileScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return DashboardScreen();
  }

  Widget _buildTransactions() {
    return Center(
      child: EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Transactions',
        subtitle: 'Transaction features have been removed.',
        showAnimation: false,
      ),
    );
  }

  Widget _buildAnalytics() {
    return Center(
      child: EmptyState(
        icon: Icons.analytics_outlined,
        title: 'Analytics coming soon...',
        subtitle: 'Charts and insights will be available here',
        showAnimation: false,
      ),
    );
  }
}
