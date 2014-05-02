const registration_map = 'node_map' //id of map-div of a registration form
const node_lat_field = '#node_registration_latitude'
const node_lng_field = '#node_registration_longitude'
const autoComplField = '#node_registration_osm_loc'
var reg_map = 'no init yet' //Map-Singleton for node-registration

//Icon via asset pipeline
var assetIcon = L.icon({
    iconUrl: '<%= asset_path "marker-icon.png" %>',
    shadowUrl: '<%= asset_path "marker-shadow.png" %>',
    iconAnchor: [12, 40],
    shadowAnchor: [12, 40],
    popupAnchor: [0,-37]
})

function init_reg_map(){
	var lat = $(node_lat_field).val()
	var lng = $(node_lng_field).val()
	var zoom = 13
	// Marker is dragable, if note-position is writable
	var r_o = $( autoComplField ).attr('readonly') == "readonly"

	map = L.map(registration_map)
	if(lat == '' || lng == ''){
		// If no position is set - set center koeln <-> bonn
		lat = 50.82990
		lng = 6.988334655761719
		zoom = 9
	}else{
		// OSM-Div
		map.nodeMarker = L.marker([lat,lng],{
			icon: assetIcon,
			draggable: !r_o,
		}).addTo(map);
		map.nodeMarker.on("dragend",updateLatitudeLongitude)
		
	}
	map.setView([lat, lng], zoom);
	
	var osmUrl = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
	L.tileLayer(osmUrl, {
	    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
	}).addTo(map);
	
	this.reg_map = map
	//Auto-Completer
}
/**
Intialize auto-complete field of registration form
*/
function init_auto_complete(ajaxSpinner){
	var field = $(autoComplField)
	field.autocomplete({
			minLength: 5,
			delay: 750,
			source: '/lookup.json',
			select: function(event, ui) {
				handle_select(field,ui.item); 
			},
			search: function(event, ui) { 
				$( ajaxSpinner ).show();
			},
			open: function(event, ui) { 
				$( ajaxSpinner ).hide();
			}
		});
}
function init_lat_lng_change(){
	$(node_lat_field).change(function(){ handle_lat_lng_change(); });
	$(node_lng_field).change(function(){ handle_lat_lng_change(); });
}
/**
Callback for selecting a record within the autocomplete list
*/
function handle_select(field,selected_element){
	var map = this.reg_map
	var lat = selected_element.data.lat
	var lng = selected_element.data.long
	move_marker(lat, lng);
	updateLatitudeLongitude();
}
function handle_lat_lng_change(){
	lat = $( node_lat_field ).val();
	lng = $( node_lng_field ).val();
	if(lat=="" || lng == ""){
		return;  # FIXME - remove Marker
	}
	move_marker(lat, lng);
}
function move_marker(lat, lng){
	if(!map.nodeMarker){
		map.nodeMarker = L.marker([lat, lng], {
			icon: assetIcon,
			draggable: true,
		}).addTo(map);
	}

	if(!map.nodePopup){
		map.nodePopup = map.nodeMarker.bindPopup("<b> Bitte bewege mich!</b><br />Ziehe den Marker zum Aufstellort.");
	}
	map.nodeMarker.on("dragend", updateLatitudeLongitude);
	map.nodeMarker.setLatLng([lat, lng]);
	map.setView([lat, lng], 13, true);
	map.nodePopup.openPopup();
}
function updateLatitudeLongitude(){
	var latlng = reg_map.nodeMarker.getLatLng()
	$(node_lat_field).val(latlng.lat);
	$(node_lng_field).val(latlng.lng);
}
