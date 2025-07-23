import 'package:flutter/material.dart';
import 'package:money_manager/features/profile/profile.dart';
import 'package:money_manager/widgets/bottom_navigation_bar.dart';

import 'package:money_manager/core/services/sign_up_service.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:money_manager/widgets/empty_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard/dashboard_screen.dart';
import 'package:money_manager/features/transactions/transaction_screen.dart';
import 'package:money_manager/features/transactions/add_transaction_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final SignUpService _authService = SignUpService();
  int _currentIndex = 0;
  late Animation<double> _fadeAnimation;
  bool _isSearching = false;
  late AnimationController _pageAnimationController;
  final TextEditingController _searchController = TextEditingController();
  // --- Search & Filter State ---
  String _searchQuery = '';

  // Change selectedCategory to a Set for multi-select
  Set<String> _selectedCategories = {};
  DateTime _selectedMonth = DateTime.now();
  String? _selectedType; // 'Income' or 'Expense'
  late Animation<Offset> _slideAnimation;

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
      _selectedCategories.clear();
      _selectedType = null;
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
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        Set<String> tempCategories = {..._selectedCategories};
        String? tempType = _selectedType;
        final sortedCategories = AppColors.categoryColors.keys.toList()..sort();
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.filter_list, color: AppColors.green, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Filter Transactions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final cat in sortedCategories)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _categoryIconForFilter(cat),
                                    size: 18,
                                    color: AppColors.categoryColors[cat],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(cat[0].toUpperCase() + cat.substring(1)),
                                  if (tempCategories.contains(cat)) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppColors.categoryColors[cat],
                                    ),
                                  ],
                                ],
                              ),
                              selected: tempCategories.contains(cat),
                              selectedColor: AppColors.categoryColors[cat]
                                  ?.withOpacity(0.18),
                              backgroundColor: AppColors.paleGrey,
                              labelStyle: TextStyle(
                                color: tempCategories.contains(cat)
                                    ? AppColors.categoryColors[cat]
                                    : AppColors.textSecondary,
                              ),
                              shape: StadiumBorder(),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    tempCategories.add(cat);
                                  } else {
                                    tempCategories.remove(cat);
                                  }
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 24),
                  const Text(
                    'Type',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(16),
                      isSelected: [
                        tempType == null,
                        tempType == 'Income',
                        tempType == 'Expense',
                      ],
                      onPressed: (index) {
                        setState(() {
                          if (index == 0) tempType = null;
                          if (index == 1) tempType = 'Income';
                          if (index == 2) tempType = 'Expense';
                        });
                      },
                      color: AppColors.textSecondary,
                      selectedColor: Colors.white,
                      fillColor: AppColors.green,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text('All'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text('Income'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text('Expense'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'categories': <String>{},
                            'type': null,
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, {
                          'categories': tempCategories,
                          'type': tempType,
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedCategories = (result['categories'] as Set<String>?) ?? {};
        _selectedType = result['type'];
      });
    }
  }

  // --- Transaction Filtering Logic ---
  List<Map<String, dynamic>> get _filteredTransactions {
    // Use the same sample data as TransactionScreen for now
    final all = [
      {
        'date': '2024-07-23',
        'description': 'Grocery Shopping',
        'amount': -50.0,
        'type': 'Expense',
        'category': 'food',
      },
      {
        'date': '2024-07-23',
        'description': 'Coffee',
        'amount': -3.5,
        'type': 'Expense',
        'category': 'food',
      },
      {
        'date': '2024-07-22',
        'description': 'Salary',
        'amount': 1500.0,
        'type': 'Income',
        'category': 'salary',
      },
      {
        'date': '2024-07-21',
        'description': 'Book',
        'amount': -12.0,
        'type': 'Expense',
        'category': 'education',
      },
    ];
    return all.where((tx) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          tx['description'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesCategory =
          _selectedCategories.isEmpty ||
          _selectedCategories.contains(tx['category']);
      final matchesType = _selectedType == null || tx['type'] == _selectedType;
      return matchesQuery && matchesCategory && matchesType;
    }).toList();
  }

  Widget _buildAppBar() {
    if (_currentIndex == 1 && _isSearching) {
      // Show search bar
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
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: _stopSearch),
          ],
        ),
      );
    }
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
        return [
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
            },
            icon: const Icon(Icons.notifications_outlined),
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
        return TransactionScreen(
          searchQuery: _searchQuery,
          selectedCategories: _selectedCategories,
          selectedType: _selectedType,
        );
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

  Widget _buildRecentTransactionsCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox();
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('dateCreated', descending: true)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 40,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No recent transactions',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final amount = data['amount'] ?? 0;
                  final type = data['type'] ?? 'Expense';
                  final category = data['category'];
                  final desc = data['description'] ?? '';
                  final icon = _categoryIconForFilter(category);
                  final color =
                      AppColors.categoryColors[category] ??
                      (type == 'Income' ? AppColors.success : AppColors.error);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withOpacity(0.18),
                          child: Icon(icon, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            desc,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          (amount > 0 ? '+' : '-') +
                              _formatVND((amount as num).abs()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: type == 'Income'
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatVND(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(amount);
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
}

IconData _categoryIconForFilter(String? category) {
  switch (category) {
    case 'salary':
      return Icons.attach_money;
    case 'freelance':
      return Icons.laptop_mac;
    case 'investment':
      return Icons.trending_up;
    case 'business':
      return Icons.business_center;
    case 'otherIncome':
      return Icons.account_balance_wallet;
    case 'food':
      return Icons.restaurant_menu;
    case 'transportation':
      return Icons.directions_car;
    case 'shopping':
      return Icons.shopping_bag;
    case 'entertainment':
      return Icons.movie;
    case 'healthcare':
      return Icons.local_hospital;
    case 'education':
      return Icons.school;
    case 'housing':
      return Icons.home;
    case 'utilities':
      return Icons.lightbulb;
    case 'insurance':
      return Icons.security;
    case 'otherExpense':
      return Icons.more_horiz;
    default:
      return Icons.category;
  }
}
