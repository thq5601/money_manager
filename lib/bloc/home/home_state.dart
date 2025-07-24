part of 'home_bloc.dart';

class HomeState extends Equatable {
  final int currentIndex;
  final String searchQuery;
  final Set<String> selectedCategories;
  final String? selectedType;
  final List<dynamic> budgetWarnings;
  final bool loadingBudgetWarnings;

  const HomeState({
    this.currentIndex = 0,
    this.searchQuery = '',
    this.selectedCategories = const {},
    this.selectedType,
    this.budgetWarnings = const [],
    this.loadingBudgetWarnings = false,
  });

  HomeState copyWith({
    int? currentIndex,
    String? searchQuery,
    Set<String>? selectedCategories,
    String? selectedType,
    List<dynamic>? budgetWarnings,
    bool? loadingBudgetWarnings,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedType: selectedType ?? this.selectedType,
      budgetWarnings: budgetWarnings ?? this.budgetWarnings,
      loadingBudgetWarnings:
          loadingBudgetWarnings ?? this.loadingBudgetWarnings,
    );
  }

  @override
  List<Object?> get props => [
    currentIndex,
    searchQuery,
    selectedCategories,
    selectedType,
    budgetWarnings,
    loadingBudgetWarnings,
  ];
}
