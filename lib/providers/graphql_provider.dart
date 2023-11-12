import 'package:graphql/client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Env {
  const Env(this.baseUrl, this.httpUrl);
  final String baseUrl;
  final String httpUrl;
}

const _env = Env(
  String.fromEnvironment('BASE_URL', defaultValue: ''),
  String.fromEnvironment('HTTP_URL', defaultValue: ''),
);

final envProvider = Provider((ref) {
  return _env;
});

final graphQlClientProvider = Provider((ref) => getClient(uri: ref.read(envProvider).httpUrl));

GraphQLClient getClient({required String uri, String? subscriptionUri}) {
  Link link = HttpLink(uri);
  if (subscriptionUri != null) {
    final WebSocketLink webSocketLink = WebSocketLink(subscriptionUri,
        config: const SocketClientConfig(autoReconnect: true, inactivityTimeout: _inactivityTimeout));
    link = Link.split((request) => request.isSubscription, webSocketLink, link);
  }
  return GraphQLClient(link: link, cache: _cache);
}

final _cache = GraphQLCache();

const _inactivityTimeout = Duration(seconds: 30);
