var url       = require('url');
var qs        = require('querystring');
var Hash      = require('hashish');
var FORMATS   = require('./formats');
var util      = require('./util');

var ytdl = {};

var INFO_URL = 'http://www.youtube.com/get_video_info?hl=en_US&el=detailpage&video_id=';
var KEYS_TO_SPLIT = [
  'keywords'
, 'fmt_list'
, 'fexp'
, 'watermark'
, 'ad_channel_code_overlay'
];

/**
 * Gets info from a video.
 *
 * @param {String} link
 * @param {Object} requestOptions
 * @param {Function(Error, Object)} callback
 */
ytdl.getInfo = function getInfo(link, requestOptions, callback) {
  if (typeof requestOptions === 'function') {
    callback = requestOptions;
    requestOptions = {};
  } else {
    requestOptions = Hash.copy(requestOptions);
  }

  var linkParsed = url.parse(link, true);
  var id = linkParsed.hostname === 'youtu.be'
    ? linkParsed.pathname.slice(1) : linkParsed.query.v;

  if (!id) {
    process.nextTick(function() {
      callback(new Error('Video ID not found'));
    });
    return;
  }

  requestOptions.url = INFO_URL + id;

  forge.request.ajax(requestOptions, function(body, headers) {
    var info = qs.parse(body);
    var err = null;

    if (info.status === 'fail') {
      callback(new Error('Error ' + info.errorcode + ': ' + info.reason));
      return;
    }

    // Split some keys by commas.
    KEYS_TO_SPLIT.forEach(function(key) {
      if (!info[key]) return;
      info[key] = info[key].split(',').filter(function(v) { return v !== ''; });
    });

    // Convert some strings to javascript numbers and booleans.
    info = Hash.map(info, function(val) {
      var intVal = parseInt(val, 10);
      var floatVal = parseFloat(val, 10);

      if (intVal.toString() === val) {
        return intVal;
      } else if (floatVal.toString() === val) {
        return floatVal;
      } else if (val === 'True') {
        return true;
      } else if (val === 'False') {
        return false;
      } else {
        return val;
      }
    });

    if (info.fmt_list) {
      info.fmt_list = info.fmt_list.map(function(format) {
        return format.split('/');
      });
    } else {
      info.fmt_list = [];
    }

    if (info.url_encoded_fmt_stream_map) {
      info.formats = info.url_encoded_fmt_stream_map
        .split(',')
        .map(function(format) {
          var data = qs.parse(format);
          var parsedUrl = url.parse(data.url, true);
          delete parsedUrl.search;
          var query = parsedUrl.query;
          var sig = data.sig || data.s;

          if (sig) {
            query.signature = info.use_cipher_signature
              ? util.signatureDecipher(sig)
              : sig;
          }

          format = FORMATS[data.itag];

          if (!format) {
            err = new Error('No such format for itag ' + data.itag + ' found');
            return;
          }

          Hash(format).forEach(function(val, key) {
            data[key] = val;
          });
          data.url = url.format(parsedUrl);

          return data;
        });
    } else {
      info.formats = [];
    }

    delete info.url_encoded_fmt_stream_map;

    if (err) {
      return callback(err);
    }

    info.video_verticals = info.video_verticals
      .slice(1, -1)
      .split(', ')
      .filter(function(val) { return val !== ''; })
      .map(function(val) { return parseInt(val, 10); })
      ;

    callback(null, info);

  }, function(err) {
    callback(err);
  });
};

module.exports = ytdl;
