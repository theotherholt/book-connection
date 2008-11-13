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