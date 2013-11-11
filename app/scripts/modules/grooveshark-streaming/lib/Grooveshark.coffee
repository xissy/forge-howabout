crypto = require 'crypto'
async = require 'async'
uuid = require 'node-uuid'


class Grooveshark


lastRandomizer = null
groovesharkRequestUuid = uuid.v4()

randomizer = ->
  e = ""
  t = 0

  while t < 6
    e += Math.floor(Math.random() * 16).toString(16)
    t++
  (if e isnt lastRandomizer then e else randomizer())


Grooveshark.getStreamingUrl = (songID, callback) ->
  forge.logging.info "songID: #{songID}"

  if not songID? or songID.length is 0
    return callback new Error 'invalid SongID'

  forge.request.ajax
    type: 'GET'
    url: 'http://html5.grooveshark.com/'
    headers:
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      'Accept-Charset': 'UTF-8,*;q=0.5'
      # 'Accept-Encoding': 'gzip,deflate,sdch'
      'Accept-Language': 'en-US,en;q=0.8'
      'Cache-Control': 'max-age=0'
      'Connection': 'keep-alive'
      'Host': 'html5.grooveshark.com'
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'

    success: (html, headers) ->
      forge.logging.info "html: #{html}"

      scriptTags = html.match /<script[^>]*>[^<]*<\/script>/g
      jsString = scriptTags[2]
      jsString = jsString[31..-12]

      forge.logging.info "jsString: #{jsString}"

      window = {}
      GS = 
        locales: {}

      eval jsString

      lastRandomizer = randomizer()
      session = window.GS.config.sessionID
      secretKey = crypto.createHash('md5').update(session).digest('hex')

      body =
        header:
          client: 'mobileshark'
          clientRevision: '20120830'
          privacy: 0
          country: window.GS.config.country
          uuid: groovesharkRequestUuid
          session: session
        method: 'getCommunicationToken'
        parameters:
          secretKey: secretKey

      forge.logging.info JSON.stringify body

      forge.request.ajax
        type: 'POST'
        url: 'https://html5.grooveshark.com/more.php?getCommunicationToken'
        contentType: 'text/plain;charset=UTF-8'
        headers:
          'Accept': '*/*'
          'Accept-Charset': 'UTF-8,*;q=0.5'
          'Accept-Encoding': 'gzip,deflate,sdch'
          'Accept-Language': 'en-US,en;q=0.8'
          'Cache-Control': 'no-cache'
          'Connection': 'keep-alive'
          'Content-Type': 'text/plain;charset=UTF-8'
          'Host': 'html5.grooveshark.com'
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
        data:
          JSON.stringify body

        success: (body, headers) ->
          forge.logging.info "body: #{body}"

          bodyObject = JSON.parse body

          communicationToken = bodyObject.result
          lastRandomizer = randomizer()
          tokenSource = "getStreamKeyFromSongIDEx:#{communicationToken}:gooeyFlubber:#{lastRandomizer}"
          token = "#{lastRandomizer}#{crypto.createHash('sha1').update(tokenSource).digest('hex')}"
          
          body =
            header:
              client: 'mobileshark'
              clientRevision: '20120830'
              privacy: 0
              country: window.GS.config.country
              uuid: groovesharkRequestUuid
              session: session
              token: token
            method: 'getStreamKeyFromSongIDEx'
            parameters:
              prefetch: false
              mobile: true
              songID: songID
              country: window.GS.config.country

          forge.request.ajax
            type: 'POST'
            url: 'https://html5.grooveshark.com/more.php?getStreamKeyFromSongIDEx'
            contentType: 'text/plain'
            headers:
              'Accept': 'application/json'
              'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3'
              # 'Accept-Encoding': 'gzip,deflate,sdch'
              'Accept-Language': 'en-US,en;q=0.8'
              'Cache-Control': 'no-cache'
              'Connection': 'keep-alive'
              'Host': 'html5.grooveshark.com'
              'Referer': 'http://html5.grooveshark.com'
              'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
            data:
              JSON.stringify body

            success: (body, headers) ->
              forge.logging.info "body: #{body}"

              bodyObject = JSON.parse body
              return callback new Error 'denied.'  if not bodyObject.result?

              host = bodyObject.result.ip
              streamKey = bodyObject.result.streamKey
              callback null, "http://#{host}/stream.php?streamKey=#{streamKey}"

            error: (err) ->
              callback err

        error: (err) ->
          callback err

    error: (err) ->
      callback err



module.exports = Grooveshark
