// ignore_for_file: subtype_of_sealed_class
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/rewards/data/datasources/remote/rewards_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late RewardsRemoteDataSourceImpl dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockDocumentSnapshot mockSnapshot;

  setUpAll(() {
    registerFallbackValue(const GetOptions());
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();
    dataSource = RewardsRemoteDataSourceImpl(mockFirestore);

    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);
    when(() => mockDocument.collection(any())).thenReturn(mockCollection);
  });

  group('RewardsRemoteDataSource', () {
    test('getAccount fetches from correct path', () async {
      when(() => mockDocument.get(any())).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({
        'profileId': 'p1',
        'points': 100,
        'experience': 200,
        'level': 1,
        'lifetimeEarnings': 100,
        'lastUpdatedAt': DateTime.now().toIso8601String(),
      });

      final result = await dataSource.getAccount('u1', 'p1');

      expect(result?.profileId, 'p1');
      expect(result?.points, 100);
      verify(() => mockFirestore.collection('users')).called(1);
    });
  });
}
