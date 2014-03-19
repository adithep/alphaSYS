Package.describe({
  summary: "REPLACEME - What does this package (or the original one you're wrapping) do?"
});

Package.on_use(function (api, where) {
  api.use(['coffeescript', 'stylus', 'jade'], ['client', 'server']);
  api.use(['spacebars', 'ui', 'standard-app-packages', 'data-lib', 'phoneformat', 'observe-sequence', 'minimongo', 'accounts-base', 'accounts-password'], 'client');
  api.add_files(['core-layout.jade', 'schema.html', 'foundation.min.css', 'core-layout.styl', 'normalize.css', 'core-layout.coffee'], 'client');
  
});

Package.on_test(function (api) {
  api.use('core-layout');

  api.add_files('core-layout_tests.js', 'client');
});
