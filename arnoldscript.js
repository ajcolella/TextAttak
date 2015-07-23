
$( document ).ready(function() {
  $.post( "http://api.textattak.com/arnold",
  { id: Shopify.checkout.order_id },
  function( data ) {
    alert(Shopify.checkout.order_id);
  })  
  .done(function() {
    alert( "second success" );
  })
  .fail(function() {
    alert( "error" );
  });
});
