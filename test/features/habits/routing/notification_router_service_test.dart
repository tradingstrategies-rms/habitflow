import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/features/habits/application/services/notification_router_service.dart';
import 'package:habitflow/core/router/route_names.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter router;
  late NotificationRouterService service;

  setUp(() {
    router = MockGoRouter();
    service = NotificationRouterService(router);
  });

  group('NotificationRouterService', () {
    test('handleNotificationTap navigates for valid payload', () {
      const payload = '{"habitId": "h123", "reminderId": "r1"}';
      
      service.handleNotificationTap(payload);

      verify(() => router.pushNamed(
        RouteNames.habitDetails,
        pathParameters: {'habitId': 'h123'},
      )).called(1);
    });

    test('handleNotificationTap does nothing for invalid payload', () {
      service.handleNotificationTap('invalid-json');
      verifyNever(() => router.pushNamed(any(), pathParameters: any(named: 'pathParameters')));
    });

    test('handleNotificationTap does nothing for empty payload', () {
      service.handleNotificationTap(null);
      service.handleNotificationTap('');
      verifyNever(() => router.pushNamed(any(), pathParameters: any(named: 'pathParameters')));
    });
  });
}
