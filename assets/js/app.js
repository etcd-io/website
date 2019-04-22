function anchors() {
  anchors.options = {
    icon: '#'
  }

  anchors.add('.docs-content h2, .docs-content h3');
};

function dropdown() {
  $('.dropdown').click(function() {
    $(this).toggleClass('is-active');
  });
}

function navbarBurgerToggle() {
  $('.navbar-burger').click(function() {
    $('.navbar-burger').toggleClass('is-active');
    $('.navbar-menu').toggleClass('is-active');
  });
}

$(function() {
  console.log("Welcome to the etcd website and documentation!");

  //anchors();
  dropdown();
  navbarBurgerToggle();
});
