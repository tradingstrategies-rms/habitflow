import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/features/habits/application/services/notification_router_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockRouter;
  late NotificationRouterService routerService;

  setUp(() {
    mockRouter = MockGoRouter();
    routerService = NotificationRouterService(mockRouter);
  });

  group('NotificationRouterService Hardening', () {
    test('should fallback to dashboard if push throws', () {
      when(() => mockRouter.push(any())).thenThrow(Exception('Route not found'));
      when(() => mockRouter.goNamed(any())).thenReturn(null);

      const payload = NotificationPayload(
        id: '1',
        title: 'T',
        body: 'B',
        type: NotificationType.system,
        route: '/invalid-route',
      );

      routerService.handleNotificationPayloadTap(payload);

      verify(() => mockRouter.goNamed('dashboard')).called(1);
    });

    test('should handle malformed JSON in handleNotificationTap', () {
      when(() => mockRouter.goNamed(any())).thenReturn(null);
      
      routerService.handleNotificationTap('invalid{json');

      verify(() => mockRouter.goNamed('dashboard')).called(1);
    });

    test('should handle missing route and metadata', () {
      when(() => mockRouter.goNamed(any())).thenReturn(null);
      
      const payload = NotificationPayload(
        id: '1',
        title: 'T',
        body: 'B',
        type: NotificationType.system,
      );

      routerService.handleNotificationPayloadTap(payload);

      verify(() => mockRouter.goNamed('dashboard')).called(1);
    });
  });
}
