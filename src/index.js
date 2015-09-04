'use strict'

var fs = require('fs');
var path = require('path');

function fileSizeTree(directoryPath, options) {
  if (!isValidDirectoryPath(directoryPath)) return null;

  var treeObjectKeys = configureTreeObjectKeysWithOptions(options);
  return buildFileSizeTree(directoryPath);

  function buildFileSizeTree(directoryPath) {
    var resolvedDirectoryPath = fs.realpathSync(directoryPath)

    var directoryNode = {};
    directoryNode[treeObjectKeys.directoryName] = path.basename(resolvedDirectoryPath);
    directoryNode[treeObjectKeys.files] = [];

    var directory = readDirectory(directoryPath);
    if (directory) {
      directory.forEach(function(file) {
        var resolvedFilePath = path.join(resolvedDirectoryPath, file);
        var fileInfo = getFileInfo(resolvedFilePath);
        if (fileInfo) {
          if (fileInfo.isDirectory()) {
            directoryNode[treeObjectKeys.files].push(buildFileSizeTree(resolvedFilePath));
          } else {
            var fileNode = {};
            fileNode[treeObjectKeys.fileName] = file;
            fileNode[treeObjectKeys.fileSize] = fileInfo['size'];
            directoryNode[treeObjectKeys.files].push(fileNode);
          }
        }
      });
    }
    return directoryNode;
  }
}

function isValidDirectoryPath(directoryPath) {
  var isValid = false;
  if (directoryPath) {
    try {
      fs.realpathSync(directoryPath);
      isValid = true;
    } catch (e) {
      // The exceptions caught here are generally thrown when
      // the path is invalid or when we do not have permission
      // to read the file information so we ignore them.
    }
  }
  return isValid;
}

function configureTreeObjectKeysWithOptions(options) {
  options = options || {};
  return {
    directoryName: options.directoryName || 'directoryName',
            files: options.files         || 'files',
         fileName: options.fileName      || 'fileName',
         fileSize: options.fileSize      || 'size'
  };
}

function readDirectory(directoryPath) {
  var directory = null;
  try {
    directory = fs.readdirSync(directoryPath);
  } catch (e) {
    // The exceptions caught here are generally thrown when
    // the path is invalid or when we do not have permission
    // to read the directory so we ignore them.
  }
  return directory;
}

function getFileInfo(filePath) {
  var fileInfo = null;
  try {
    fileInfo = fs.lstatSync(filePath);
  } catch (e) {
    // The exceptions caught here are generally thrown when we do not
    // have permission to read the file information so we ignore them.
  }
  return fileInfo;
}

module.exports = fileSizeTree;
