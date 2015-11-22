// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(document).on('page:load', function() {
  series_info_toggle();
})

$(document).ready(function() {
  series_info_toggle();
})

var series_info_toggle = function(){
	$('#crumb_1').on("click", function(){
		if ($('#bread_1').hasClass("hide") == true) {
			$('#bread_1').toggleClass("hide")
		}
		if ($('#bread_2').hasClass("hide") == false) {
			$('#bread_2').toggleClass("hide")
		}
		if ($('#bread_3').hasClass("hide") == false) {
			$('#bread_3').toggleClass("hide")
		}
	})

	$('#crumb_2').on("click", function(){
		if ($('#bread_1').hasClass("hide") == false) {
			$('#bread_1').toggleClass("hide")
		}
		if ($('#bread_2').hasClass("hide") == true) {
			$('#bread_2').toggleClass("hide")
		}
		if ($('#bread_3').hasClass("hide") == false) {
			$('#bread_3').toggleClass("hide")
		}
	})

	$('#crumb_3').on("click", function(){
		if ($('#bread_1').hasClass("hide") == false) {
			$('#bread_1').toggleClass("hide")
		}
		if ($('#bread_2').hasClass("hide") == false) {
			$('#bread_2').toggleClass("hide")
		}
		if ($('#bread_3').hasClass("hide") == true) {
			$('#bread_3').toggleClass("hide")
		}
	})
}