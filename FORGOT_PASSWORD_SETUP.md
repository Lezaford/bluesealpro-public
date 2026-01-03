# Forgot Password System Setup

## What's Been Configured

Your forgot password system is now fully functional! Here's how it works:

### User Flow

1. **User visits login page** → Click "Forgot?" link
2. **User enters email** → Click "Send Reset Link"
3. **Email is sent** with password reset instructions
4. **User clicks link in email** → Password reset form loads
5. **User enters new password** → Updated immediately

### Key Files Modified

- **`config/initializers/devise.rb`** - Updated mailer sender to `noreply@example.com`
- **`app/views/devise/passwords/new.html.erb`** - Styled forgot password form (matches your app design)
- **`app/views/devise/passwords/edit.html.erb`** - Styled password reset form
- **`app/views/devise/mailer/reset_password_instructions.html.erb`** - Styled email template
- **`app/views/devise/mailer/reset_password_instructions.text.erb`** - Text version of email

### Email Configuration (Development)

Currently configured for **development only** using MailHog on `localhost:1025`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "localhost",
  port: 1025
}
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
```

To test locally:
1. Start MailHog: `mailhog` (or `brew services start mailhog` on Mac)
2. Access MailHog UI at: `http://localhost:1025`
3. Emails will appear in MailHog inbox automatically

### For Production

Update `config/environments/production.rb` with your email service (Gmail, SendGrid, etc.):

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "smtp.gmail.com",  # or your email service
  port: 587,
  user_name: ENV['EMAIL_USERNAME'],
  password: ENV['EMAIL_PASSWORD'],
  authentication: "plain",
  enable_starttls_auto: true
}
config.action_mailer.default_url_options = { host: "yourdomain.com" }
```

## How to Test

1. Go to login page: `http://localhost:3000/users/sign_in`
2. Click "Forgot?" link
3. Enter a test email (e.g., `admin@example.com`)
4. Check MailHog at `http://localhost:1025`
5. Click the reset link in the email
6. Set new password
7. Login with new password

## Security Features

- Tokens expire after token_expiration_time (default: 6 hours)
- One-time use tokens (can't reuse same reset link)
- Email verification ensures user owns the email
- Password must meet minimum length requirements
