<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="Earthquakes._Default" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <title>Geocoding service</title>
    <style type="text/css">
        html, body, #map-canvas
        {
            height: 100%;
            margin: 0px;
            padding: 0px;
        }
        #panel
        {
            position: absolute;
            top: 5px;
            left: 50%;
            margin-left: -180px;
            z-index: 5;
            background-color: #fff;
            padding: 5px;
            border: 1px solid #999;
        }
        #list
        {
            width: 937px;
        }
        #address
        {
            width: 226px;
        }
    </style>
    <script type="text/jscript" src="https://maps.googleapis.com/maps/api/js?v=3.exp"></script>
    <script type="text/javascript">
        var map;
        var markers = [];

        //initialize initial google maps
        function initialize() {
            var geocoder = new google.maps.Geocoder();
            var latlng = new google.maps.LatLng(0, 0);
            var mapOptions = {
                zoom: 2,
                center: latlng,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            }
            map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
        }

        //search for other location
        function newLocation() {
            resetMarkers();
            setNewLocation();
            setMarkers(false, 200);
            document.getElementById('address').value = "";
        }

        //Top 10 location
        function topTenLocation() {
            initialize();
            resetMarkers();
            setMarkers(true, 10);
            document.getElementById('location').innerHTML = "Top 10 location in world for earthquakes";
        }

        //Top 10 location
        function resetMap() {
            initialize();
            resetMarkers();
            document.getElementById('location').innerHTML = "";
        }

        //change map to center it on location
        function setNewLocation() {
            var geocoder = new google.maps.Geocoder();
            //location searched
            var address = document.getElementById('address').value;

            document.getElementById('location').innerHTML = "Earthquakes near: " + address;

            //search location in google maps
            geocoder.geocode({ 'address': address }, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    //center as center of location
                    map.setCenter(results[0].geometry.location);
                    //adapt zoom level
                    if (results[0].geometry.viewport)
                        map.fitBounds(results[0].geometry.viewport);
                } else {
                    alert('Geocode was not successful for the following reason: ' + status);
                }
            });
        }

        //resetMarkers on google maps
        function resetMarkers() {
            //take them out of map and reset array of markers
            for (var i = 0; i < markers.length; i++) {
                markers[i].setMap(null);
            }
            markers = [];
        }

        //set earthquakes markers
        function setMarkers(initialize, row) {
            //only do it when map changes location
            google.maps.event.addListenerOnce(map, 'bounds_changed', function () {

                var limits = map.getBounds();
                var north = limits.getNorthEast().lat();
                var east = limits.getNorthEast().lng();
                var south = limits.getSouthWest().lat();
                var west = limits.getSouthWest().lng();
                var url;

                var threshold = new Date();
                
                threshold.setFullYear(threshold.getFullYear() - 1);
                if (!initialize) {
                    url = "http://api.geonames.org/earthquakesJSON?north=" + north + "&south=" + south + "&east=" + east + "&west=" + west + "&maxRows=" + row + "&username=chetanbluewolf";
                }
                else {
                    var yyyy = threshold.getFullYear().toString();
                    var mm = (threshold.getMonth() + 1).toString(); // getMonth() is zero-based         
                    var dd = threshold.getDate().toString();
                    // get last year date
                    var lastyear = yyyy + '-' + (mm[1] ? mm : "0" + mm[0]) + '-' + (dd[1] ? dd : "0" + dd[0]);
                    url = "http://api.geonames.org/earthquakesJSON?north=" + north + "&south=" + south + "&east=" + east + "&west=" + west + "&date=" + lastyear + "&maxRows=" + row + "&username=chetanbluewolf";
                }
                
                $.getJSON(url, function (response) {
                    defineMarkers(response);
                });
            });
        }

        //define markers for earthquake response
        function defineMarkers(response) {
            //Array of info about different earthquakes
            var contentString = [];

            for (var i = 0; i < response.earthquakes.length; i++) {
                //infowindow pop up information
                contentString[i] = '<div id="content">' +
              '<h1> Eqid:' + response.earthquakes[i].eqid + '</h1>' +
              '<p> Magnitude: ' + response.earthquakes[i].magnitude + '   Depth: ' + response.earthquakes[i].depth + '</p>' +
              '<p> Latitude: ' + response.earthquakes[i].lat + '   Longitude: ' + response.earthquakes[i].lng + '</p>' +
              '<p> Time: ' + response.earthquakes[i].datetime + '   Source: ' + response.earthquakes[i].src + '</p>' +
              '</div>';

                var infowindow = new google.maps.InfoWindow();

                //locate marker
                var myLatlng = new google.maps.LatLng(response.earthquakes[i].lat, response.earthquakes[i].lng);
                var marker = new google.maps.Marker({
                    position: myLatlng,
                    map: map,
                    title: 'Earthquake'
                });

                //Add listener for infowindow pops up
                google.maps.event.addListener(marker, 'click', (function (marker, i) {
                    return function () {
                        infowindow.setContent(contentString[i]);
                        infowindow.open(map, marker);
                    }
                })(marker, i));

                //add marker to array of markers.
                markers.push(marker);
            }
        }
        google.maps.event.addDomListener(window, 'load', initialize);
    </script>
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <table width="100%">
        <tr>
            <td width="25%">
                <asp:Label ID="lblAddress" runat="server" Text="Enter address:"></asp:Label>
            </td>
            <td width="25%">
                <input id="address" type="textbox" value="" />
            </td>
            <td width="25%">
                <input type="button" value="Geocode" onclick="newLocation()" />
                <input type="button" value="Reset" onclick="resetMap()" />
                <input type="button" value="Top 10" onclick="topTenLocation()" />
            </td>
            <td width="25%">
                 <span id="location"></span>
            </td>
        </tr>
    </table>
    <div id="list">
    </div>
    <div id="map-canvas" style="width: 938px; height: 450px; border-style: solid; border-width: 1px;">
    </div>
</asp:Content>
