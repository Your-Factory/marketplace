$(document).ready(function() {

  $('.color-choose input').on('click', function() {
      var headphonesColor = $(this).attr('data-image');

      $('.active').removeClass('active');
      $('.left-column img[data-image = ' + headphonesColor + ']').addClass('active');
      $(this).addClass('active');
  });

});

amount = document.getElementById('AmountOfModelsToBuy');
amount.addEventListener('change', multiplyAmountAndPrice);
function multiplyAmountAndPrice() {
    var price = document.getElementById('Price').value;
    var amount = document.getElementById('AmountOfModelsToBuy').value;
    alert(amount);
    document.getElementById('FinalPrice').value = price * amount;
}
