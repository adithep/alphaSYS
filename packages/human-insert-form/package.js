Package.describe({
  summary: "REPLACEME - What does this package (or the original one you're wrapping) do?"
});

Package.on_use(function (api, where) {
  api.use(['coffeescript', 'stylus', 'jade'], ['client', 'server']);
  api.use(['spacebars', 'ui', 'standard-app-packages', 'core-layout', 'data-lib', 'phoneformat', 'repeat-component'], 'client');
  api.add_files(['human-insert-form.jade', 'human-insert-form.coffee'], 'client');
});

Package.on_test(function (api) {
  api.use('human-insert-form');

  api.add_files('human-insert-form_tests.js', ['client', 'server']);
});
