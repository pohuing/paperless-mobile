import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:paperless_api/paperless_api.dart';
import 'package:paperless_mobile/core/widgets/form_builder_fields/extended_date_range_form_field/form_builder_extended_date_range_picker.dart';
import 'package:paperless_mobile/extensions/flutter_extensions.dart';
import 'package:paperless_mobile/features/documents/view/widgets/search/query_type_form_field.dart';
import 'package:paperless_mobile/features/labels/bloc/label_cubit.dart';
import 'package:paperless_mobile/features/labels/bloc/label_state.dart';
import 'package:paperless_mobile/features/labels/tags/view/widgets/tags_form_field.dart';
import 'package:paperless_mobile/features/labels/view/widgets/label_form_field.dart';
import 'package:paperless_mobile/generated/l10n.dart';
import 'package:paperless_mobile/util.dart';

enum DateRangeSelection { before, after }

class DocumentFilterPanel extends StatefulWidget {
  final DocumentFilter initialFilter;
  final ScrollController scrollController;
  const DocumentFilterPanel({
    Key? key,
    required this.initialFilter,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<DocumentFilterPanel> createState() => _DocumentFilterPanelState();
}

class _DocumentFilterPanelState extends State<DocumentFilterPanel> {
  static const fkCorrespondent = DocumentModel.correspondentKey;
  static const fkDocumentType = DocumentModel.documentTypeKey;
  static const fkStoragePath = DocumentModel.storagePathKey;
  static const fkQuery = "query";
  static const fkCreatedAt = DocumentModel.createdKey;
  static const fkAddedAt = DocumentModel.addedKey;

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.done),
            label: Text(S.of(context).documentFilterApplyFilterLabel),
            onPressed: _onApplyFilter,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: _resetFilter,
                icon: const Icon(Icons.refresh),
                label: Text(S.of(context).documentFilterResetLabel),
              )
            ],
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: FormBuilder(
          key: _formKey,
          child: ListView(
            controller: widget.scrollController,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Text(
                S.of(context).documentFilterTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ).paddedOnly(
                top: 16.0,
                left: 16.0,
                bottom: 24,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  S.of(context).documentFilterSearchLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ).paddedOnly(left: 8.0),
              _buildQueryFormField().padded(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  S.of(context).documentFilterAdvancedLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ).padded(),
              FormBuilderExtendedDateRangePicker(
                name: DocumentModel.createdKey,
                initialValue: widget.initialFilter.created,
                labelText: S.of(context).documentCreatedPropertyLabel,
              ).padded(),
              FormBuilderExtendedDateRangePicker(
                name: DocumentModel.addedKey,
                initialValue: widget.initialFilter.added,
                labelText: S.of(context).documentAddedPropertyLabel,
              ).padded(),
              _buildCorrespondentFormField().padded(),
              _buildDocumentTypeFormField().padded(),
              _buildStoragePathFormField().padded(),
              _buildTagsFormField().padded(),
            ],
          ).paddedOnly(bottom: 16),
        ),
      ),
    );
  }

  BlocBuilder<LabelCubit<Tag>, LabelState<Tag>> _buildTagsFormField() {
    return BlocBuilder<LabelCubit<Tag>, LabelState<Tag>>(
      builder: (context, state) {
        return TagFormField(
          name: DocumentModel.tagsKey,
          initialValue: widget.initialFilter.tags,
          allowCreation: false,
          selectableOptions: state.labels,
        );
      },
    );
  }

  void _resetFilter() async {
    FocusScope.of(context).unfocus();
    Navigator.pop(
        context,
        DocumentFilter.initial.copyWith(
          sortField: widget.initialFilter.sortField,
          sortOrder: widget.initialFilter.sortOrder,
        ));
  }

  Widget _buildDocumentTypeFormField() {
    return BlocBuilder<LabelCubit<DocumentType>, LabelState<DocumentType>>(
      builder: (context, state) {
        return LabelFormField<DocumentType>(
          formBuilderState: _formKey.currentState,
          name: fkDocumentType,
          labelOptions: state.labels,
          textFieldLabel: S.of(context).documentDocumentTypePropertyLabel,
          initialValue: widget.initialFilter.documentType,
          prefixIcon: const Icon(Icons.description_outlined),
        );
      },
    );
  }

  Widget _buildCorrespondentFormField() {
    return BlocBuilder<LabelCubit<Correspondent>, LabelState<Correspondent>>(
      builder: (context, state) {
        return LabelFormField<Correspondent>(
          formBuilderState: _formKey.currentState,
          name: fkCorrespondent,
          labelOptions: state.labels,
          textFieldLabel: S.of(context).documentCorrespondentPropertyLabel,
          initialValue: widget.initialFilter.correspondent,
          prefixIcon: const Icon(Icons.person_outline),
        );
      },
    );
  }

  Widget _buildStoragePathFormField() {
    return BlocBuilder<LabelCubit<StoragePath>, LabelState<StoragePath>>(
      builder: (context, state) {
        return LabelFormField<StoragePath>(
          formBuilderState: _formKey.currentState,
          name: fkStoragePath,
          labelOptions: state.labels,
          textFieldLabel: S.of(context).documentStoragePathPropertyLabel,
          initialValue: widget.initialFilter.storagePath,
          prefixIcon: const Icon(Icons.folder_outlined),
        );
      },
    );
  }

  Widget _buildQueryFormField() {
    final queryType =
        _formKey.currentState?.getRawValue(QueryTypeFormField.fkQueryType) ??
            QueryType.titleAndContent;
    late String label;
    switch (queryType) {
      case QueryType.title:
        label = S.of(context).documentFilterQueryOptionsTitleLabel;
        break;
      case QueryType.titleAndContent:
        label = S.of(context).documentFilterQueryOptionsTitleAndContentLabel;
        break;
      case QueryType.extended:
        label = S.of(context).documentFilterQueryOptionsExtendedLabel;
        break;
    }

    return FormBuilderTextField(
      name: fkQuery,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_outlined),
        labelText: label,
        suffixIcon: QueryTypeFormField(
          initialValue: widget.initialFilter.queryType,
          afterSelected: (queryType) => setState(() {}),
        ),
      ),
      initialValue: widget.initialFilter.queryText,
    );
  }

  void _onApplyFilter() async {
    _formKey.currentState?.save();
    if (_formKey.currentState?.validate() ?? false) {
      final v = _formKey.currentState!.value;
      DocumentFilter newFilter = _assembleFilter();
      try {
        FocusScope.of(context).unfocus();
        Navigator.pop(context, newFilter);
      } on PaperlessServerException catch (error, stackTrace) {
        showErrorMessage(context, error, stackTrace);
      }
    }
  }

  DocumentFilter _assembleFilter() {
    final v = _formKey.currentState!.value;
    return DocumentFilter(
      correspondent: v[fkCorrespondent] as IdQueryParameter? ??
          DocumentFilter.initial.correspondent,
      documentType: v[fkDocumentType] as IdQueryParameter? ??
          DocumentFilter.initial.documentType,
      storagePath: v[fkStoragePath] as IdQueryParameter? ??
          DocumentFilter.initial.storagePath,
      tags:
          v[DocumentModel.tagsKey] as TagsQuery? ?? DocumentFilter.initial.tags,
      queryText: v[fkQuery] as String?,
      created: (v[fkCreatedAt] as DateRangeQuery),
      added: (v[fkAddedAt] as DateRangeQuery),
      queryType: v[QueryTypeFormField.fkQueryType] as QueryType,
      asnQuery: widget.initialFilter.asnQuery,
      page: 1,
      pageSize: widget.initialFilter.pageSize,
      sortField: widget.initialFilter.sortField,
      sortOrder: widget.initialFilter.sortOrder,
    );
  }
}

DateTimeRange? _dateTimeRangeOfNullable(DateTime? start, DateTime? end) {
  if (start == null && end == null) {
    return null;
  }
  if (start != null && end != null) {
    return DateTimeRange(start: start, end: end);
  }
  assert(start != null || end != null);
  final singleDate = (start ?? end)!;
  return DateTimeRange(start: singleDate, end: singleDate);
}
