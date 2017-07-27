'use strict';

const path = require('path');
const es = require('event-stream');
const gutil = require('gulp-util');
const gulp = require('gulp');
const runSequence = require('run-sequence');
const rimraf = require('rimraf');
const sass = require('gulp-sass');
const webpack = require('webpack');
const WebpackDevServer = require('webpack-dev-server');

// Helpers
// -------

const debugVinyl = (title) => {
  return es.mapSync((file) => {
    if (file.isBuffer()) {
      const contents = file.contents.toString();
      console.log(title, file.relative, contents.length);
    }
    return file;
  });
};

// Configuration
// -------------

const SRC_DIR = path.resolve('src');
const DEST_DIR = path.resolve('dist');

const JS_DIR = 'javascripts';
const JS_SRC_DIR = path.join(SRC_DIR, JS_DIR);
const JS_ENTRY_FILE = path.join(JS_SRC_DIR, 'flow_viz.coffee');
const JS_DEST_DIR = path.join(DEST_DIR, JS_DIR);
const JS_DEST_FILE = 'flow_viz.js';

const SASS_DIR = 'stylesheets';
const SASS_SRC_DIR = path.join(SRC_DIR, SASS_DIR);
const SASS_SRC_FILES = path.join(SASS_SRC_DIR, '*.sass');
const SASS_ENTRY_FILE = path.join(SASS_SRC_DIR, 'flow_viz.sass');
const SASS_DEST_DIR = path.join(DEST_DIR, SASS_DIR);

const HTML_SRC_FILES = path.join(SRC_DIR, '*.html');
const HTML_DEST_DIR = DEST_DIR;

const CONFIG_DIR = 'example_configuration';
const CONFIG_SRC_DIR = path.join(SRC_DIR, CONFIG_DIR);
const CONFIG_SRC_FILES = path.join(CONFIG_SRC_DIR, '*.js');
const CONFIG_DEST_DIR = path.join(DEST_DIR, CONFIG_DIR);

const IMAGE_DIR = 'images';
const IMAGE_SRC_DIR = path.join(SRC_DIR, IMAGE_DIR);
const IMAGE_SRC_FILES = path.join(IMAGE_SRC_DIR, '*');
const IMAGE_DEST_DIR = path.join(DEST_DIR, IMAGE_DIR);

const DEV_SERVER_PORT = 8080;

// Webpack base config

const webpackConfig = {
  devtool: 'cheap-module-eval-source-map',
  context: JS_SRC_DIR,
  entry: JS_ENTRY_FILE,
  output: {
    path: JS_DEST_DIR,
    filename: JS_DEST_FILE
  },
  resolve: {
    root: JS_SRC_DIR,
    extensions: ['', '.js', '.coffee'],
     alias: {
       'underscore': 'lodash'
     }
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' },
      { test: /\.hamlc/, loader: 'hamlc-loader' }
    ]
  }
};

// Webpack production build config

const webpackBuildConfig = Object.create(webpackConfig);
webpackBuildConfig.devtool = 'source-map';
webpackBuildConfig.plugins = [
  new webpack.optimize.OccurenceOrderPlugin(),
  new webpack.optimize.UglifyJsPlugin({
    compressor: {
      warnings: false
    }
  })
];

// Clean
// -----

gulp.task('clean', (callback) => {
  rimraf(DEST_DIR, callback);
});

// Sass
// ----

const sassErrorHandler = function(error) {
  console.error(error.messageFormatted);
  // Necessary so the stream does not break
  this.emit('end');
};

const sassOptions = {
  outputStyle: 'expanded'
};

gulp.task('sass', () => {
  return gulp.src(SASS_ENTRY_FILE)
    .pipe(
      sass(sassOptions).on('error', sassErrorHandler)
    )
    .pipe(gulp.dest(SASS_DEST_DIR));
});

// Copy
// ----

gulp.task('copy:html', () =>
  gulp.src(HTML_SRC_FILES).pipe(gulp.dest(HTML_DEST_DIR))
);

gulp.task('copy:config', () =>
  gulp.src(CONFIG_SRC_FILES).pipe(gulp.dest(CONFIG_DEST_DIR))
);

gulp.task('copy:images', () =>
  gulp.src(IMAGE_SRC_FILES).pipe(gulp.dest(IMAGE_DEST_DIR))
);

gulp.task('copy', ['copy:html', 'copy:config', 'copy:images']);

// Webpack
// -------

gulp.task('webpack', (callback) => {
  webpack(webpackBuildConfig, (err, stats) => {
    if (err) {
      throw new gutil.PluginError('webpack', err);
    }
    gutil.log('[webpack]', stats.toString({
      // output options
    }));
    callback();
  });
});

// Webpack Development server

gulp.task('webpack-dev-server', () => {
  const compiler = webpack(webpackConfig);

  new WebpackDevServer(compiler, {
    contentBase: DEST_DIR,
    publicPath: '/javascripts/',
    noInfo: true
  }).listen(DEV_SERVER_PORT, 'localhost', (err) => {
    if (err) {
      throw new gutil.PluginError('webpack-dev-server', err);
    }
    gutil.log(
      'Development server is running at http://localhost:' + DEV_SERVER_PORT
    );
  });
});

// Watching
// --------

gulp.task('watch:html', () =>
  gulp.watch(HTML_SRC_FILES, ['copy:html'])
);

gulp.task('watch:config', () =>
  gulp.watch(CONFIG_SRC_FILES, ['copy:config'])
);

gulp.task('watch:images', () =>
  gulp.watch(IMAGE_SRC_FILES, ['copy:images'])
);

gulp.task('watch:sass', () =>
  gulp.watch(SASS_SRC_FILES, ['sass'])
);

gulp.task(
  'watch',
  ['watch:html', 'watch:config', 'watch:images', 'watch:sass']
);

// High-level tasks
// ----------------

gulp.task('default', (callback) => {
  runSequence(
    'clean',
    ['copy', 'sass', 'watch', 'webpack-dev-server'],
    callback
  )
});

gulp.task('build', (callback) => {
  runSequence(
    'clean',
    ['copy', 'sass', 'webpack'],
    callback
  );
});
