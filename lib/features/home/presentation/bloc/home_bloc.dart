import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/tool_item.dart';
import '../../../../core/constants/neo_colors.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeToolsEvent extends HomeEvent {}

class SearchToolsEvent extends HomeEvent {
  final String query;
  const SearchToolsEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterCategoryEvent extends HomeEvent {
  final String category;
  const FilterCategoryEvent(this.category);
  @override
  List<Object?> get props => [category];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadedState extends HomeState {
  final List<ToolItem> allTools;
  final List<ToolItem> filteredTools;
  final String searchQuery;
  final String selectedCategory;

  const HomeLoadedState({
    required this.allTools,
    required this.filteredTools,
    this.searchQuery = '',
    this.selectedCategory = 'ALL',
  });

  HomeLoadedState copyWith({
    List<ToolItem>? allTools,
    List<ToolItem>? filteredTools,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return HomeLoadedState(
      allTools: allTools ?? this.allTools,
      filteredTools: filteredTools ?? this.filteredTools,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [allTools, filteredTools, searchQuery, selectedCategory];
}

// BLoC Implementation
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const List<ToolItem> defaultTools = [
    ToolItem(
      id: 'compress',
      title: 'Compress Image',
      subtitle: 'Shrink file size up to 90%',
      icon: Icons.compress_rounded,
      accentColor: NeoColors.yellow,
      softColor: NeoColors.softYellow,
      route: '/compress',
      category: 'popular',
      tag: '🔥 POPULAR',
    ),
    ToolItem(
      id: 'pdf',
      title: 'Image to PDF',
      subtitle: 'Merge images into PDF doc',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: NeoColors.purple,
      softColor: NeoColors.softPurple,
      route: '/tool/pdf',
      category: 'popular',
      tag: '🔥 POPULAR',
    ),
    ToolItem(
      id: 'resize',
      title: 'Resize Image',
      subtitle: 'Exact width, height & ratio',
      icon: Icons.aspect_ratio_rounded,
      accentColor: NeoColors.cyan,
      softColor: NeoColors.softCyan,
      route: '/tool/resize',
      category: 'edit',
      tag: 'ESSENTIAL',
    ),
    ToolItem(
      id: 'crop',
      title: 'Crop & Rotate',
      subtitle: 'Freehand, 1:1, 16:9 presets',
      icon: Icons.crop_rounded,
      accentColor: NeoColors.pink,
      softColor: NeoColors.softPink,
      route: '/tool/crop',
      category: 'edit',
      tag: 'FAST',
    ),
    ToolItem(
      id: 'convert',
      title: 'Format Convert',
      subtitle: 'JPG, PNG, WebP & HEIC',
      icon: Icons.transform_rounded,
      accentColor: NeoColors.green,
      softColor: NeoColors.softGreen,
      route: '/tool/convert',
      category: 'convert',
      tag: 'BATCH',
    ),
    ToolItem(
      id: 'id_photo',
      title: 'Passport Photo',
      subtitle: 'Official ID standard sizes',
      icon: Icons.badge_rounded,
      accentColor: NeoColors.orange,
      softColor: NeoColors.softOrange,
      route: '/tool/id_photo',
      category: 'utilities',
      tag: 'SMART',
    ),
    ToolItem(
      id: 'signature',
      title: 'Digital Signature',
      subtitle: 'Draw & export PNG sign',
      icon: Icons.draw_rounded,
      accentColor: NeoColors.blue,
      softColor: NeoColors.softCyan,
      route: '/tool/signature',
      category: 'utilities',
      tag: 'VECTOR',
    ),
    ToolItem(
      id: 'remove_bg',
      title: 'Remove Background',
      subtitle: '100% on-device AI cutout',
      icon: Icons.auto_fix_high_rounded,
      accentColor: NeoColors.purple,
      softColor: NeoColors.softPurple,
      route: '/tool/remove_bg',
      category: 'edit',
      tag: '🤖 AI OFFLINE',
    ),
  ];

  HomeBloc({List<ToolItem> initialTools = defaultTools})
      : super(HomeLoadedState(
          allTools: initialTools,
          filteredTools: initialTools,
        )) {
    on<LoadHomeToolsEvent>(_onLoadTools);
    on<SearchToolsEvent>(_onSearchTools);
    on<FilterCategoryEvent>(_onFilterCategory);
  }

  void _onLoadTools(LoadHomeToolsEvent event, Emitter<HomeState> emit) {
    final currentTools = state is HomeLoadedState
        ? (state as HomeLoadedState).allTools
        : defaultTools;
    emit(HomeLoadedState(
      allTools: currentTools,
      filteredTools: currentTools,
    ));
  }

  void _onSearchTools(SearchToolsEvent event, Emitter<HomeState> emit) {
    if (state is! HomeLoadedState) return;
    final current = state as HomeLoadedState;
    final filtered = _filter(current.allTools, event.query, current.selectedCategory);
    emit(current.copyWith(
      searchQuery: event.query,
      filteredTools: filtered,
    ));
  }

  void _onFilterCategory(FilterCategoryEvent event, Emitter<HomeState> emit) {
    if (state is! HomeLoadedState) return;
    final current = state as HomeLoadedState;
    final filtered = _filter(current.allTools, current.searchQuery, event.category);
    emit(current.copyWith(
      selectedCategory: event.category,
      filteredTools: filtered,
    ));
  }

  List<ToolItem> _filter(List<ToolItem> tools, String query, String category) {
    return tools.where((t) {
      final matchesSearch =
          t.title.toLowerCase().contains(query.toLowerCase()) ||
          t.subtitle.toLowerCase().contains(query.toLowerCase());

      final matchesCategory =
          category == 'ALL' ||
          (category == 'POPULAR' && t.category == 'popular') ||
          (category == 'EDIT' && t.category == 'edit') ||
          (category == 'CONVERT' && t.category == 'convert') ||
          (category == 'UTILITIES' && t.category == 'utilities');

      return matchesSearch && matchesCategory;
    }).toList();
  }
}
