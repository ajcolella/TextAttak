
$( document ).ready(function() {
  $.post( "https://api.textattak.com/attak",
  { 
    id: Shopify.checkout.order_id,
    sku: Shopify.checkout.sku
  },
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
