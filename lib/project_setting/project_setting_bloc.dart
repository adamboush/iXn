import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:doppio_dev_ixn/project_setting/index.dart';

class ProjectSettingBloc extends Bloc<ProjectSettingEvent, ProjectSettingState> {
  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  @override
  ProjectSettingState get initialState => UnProjectSettingState(0);

  @override
  Stream<ProjectSettingState> mapEventToState(
    ProjectSettingEvent event,
  ) async* {
    try {
      yield* event.applyAsync(currentState: state, bloc: this);
    } catch (_, stackTrace) {
      developer.log('$_', name: 'ProjectSettingBloc', error: _, stackTrace: stackTrace);
      yield state;
    }
  }
}
