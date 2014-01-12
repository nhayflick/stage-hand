// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require bootstrap-datepicker
//= require_tree .

// var marketplaceUri = '<%= "#{ENV['BALANCED_MARKETPLACE_URI']}" %>'
balanced.init('/v1/marketplaces/TEST-MP2FOG8MNXsCxbD7ewtUnk5y');

// var csrf = '<%= "#{ENV['BALANCED_CSRF']}" %>'
// var marketplaceUri = '<%= "#{ENV['BALANCED_MARKETPLACE_URI']}" %>'
// //  kick everything off when jquery is ready
// $(function () {
//     rentmybike.init({
//         csrfToken:csrf,
//         marketplaceUri:marketplaceUri
//     });
// });
