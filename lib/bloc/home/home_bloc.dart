import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeTabChanged>((event, emit) {
      emit(state.copyWith(currentIndex: event.index));
    });
    on<HomeSearchChanged>((event, emit) {
      emit(state.copyWith(searchQuery: event.query));
    });
    on<HomeFilterChanged>((event, emit) {
      emit(
        state.copyWith(
          selectedCategories: event.categories,
          selectedType: event.selectedType,
        ),
      );
    });
    on<HomeBudgetWarningsUpdated>((event, emit) {
      emit(state.copyWith(budgetWarnings: event.budgetWarnings));
    });
    on<HomeLoadingChanged>((event, emit) {
      emit(state.copyWith(loadingBudgetWarnings: event.isLoading));
    });
  }
}
