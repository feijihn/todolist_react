var path = require('path');
var DB = require('../index');
var uuid = require('uuid').v1;
var expect = require('chai').expect;

describe('SuperSimpleDB', function () {
  var db;

  describe('when I save an obj', function () {
    var expectedPath, expectedObj, expectedKey;

    beforeEach(function () {
      expectedKey = 'bam';
      expectedPath = path.join(__dirname, 'tmp', uuid() + '.json');
      expectedObj = {
        what: {
          ever: true
        }
      };

      db = new DB(expectedPath);

      db.set(expectedKey, expectedObj);
    });

    it('should write it to disk', function () {
      expect(require(expectedPath)[expectedKey]).to.eql(expectedObj);
    });
  });

  describe('when I get a key', function () {
    beforeEach(function () {
      db = new DB(path.join(__dirname, 'fixtures', 'db.json'));
    });

    it('should retrieve it from disk', function () {
      expect(db.get('foo')).to.eql({
        'bar': 'baz'
      });
    });
  });
});