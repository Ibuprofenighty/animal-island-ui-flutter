{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: 'assets/fonts/',
  },
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  }
});
