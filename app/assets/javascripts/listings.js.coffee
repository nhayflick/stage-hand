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
	$('#price-span').text(diff * price)

window.scenius.tokenizeCard = ->
	$form = $('#credit-card-form')
	creditCardData =
	    card_number: $form.find('#cc-number').val(),
	    expiration_month: $form.find('#cc-em').val(),
	    expiration_year: $form.find('#cc-ey').val(),
	    security_code: $form.find('#cc-csc').val()
	balanced.card.create(creditCardData, callbackHandler)

callbackHandler = (response) ->
	switch response.status
		when 201
			console.log response.data
			$form = $("#credit-card-form")
			cardTokenURI = response.data['uri']
			$('<input>').attr({
				type: 'hidden',
				value: cardTokenURI,
				name: 'booking[credit_uri]'
			}).appendTo($('#new_booking'))
		when 400
        	console.log(response.error)
        	$('<div>').
        		prependTo($('#credit-card-form')).
        		addClass('alert alert-error').
        		text(JSON.stringify(response.error))
    	when 402
        	console.log(response.error)
        	$('<div>').
        		prependTo($('#credit-card-form')).
        		addClass('alert alert-error').
        		text(JSON.stringify(response.error))
       	when 404
        	console.log(response.error)
    	when 500
    		console.log(response.error)