Package.describe({
  summary: "REPLACEME - What does this package (or the original one you're wrapping) do?"
});

Package.on_use(function (api, where) {
  api.use('lodash');
  api.use(['coffeescript', 'stylus'], ['client', 'server']);
  api.add_files('rloop.coffee', 'server');
  api.export('re', 'server');
});

Package.on_test(function (api) {
  api.use('rloop');

  api.add_files('rloop_tests.js', ['client', 'server']);
});
