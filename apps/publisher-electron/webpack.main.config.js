const path = require('path');
module.exports = {
  entry: './main/main.ts',
  target: 'electron-main',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'main.js'
  },
  resolve: {
    extensions: ['.ts', '.js'],
    alias: {
      '@main': path.resolve(__dirname, 'main'),
      '@services': path.resolve(__dirname, 'services'),
      '@config': path.resolve(__dirname, 'config')
    }
  },
  module: {
    rules: [
      {
        test: /\\.ts$/,
        include: /main/,
        use: [{ loader: 'ts-loader' }]
      }
    ]
  }
};
