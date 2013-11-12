
howaboutApp.controller 'PlayerController', [
  '$scope'
  '$route'
  '$http'
  'PlayInfoSharedService'
  'PlaylistSharedService'
  ($scope, $route, $http, playInfoSharedService, playlistSharedService) ->
    
    forge.playback_without_action.disable()    

    playState = 'stopped'
    isLoading = false

    audioElement = document.createElement 'audio'

    audioElement.addEventListener 'error', ->
      audioElement.pause()
      setPlayButtonIcon getPlayState()
    
    audioElement.addEventListener 'play', ->
      isLoading = false
      playState = 'playing'
      setPlayButtonIcon getPlayState()
    
    audioElement.addEventListener 'pause', ->
      if isLoading is true
        showLoadingIcon()
        $scope.$apply ->
          $scope.durationTimeString = '0:00'
          $scope.positionTimeString = '0:00'
          $scope.progressPercentStyle =
            width: '0%'
      else
        playState = 'paused'
        setPlayButtonIcon getPlayState()
    
    audioElement.addEventListener 'timeupdate', ->
      return  if isLoading is true
      
      durationSecs = audioElement.duration
      positionSecs = audioElement.currentTime
      durationSec = parseInt durationSecs % 60
      positionSec = parseInt positionSecs % 60
      durationSec = "0#{durationSec}"  if durationSec < 10
      positionSec = "0#{positionSec}"  if positionSec < 10
      progressPercent = parseInt positionSecs * 100 / durationSecs

      $scope.$apply ->
        if "#{parseInt durationSecs / 60}:#{durationSec}" isnt 'NaN:NaN'
          $scope.durationTimeString = "#{parseInt durationSecs / 60}:#{durationSec}"
        $scope.positionTimeString = "#{parseInt positionSecs / 60}:#{positionSec}"
        $scope.progressPercentStyle =
          width: "#{progressPercent}%"

    audioElement.addEventListener 'ended', ->
      $scope.$apply ->
        $scope.durationTimeString = '0:00'
        $scope.positionTimeString = '0:00'
        $scope.progressPercentStyle =
          width: '0%'
      playState = 'stopped'
      setPlayButtonIcon getPlayState()
      playlistSharedService.playNext()


    $scope.$on 'onBroadcastPlayInfo', ->
      audioElement.setAttribute 'src', playInfoSharedService.streamUrl
      audioElement.load()
      audioElement.play()

      forge.file.cacheURL playInfoSharedService.streamUrl
      ,
        (file) ->
          forge.media.createAudioPlayer file
          ,
            (player) ->
              player.play ->
                player.stop()
              ,
                ->


    $scope.$on 'onBroadcastStartLoadingSong', ->
      isLoading = true
      showLoadingIcon()
      $scope.$apply ->
        $scope.durationTimeString = '0:00'
        $scope.positionTimeString = '0:00'
        $scope.progressPercentStyle =
          width: '0%'
      audioElement.pause()


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
          audioElement.pause()
          playState = 'paused'
          setPlayButtonIcon getPlayState()
        when 'paused'
          audioElement.play()
          playState = 'playing'
          setPlayButtonIcon getPlayState()
        else
          playlistSharedService.playNext()

    $scope.onClickPrev = ->
      playlistSharedService.playPrev()

    $scope.onClickNext = ->
      playlistSharedService.playNext()

]
