part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeTabChanged extends HomeEvent {
  final int index;
  const HomeTabChanged(this.index);
  @override
  List<Object?> get props => [index];
}

class HomeSearchChanged extends HomeEvent {
  final String query;
  const HomeSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class HomeFilterChanged extends HomeEvent {
  final Set<String> categories;
  final String? selectedType;
  const HomeFilterChanged(this.categories, this.selectedType);
  @override
  List<Object?> get props => [categories, selectedType];
}

class HomeBudgetWarningsUpdated extends HomeEvent {
  final List<dynamic> budgetWarnings;
  const HomeBudgetWarningsUpdated(this.budgetWarnings);
  @override
  List<Object?> get props => [budgetWarnings];
}

class HomeLoadingChanged extends HomeEvent {
  final bool isLoading;
  const HomeLoadingChanged(this.isLoading);
  @override
  List<Object?> get props => [isLoading];
}
