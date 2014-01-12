# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

tokenizeBank = ->
    $form = $('#bank-form')
    bankAccountData = {
        name: $form.find('#ba-name').val(),
        account_number: $form.find('#ba-an').val(),
        routing_number: $form.find('#ba-rn').val()
    }

    console.log bankAccountData

    balanced.bankAccount.create bankAccountData, callbackHandler

callbackHandler = (response) ->
    console.log response
    $form = $('#bank-form')
    $form.find('.form-control').removeClass('has-error')
    switch response.status
        when 201
            bank_account_uri = response.data['credits_uri']
            $('<input>').attr({
                type: 'hidden',
                value: bank_account_uri,
                name: 'user[bank_account_uri]'
            }).appendTo($form)
            $form.submit();
        when 400
            # missing field - check response.error for details
            $form.find('#ba-name').attr('placeholder', response.error.name).parent().addClass('has-error') if response.error.name
            $form.find('#ba-an').attr('placeholder', response.error.account_number).parent().addClass('has-error') if response.error.account_number
            $form.find('#ba-rn').attr('placeholder', response.error.routing_number).parent().addClass('has-error') if response.error.routing_number
        when 402
            # we couldn't authorize the buyer's credit card
            $form = $('#bank-form')
            $('<div>').
                prependTo($form).
                addClass('alert alert-error').
                text(JSON.stringify(response.error))
        when 404
            # your marketplace URI is incorrect
            console.log(response.error)
        when 500
            # balanced did something bad, please retry the request
            console.log(response.error)

$(document).ready ->
    $('#bank-submit').click ->
        tokenizeBank()