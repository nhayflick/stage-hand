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
            $("#new_booking").submit()
        when 400
            console.log(response.error)
            $('<div>').
                prependTo($('#credit-card-form')).
                addClass('alert alert-danger').
                text(JSON.stringify(response.error))
        when 402
            console.log(response.error)
            $('<div>').
                prependTo($('#credit-card-form')).
                addClass('alert alert-danger').
                text(JSON.stringify(response.error))
        when 404
            console.log(response.error)
        when 500
            console.log(response.error)

$(document).ready ->
  $("#new_booking").on("ajax:success", (e, data, status, xhr) ->
    $('.alert').remove();
    $('#booking-step-1').show();
    $('#booking-step-2').hide();
    $("#new_booking").find('input').attr('disabled', 'disabled')
    $("#new_booking").find('input[type="submit"]').remove()
    $("#new_booking").parent().find('h4').text('Request Sent!').append('<h6>Thank you for your booking request! We will be in touch once the owner replies.</h6>')
  ).bind "ajax:error", (e, xhr, status, error) ->
    if xhr.responseJSON.base
        content = '<div class="alert alert-danger">' + xhr.responseJSON.base + '</div>'
        if $('#new_booking').parent().find('.alert').length == 0 then $('#new_booking').parent().prepend(content) else $('#new_booking').parent().find('.alert').html(xhr.responseJSON.base)
    else if xhr.responseJSON.credit_uri && !xhr.responseJSON.base
        $('#booking-step-1').hide();
        $('#booking-step-2').show();

  $('.input-daterange').datepicker({format: "mm/dd/yyyy"});

  $('#booking_start_date, #booking_end_date').change ->
    window.scenius.calculatePrice()
  $('#cc-submit').click ->
    window.scenius.tokenizeCard()