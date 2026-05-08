import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'package:core/widgets/schema_form_builder.dart';
import 'package:core/services/game_model_service.dart';
import 'package:provider/provider.dart';

typedef CharacterSaveCallback = void Function(GameEntity character);

class CharacterSheetScreen extends StatefulWidget {
  const CharacterSheetScreen({
    super.key,
    this.character,
    required this.onSave,
    required this.onCancel,
  });

  final GameEntity? character;
  final CharacterSaveCallback onSave;
  final VoidCallback onCancel;

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _data;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.character != null;
    _data = _isEditMode
        ? Map<String, dynamic>.from(widget.character!.toJson()['data'] as Map)
        : <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameModelService, GameModel?>(
      selector: (_, service) => service.activeModel,
      builder: (context, gameModel, child) {
        if (gameModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final characterType = _findCharacterEntityType(gameModel);
        if (characterType == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Character Sheet'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
            body: const Center(
              child: Text('No character entity type defined in this game system'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? 'Edit Character' : 'Create Character'),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
                tooltip: 'Cancel',
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _save,
                tooltip: 'Save Character',
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SchemaFormBuilder(
              fields: characterType.fields,
              data: _data,
              onDataChanged: (updated) => setState(() => _data = updated),
              gameModel: gameModel,
            ),
          ),
        );
      },
    );
  }

  EntityTypeSchema? _findCharacterEntityType(GameModel gameModel) {
    // First try to find entity type with key 'character'
    for (final type in gameModel.entityTypes) {
      if (type.key == 'character') return type;
    }
    // Fallback: first entity type that is NOT a wiki page type
    for (final type in gameModel.entityTypes) {
      if (!type.isWikiPageType) return type;
    }
    // Last fallback: first entity type (for systems like D&D where 'creature' is used for both)
    return gameModel.entityTypes.isNotEmpty ? gameModel.entityTypes.first : null;
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      final entity = GameEntity(
        entityTypeKey: _findCharacterEntityType(
          context.read<GameModelService>().activeModel!,
        )?.key ??
            'character',
        data: Map<String, dynamic>.from(_data),
      );
      widget.onSave(entity);
    }
  }
}
