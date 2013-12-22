jQuery ->	
	$('.dropdown').on 'show.bs.dropdown hide.bs.dropdown', (e) ->
	  $.get(
	    '/notifications',
	    (response) ->
	    	$('#notifications-dropdown').html(response)
	  );

	$('.dropdown').on 'hide.bs.dropdown', ->
	  $.get(
	    '/notifications/render_bell',
	    (response) ->
	    	$('#notifications').html(response)
	  );
	return false;

	