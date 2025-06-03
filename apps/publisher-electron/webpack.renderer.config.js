const path = require('path');
module.exports = {
  entry: './renderer/renderer.ts',
  target: 'electron-renderer',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'renderer.js'
  },
  resolve: {
    extensions: ['.ts', '.js', '.jsx'],
    alias: {
      '@renderer': path.resolve(__dirname, 'renderer'),
      '@services': path.resolve(__dirname, 'services'),
      '@config': path.resolve(__dirname, 'config')
    }
  },
  module: {
    rules: [
      {
        test: /\\.tsx?$/,
        include: /renderer/,
        use: [{ loader: 'ts-loader' }]
      },
      {
        test: /\\.css$/,
        use: ['style-loader', 'css-loader']
      },
      {
        test: /\\.(png|jpg|gif|svg)$/,
        use: [{ loader: 'file-loader' }]
      }
    ]
  }
};
