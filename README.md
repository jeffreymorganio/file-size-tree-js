# file-size-tree-js

**file-size-tree-js** provides the `fileSizeTree` function that builds a JavaScript object representing a hierarchical directory structure. Each directory is represented as an object containing the name of the directory and an array containing the files and sub-directories in the directory. Each file is represented as an object containing the name of the file and its size in bytes. The following is an example directory structure object:

```
{
  directoryName: "aDirectory",
  files: [
    {
      fileName: "aFile",
      size: 93480243
    },
    {
      directoryName: "aSubDirectory",
      files: [
        {
          directoryName: "aSubSubDirectory",
          files: [
            {
              fileName: "anotherFile",
              size: 7293
            }
          ]
        }
      ]
    }
  ]
}
```

## Installation

```
npm install file-size-tree-js
```

**file-size-tree-js** has been tested on Mac OS X, Linux and Windows 7.

## Use

```
var fileSizeTree = require('file-size-tree-js');

var path = '/path/to/a/directory';
var tree = fileSizeTree(path);
```

## API

**fileSizeTree**(*path*[, *options*])

Returns a JavaScript object representing the hierarchical directory structure rooted at the supplied path, or `null` if the path is `null` or does not represent a valid path to a readable directory. Files and directories that cannot be read because the user calling `fileSizeTree` does not have read permission will be ignored.

The keys in the returned JavaScript object are configured by passing an options object as the second parameter to `fileSizeTree`. For example, the following directory structure object:

```
{
  directoryName: "aDirectory",
  files: [
    {
      fileName: "aFile",
      size: 892372
    }
  ]
}
```

was produced with the default keys shown in this options object:

```
{
  directoryName: "directoryName",
  files: "files",
  fileName: "fileName",
  fileSize: "size"
}
```

## Example: D3 Treemap Layout Configuration

One application of the `fileSizeTree` function is building a directory structure object suitable for use with the [D3 treemap layout](https://github.com/mbostock/d3/wiki/Treemap-Layout). The following options provide the correct keys for the treemap layout:

```
var options = {
  fileName: 'name',
  files: 'children',
  directoryName: 'name'
};
var path = '/path/to/a/directory';
var tree = fileSizeTree(path, options);
```
