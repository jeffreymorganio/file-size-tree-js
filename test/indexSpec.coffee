'use strict'

fs = require('fs')
tmp = require('tmp')
path = require('path')
touch = require('touch')

chai = require('chai')
chai.use(require('chai-things'))
assert = chai.assert
expect = chai.expect
should = chai.should()

fileSizeTree = require('../src/index')

NOT_FOUND = -1

describe 'The fileSizeTree() function', ->

  tmp.setGracefulCleanup()

  it 'should be defined', ->
    assert.isDefined(fileSizeTree)

  it 'should return null when the path is null', ->
    directoryPath = null
    tree = fileSizeTree(directoryPath)
    assert.isNull(tree)

  it 'should return null when the path is empty', ->
    directoryPath = ''
    tree = fileSizeTree(directoryPath)
    assert.isNull(tree)

  it 'should return null when the path is not a directory', ->
    directoryPath = '/not/a/path/to/a/directory'
    tree = fileSizeTree(directoryPath)
    assert.isNull(tree)

  it 'should not return null for a valid directory', ->
    testDirectory = createTestDirectory()
    testDirectoryPath = testDirectory.name
    tree = fileSizeTree(testDirectoryPath)
    expect(tree).to.exist

  it 'should return an object for a valid directory', ->
    testDirectory = createTestDirectory()
    testDirectoryPath = testDirectory.name
    tree = fileSizeTree(testDirectoryPath)
    expect(tree).to.be.an('object')

  it 'should return a tree object representing an empty directory', ->
    testDirectory = createTestDirectory()
    testDirectoryPath = testDirectory.name
    tree = fileSizeTree(testDirectoryPath)
    expect(tree.directoryName).to.equal(path.basename(testDirectoryPath))
    expect(tree.files.length).to.equal(0)

  it 'should return a tree object representing a directory with one file', ->
    testDirectory = createTestDirectory()
    testDirectoryPath = testDirectory.name

    fileName = 'a'
    createFile(testDirectoryPath, fileName)

    tree = fileSizeTree(testDirectoryPath)
    expect(tree.directoryName).to.equal(path.basename(testDirectoryPath))
    expect(tree.files.length).to.equal(1)

    file = tree.files[0]
    expect(file.fileName).to.equal(fileName)
    expect(file.size).to.equal(0)

  it 'should return a tree object representing a directory with one file using custom tree object key names', ->
    testDirectory = createTestDirectory()
    testDirectoryPath = testDirectory.name

    fileName = 'a'
    createFile(testDirectoryPath, fileName)

    customDirectoryNameKey = '_directoryName'
    customFilesKey = '_files'
    customFileNameKey = '_filename'
    customFileSizeKey = '_size'

    options =
      directoryName: customDirectoryNameKey
      files: customFilesKey
      fileName: customFileNameKey
      fileSize: customFileSizeKey

    tree = fileSizeTree(testDirectoryPath, options)
    expect(tree[customDirectoryNameKey]).to.equal(path.basename(testDirectoryPath))
    expect(tree[customFilesKey].length).to.equal(1)

    file = tree[customFilesKey][0]
    expect(file[customFileNameKey]).to.equal(fileName)
    expect(file[customFileSizeKey]).to.equal(0)

  it 'should return a tree object representing a directory structure', ->
    testDirectory = createTestDirectory()
    testDirectoryPath = testDirectory.name

    directoryNameA = 'A'
    directoryA = path.join(testDirectoryPath, directoryNameA)
    createDirectory(testDirectoryPath, directoryNameA)

    directoryNameB = 'B'
    directoryB = path.join(directoryA, directoryNameB)
    createDirectory(directoryA, directoryNameB)

    directoryNameC = 'C'
    directoryC = path.join(testDirectoryPath, directoryNameC)
    createDirectory(testDirectoryPath, directoryNameC)

    fileNameA1 = 'a1'; createFile(directoryA, fileNameA1)
    fileNameA2 = 'a2';  createFile(directoryA, fileNameA2)

    fileNameB1 = 'b1'; createFile(directoryB, fileNameB1)
    fileNameB2 = 'b2';  createFile(directoryB, fileNameB2)

    fileNameC1 = 'c1'; createFile(directoryC, fileNameC1)
    fileNameC2 = 'c2';  createFile(directoryC, fileNameC2)

    testFileObjectA1 = { fileName: fileNameA1, size: 0 }
    testFileObjectA2 = { fileName: fileNameA2, size: 0 }

    testFileObjectB1 = { fileName: fileNameB1, size: 0 }
    testFileObjectB2 = { fileName: fileNameB2, size: 0 }

    testFileObjectC1 = { fileName: fileNameC1, size: 0 }
    testFileObjectC2 = { fileName: fileNameC2, size: 0 }

    tree = fileSizeTree(testDirectoryPath)

    # Check for presence of directory A
    indexOfActualDirectoryA = indexOfDirectoryObject(tree, directoryNameA)
    assert.isAbove(indexOfActualDirectoryA, NOT_FOUND)
    actualDirectoryA = tree.files[indexOfActualDirectoryA]
    actualDirectoryA.files.should.include.something.that.deep.equals(testFileObjectA1)
    actualDirectoryA.files.should.include.something.that.deep.equals(testFileObjectA2)

    # Check for presence of directory B within directory A
    indexOfActualDirectoryB = indexOfDirectoryObject(actualDirectoryA, directoryNameB)
    assert.isAbove(indexOfActualDirectoryB, NOT_FOUND)
    actualDirectoryB = actualDirectoryA.files[indexOfActualDirectoryB]
    expect(actualDirectoryB.directoryName).to.equal(directoryNameB)
    actualDirectoryB.files.should.include.something.that.deep.equals(testFileObjectB1)
    actualDirectoryB.files.should.include.something.that.deep.equals(testFileObjectB2)

    # Check for presence of directory C
    indexOfActualDirectoryC = indexOfDirectoryObject(tree, directoryNameC)
    assert.isAbove(indexOfActualDirectoryC, NOT_FOUND)
    actualDirectoryC = tree.files[indexOfActualDirectoryC]
    expect(actualDirectoryC.directoryName).to.equal(directoryNameC)
    actualDirectoryC.files.should.include.something.that.deep.equals(testFileObjectC1)
    actualDirectoryC.files.should.include.something.that.deep.equals(testFileObjectC2)

indexOfDirectoryObject = (treeNode, directoryName) ->
  foundAtIndex = NOT_FOUND
  treeNode.files.forEach (fileObject, index) ->
    if fileObject.directoryName and fileObject.directoryName is directoryName
      foundAtIndex = index
  foundAtIndex

createTestDirectory = ->
  tmp.dirSync()

createDirectory = (pathTo, directoryName) ->
  fs.mkdirSync(path.join(pathTo, directoryName))

createFile = (pathTo, filename) ->
  touch.sync(path.join(pathTo, filename))
