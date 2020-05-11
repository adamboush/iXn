import 'package:doppio_dev_ixn/core/index.dart';
import 'package:doppio_dev_ixn/main.dart';
import 'package:doppio_dev_ixn/project_setting/index.dart';
import 'package:doppio_dev_ixn/service/index.dart';
import 'package:flutter/material.dart';
import 'package:doppio_dev_ixn/project/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:uuid/uuid.dart';

class ProjectPage extends StatefulWidget {
  static const String routeName = '/project';

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final _projectBloc = ProjectBloc();
  ProjectModel projectModel;
  int currentVersionState;

  ProjectScreen projectScreen;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _projectBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      bloc: _projectBloc,
      builder: (
        BuildContext context,
        ProjectState currentState,
      ) {
        ContextService().buidlContext(context);
        if (currentState is InProjectState) {
          if (projectModel == null) {
            projectModel = currentState.project.copyWith();
            currentVersionState = currentState.version;
          }

          // change setting
          if (currentVersionState != currentState.version) {
            currentVersionState = currentState.version;
            final pr = currentState.project;
            projectModel = projectModel.copySettings(
              defaultLocale: pr.defaultLocale,
              locales: pr.locales,
              name: pr.name,
              formats: pr.formats,
            );
          }
        }
        projectScreen = ProjectScreen(projectBloc: _projectBloc, projectModel: projectModel);
        final i10n = TranslateService().locale;
        final name = projectModel?.name ?? i10n.project_name_no;
        return Scaffold(
          appBar: AppBar(
            title: Text(i10n.project_name_title(name)),
            actions: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  final args = ModalRoute.of(context).settings.arguments as Map<String, Object>;
                  if (args == null) {
                    print('args==null');
                    return;
                  }
                  final id = args['id'] as String;
                  unawaited(navigatorKey.currentState.pushNamed(
                    ProjectSettingPage.routeName,
                    arguments: {'id': id},
                  ));
                },
              )
            ],
          ),
          persistentFooterButtons: <Widget>[
            Container(
              width: ContextService().deviceSize.width,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      _addKey();
                    },
                    tooltip: i10n.project_add,
                    icon: Icon(Icons.add),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      await projectModel.export();
                    },
                    tooltip: i10n.project_export,
                    icon: Icon(Icons.file_upload),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _import();
                    },
                    tooltip: i10n.project_import,
                    icon: Icon(Icons.file_download),
                  ),
                  IconButton(
                    onPressed: () async {
                      _projectBloc.add(SaveProjectEvent(projectModel));
                    },
                    tooltip: i10n.project_save,
                    icon: Icon(Icons.save),
                  ),
                ],
              ),
            ),
          ],
          body: projectScreen,
        );
      },
    );
  }

  Future _import() async {
    try {
      final filesData = await TranslateService().importFiles();
      for (var locale in filesData?.keys ?? <String>[]) {
        var localeCode = TranslateService.countryName2Code.entries.firstWhere((element) => element.value == locale);
        var localeModel = LocaleModel.from(localeCode);
        setState(() {
          projectModel.import(localeModel, filesData[locale]);
        });
      }
    } catch (_, stackTrace) {
      log(_?.toString(), name: 'ProjectsPage', error: _, stackTrace: stackTrace);
      NotificationService.showError(_?.toString());
    }
  }

  void _addKey() {
    setState(() {
      var newKeys = projectModel.keys ?? [];
      newKeys.add(KeyModel(id: Uuid().v4()));
    });
  }
}
