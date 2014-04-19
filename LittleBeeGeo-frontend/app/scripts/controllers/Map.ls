'use strict'

{map, fold, fold1, mean, join} = require 'prelude-ls'

LEGENDS = <[ ]>

# LEGEND_STRING = 

# LEGEND_COLOR =
  

angular.module 'LittleBeeGeoFrontend'
  .controller 'MapCtrl',  <[ $scope geoAccelGyro jsonData ]> ++ ($scope, geoAccelGyro, jsonData) ->
    geo = geoAccelGyro.getGeo!

    $scope.mapOptions = 
      center: new google.maps.LatLng geo.lat, geo.lon
      zoom: 14
      mapTypeId: google.maps.MapTypeId.ROADMAP

    is_first_map_center = true
    $scope.$on 'geoAccelGyro:event', (e, data) ->

      if data.event != 'devicegeo'
          return

      if not is_first_map_center
          return

      console.log 'to set is_first_map_center as false'
      is_first_map_center := false

      $scope.myMap.setCenter (new google.maps.LatLng data.lat, data.lon)

    $scope.$watch (-> jsonData.getDataTimestamp!), ->
      the_data = jsonData.getData!

      console.log 'Map: the_data:', the_data

      data = [val for key, val of the_data]
      markers = _parse_markers data

      console.log 'markers:', markers

      $scope.markers = markers

    $scope.onMapIdle = ->

    $scope.onMapClick = (event, params) ->
      console.log 'onMapClick: event:', event, 'params:', params

    $scope.onMapZoomChanged = (zoom) ->
      console.log 'onMapZoomChanged: zoom:', zoom

    _set_markers_to_googlemap = (markers) ->
      markers |> map (marker) -> marker.setMap $scope.myMap

    _parse_markers = (the_data_values) ->
      console.log '_parse_markers: the_data_values:', the_data_values
      results = [_parse_marker each_value for each_value in the_data_values]
      results = [val for val in results when val is not void]
      results |> fold1 (++)

    _parse_marker = (value) ->
      #console.log '_parse_marker: value', value
      geo = value.geo
      if geo is void
        return void

      color = _parse_marker_color(value)

      console.log '_parse_marker: geo:', geo

      markers = [_parse_each_marker each_geo, color, value for each_geo in geo]

      console.log 'after _parse_each_marker: markers:', markers

      [_add_map_listener each_marker for each_marker in markers]

      markers

    _parse_marker_color = (value) ->
      \#840

    #_parse_each_marker
    _parse_each_marker = (geo, color, value) ->
      the_type = geo.type
      the_coordinates = geo.coordinates

      console.log '_parse_each_marker: geo:', geo, 'the_type:', the_type, 'the_coordinates', the_coordinates
      switch the_type
      | 'Polygon'    => _parse_polygon the_coordinates, color, value
      | 'LineString' => _parse_line_string the_coordinates, color, value
      | 'Point'      => _parse_point the_coordinates, color, value

    _parse_polygon = (coordinates, color, value) ->
      polygon_opts = 
        map: $scope.myMap,
        paths: [_parse_path coord for coord in coordinates]
        fillColor: color
        strokeColor: color

      polygon = new google.maps.Polygon polygon_opts
      polygon._value = value
      polygon

    _parse_line_string = (coordinates, color, value) ->
      polyline_opts = 
        map: $scope.myMap
        path: _parse_path coordinates
        fillColor: color
        strokeColor: color

      polyline = new google.maps.Polyline polyline_opts
      polyline._value = value
      console.log '_parse_line_string: polyline_opts:', polyline_opts, 'polyline:', polyline
      polyline

    _parse_point = (coordinates, color, value) ->
      marker_opts = 
        map: $scope.myMap
        position: new google.maps.LatLng coordinates[1], coordinates[0]
        fillColor: color
        strokeColor: color

      marker = new google.maps.Marker marker_opts
      marker._value = value
      marker

    _parse_path = (coordinates) ->
      console.log '_parse_path: coordinates', coordinates
      [new google.maps.LatLng coord[1], coord[0] for coord in coordinates]

    #_add_map_listener
    info_window = new google.maps.InfoWindow do
      content: 'Hello World'

    _add_map_listener = (marker) ->
      console.log '_add_map_listener: start: marker:', marker

      google.maps.event.addListener marker, 'click', (event) ->

        console.log 'map_listener: marker:', marker

        if event is not void
          info_window.setPosition event.latLng
          info_window.open $scope.myMap
          info_window.setContent _parse_content marker._value

    _parse_content = (value) ->
      the_address = value.address
      if value.start_number is not void
        the_address += ' ' + value.start_number + ' 號'
      if value.end_number is not void
        the_address += ' ~ ' + value.end_number + ' 號'
      result = '<div>' + \
        '<p>' + _parse_content_join_str([value.county, value.town]) + '</p>' + \
        '<p>' + the_address + '</p>' + \
        '<p>' + value.deliver_time + '</p>'

      #if value.deliver_status:
      #  result += '<p>' + value.deliver_status + '</p>'

      result += '</div>'

      result

    _parse_content_join_str = (the_list) ->
      the_list = [column for column in the_list when column]
      return join ' / ' the_list
