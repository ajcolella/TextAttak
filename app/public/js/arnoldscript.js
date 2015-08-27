
$( document ).ready(function() {
  $.post( "https://api.textattak.com/attak",
  { 
    id: Shopify.checkout.order_id,
    sku: Shopify.checkout.sku
  });
});
