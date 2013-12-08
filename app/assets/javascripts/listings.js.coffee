# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.scenius = {}

window.scenius.calculatePrice = ->
	start = new Date $('#booking_start_date').val()
	end = new Date $('#booking_end_date').val()
	price = $('#live-price').data('price')
	diff = (end - start) / 86400000
	diff = if diff > 0 then diff else 1
	console.log diff
	$('#price-span').text(diff * price)