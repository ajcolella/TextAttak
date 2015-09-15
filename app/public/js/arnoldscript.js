$(document).ready(function() {
  $('.section--payment-information-recap')[0].style.display = 'none';
  $.post( "https://api.textattak.com/attak",
  { 
    id: Shopify.checkout.order_id,
    sku: Shopify.checkout.sku
  });
});
