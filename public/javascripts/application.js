function forgot_password() {
  $('user_submit_login').disable();
  new Effect.BlindUp('password', { duration: 0.15 });
  setTimeout(function() {
    new Effect.BlindDown('forgot-password', { duration: 0.15 });
    new Effect.BlindDown('password-notice', { duration: 0.15 });
  }, 350);
}

function remember_password() {
  $('user_submit_login').enable();
  new Effect.BlindUp('forgot-password', { duration: 0.15 });
  new Effect.BlindUp('password-notice', { duration: 0.15 });
  setTimeout(function() {
    new Effect.BlindDown('password', { duration: 0.15 });
  }, 350);
}

function setup_search_prompt() {
  var search_field  = $('query');
  var default_value = "Enter an ISBN, book title, or author's name...";
  
  if (search_field.value == "" || search_field.value == default_value) {
    search_field.value = default_value;
    search_field.style.color = "#666666";
  }
}

function toggle_search_prompt() {
  var search_field = $('query');
  var default_value = "Enter an ISBN, book title, or author's name...";
  
  if (search_field.value == "") {
    search_field.value = default_value;
    search_field.style.color = "#666666";
  } else if (search_field.value == default_value) {
    search_field.value = "";
    search_field.style.color = "#000000";
  }
}