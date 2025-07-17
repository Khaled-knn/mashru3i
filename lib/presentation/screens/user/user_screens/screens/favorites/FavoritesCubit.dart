// lib/cubits/favorite_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../data/creatorsItems.dart';
import 'favorites_database.dart';

class FavoriteState {
  final Set<int> favoriteCreatorIds;
  final List<CreatorItem> favoriteCreatorsList;

  FavoriteState({required this.favoriteCreatorIds, required this.favoriteCreatorsList});

  FavoriteState copyWith({
    Set<int>? favoriteCreatorIds,
    List<CreatorItem>? favoriteCreatorsList,
  }) {
    return FavoriteState(
      favoriteCreatorIds: favoriteCreatorIds ?? this.favoriteCreatorIds,
      favoriteCreatorsList: favoriteCreatorsList ?? this.favoriteCreatorsList,
    );
  }
}

class FavoriteCubit extends Cubit<FavoriteState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  FavoriteCubit() : super(FavoriteState(favoriteCreatorIds: {}, favoriteCreatorsList: [])) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _databaseHelper.getFavoriteCreators();
    final favoriteIds = favorites.map((c) => c.id).toSet();
    emit(state.copyWith(
      favoriteCreatorIds: favoriteIds,
      favoriteCreatorsList: favorites,
    ));
  }

  Future<void> toggleFavorite(CreatorItem creator) async {
    final currentFavorites = Set<int>.from(state.favoriteCreatorIds);
    final currentCreatorsList = List<CreatorItem>.from(state.favoriteCreatorsList);

    if (currentFavorites.contains(creator.id)) {
      await _databaseHelper.removeFavoriteCreator(creator.id);
      currentFavorites.remove(creator.id);
      currentCreatorsList.removeWhere((item) => item.id == creator.id);
    } else {
      await _databaseHelper.addFavoriteCreator(creator);
      currentFavorites.add(creator.id);
      currentCreatorsList.add(creator);
    }
    emit(state.copyWith(
      favoriteCreatorIds: currentFavorites,
      favoriteCreatorsList: currentCreatorsList,
    ));
  }

  bool isFavorite(int creatorId) {
    return state.favoriteCreatorIds.contains(creatorId);
  }
}