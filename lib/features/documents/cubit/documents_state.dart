part of 'documents_cubit.dart';

class DocumentsState extends DocumentPagingState {
  final List<DocumentModel> selection;
  final Map<int, Correspondent> correspondents;
  final Map<int, DocumentType> documentTypes;
  final Map<int, Tag> tags;
  final Map<int, StoragePath> storagePaths;

  final ViewType viewType;

  const DocumentsState({
    this.selection = const [],
    this.viewType = ViewType.list,
    super.value = const [],
    super.filter = const DocumentFilter(),
    super.hasLoaded = false,
    super.isLoading = false,
    this.correspondents = const {},
    this.documentTypes = const {},
    this.tags = const {},
    this.storagePaths = const {},
  });

  List<int> get selectedIds => selection.map((e) => e.id).toList();

  DocumentsState copyWith({
    bool? hasLoaded,
    bool? isLoading,
    List<PagedSearchResult<DocumentModel>>? value,
    DocumentFilter? filter,
    List<DocumentModel>? selection,
    ViewType? viewType,
    Map<int, Correspondent>? correspondents,
    Map<int, DocumentType>? documentTypes,
    Map<int, Tag>? tags,
    Map<int, StoragePath>? storagePaths,
  }) {
    return DocumentsState(
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isLoading: isLoading ?? this.isLoading,
      value: value ?? this.value,
      filter: filter ?? this.filter,
      selection: selection ?? this.selection,
      viewType: viewType ?? this.viewType,
      correspondents: correspondents ?? this.correspondents,
      documentTypes: documentTypes ?? this.documentTypes,
      tags: tags ?? this.tags,
      storagePaths: storagePaths ?? this.storagePaths,
    );
  }

  @override
  List<Object?> get props => [
        selection,
        viewType,
        correspondents,
        documentTypes,
        tags,
        storagePaths,
        super.filter,
        super.hasLoaded,
        super.isLoading,
        super.value,
      ];

  @override
  DocumentsState copyWithPaged({
    bool? hasLoaded,
    bool? isLoading,
    List<PagedSearchResult<DocumentModel>>? value,
    DocumentFilter? filter,
  }) {
    return copyWith(
      filter: filter,
      hasLoaded: hasLoaded,
      isLoading: isLoading,
      value: value,
    );
  }
}
