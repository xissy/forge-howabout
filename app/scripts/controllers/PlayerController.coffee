
howaboutApp.controller 'PlayerController', [
  '$scope'
  '$route'
  '$http'
  'PlayInfoSharedService'
  'PlaylistSharedService'
  ($scope, $route, $http, playInfoSharedService, playlistSharedService) ->
    audioPlayer = null
    playState = 'stopped'

    $scope.$on 'onBroadcastPlayInfo', ->
      if audioPlayer?
        audioPlayer.stop()
        audioPlayer.destroy()
        audioPlayer = null

      forge.file.cacheURL playInfoSharedService.streamUrl
      ,
        (file) ->
          forge.media.createAudioPlayer file
          ,
            (player) ->
              audioPlayer = player

              player.play ->
                playState = 'playing'
                setPlayButtonIcon getPlayState()
              ,
                ->
                  playState = 'stopped'
                  setPlayButtonIcon getPlayState()

              player.positionChanged.addListener (e) ->
                player.duration (duration) ->
                  durationSecs = duration
                  durationSec = parseInt durationSecs % 60
                  durationSec = "0#{durationSec}"  if durationSec < 10

                  positionSecs = if e.time? then e.time else e
                  positionSec = parseInt positionSecs % 60
                  positionSec = "0#{positionSec}"  if positionSec < 10

                  progressPercent = parseInt positionSecs * 100 / durationSecs

                  $scope.$apply ->
                    $scope.durationTimeString = "#{parseInt durationSecs / 60}:#{durationSec}"
                    $scope.positionTimeString = "#{parseInt positionSecs / 60}:#{positionSec}"
                    $scope.progressPercentStyle =
                      width: "#{progressPercent}%"

                  if positionSecs >= durationSecs - 1
                    setPlayButtonIcon getPlayState()
                    $scope.$apply ->
                      $scope.durationTimeString = '0:00'
                      $scope.positionTimeString = '0:00'
                      $scope.progressPercentStyle =
                        width: '0%'

                    playState = 'stopped'
                    setPlayButtonIcon getPlayState()
                    
                    playlistSharedService.playNext()
      ,
        (content) ->
          playState = 'stopped'
          setPlayButtonIcon getPlayState()


    $scope.$on 'onBroadcastStartLoadingSong', ->
      audioPlayer.pause()  if audioPlayer?

      showLoadingIcon()
      $scope.durationTimeString = '0:00'
      $scope.positionTimeString = '0:00'
      $scope.progressPercentStyle =
        width: '0%'


    $scope.$on 'onBroadcastNoSteamingUrl', ->
      playState = 'stopped'
      setPlayButtonIcon getPlayState()

      # playlistSharedService.playNext()


    showPlayButton = ->
      $('#playButtonIcon').removeClass('fa-stop fa-pause fa-spinner fa-spin').addClass('fa-play')
      $('#player-progress').removeClass('active')

    showPauseButton = ->
      $('#playButtonIcon').removeClass('fa-stop fa-play fa-spinner fa-spin').addClass('fa-pause')
      $('#player-progress').addClass('active')

    showStopButton = ->
      $('#playButtonIcon').removeClass('fa-play fa-pause fa-spinner fa-spin').addClass('fa-stop')
      $('#player-progress').addClass('active')

    showLoadingIcon = ->
      $('#playButtonIcon').removeClass('fa-play fa-pause fa-stop').addClass('fa-spinner fa-spin')
      $('#player-progress').removeClass('active')


    getPlayState = ->
      playState

    setPlayButtonIcon = (playState) ->
      switch playState
        when 'playing'
          showPauseButton()
        when 'paused'
          showPlayButton()
        when 'stopped'
          showPlayButton()
        

    $scope.onClickPlay = ->
      switch getPlayState()
        when 'playing'
          audioPlayer.pause()  if audioPlayer?
          playState = 'paused'
          setPlayButtonIcon getPlayState()
        when 'paused'
          audioPlayer.play()  if audioPlayer?
          playState = 'playing'
          setPlayButtonIcon getPlayState()
        else
          playlistSharedService.playNext()

    $scope.onClickPrev = ->
      playlistSharedService.playPrev()

    $scope.onClickNext = ->
      playlistSharedService.playNext()

]
