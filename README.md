# nab_com_au

## Description

Log into NAB Internet Banking (ib.nab.com.au) and pay a bill by BPAY from an account, via Selenium WebDriver and WebAccount.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'nab_com_au'
```
And then execute:
```shell
$ bundle
```
Or install it yourself as:
```shell
$ gem install nab_com_au
```

## Usage

### Paying a bill by BPAY
```ruby
  require 'nab_com_au'

  nab_account = NabComAu::Account.new(username: nab_id, password: password)
  nab_account.login
  nab_account.bpay(
    source_bank_account_name_or_number: 'Everyday Account',
    biller_name_or_code: '1234',
    customer_reference_number: '5678',
    amount: '1.00'
  )
  nab_account.shutdown # Logs out, and quits the browser.
```
The payment is made: `bpay` goes through NAB's confirmation page, entering the password there, and submits it.

The account paid from is picked from the list by its name, or by its number, given as `'123456789'` or `'12-345-6789'`.

A biller given as digits is entered as a biller code. Since NAB matches a code as a substring, where it matches more than one biller the one whose code it is is chosen from the results. A biller given by name is chosen from the list of billers already paid, or else searched for by name.

### Credentials

The username is the NAB ID. It and the password are given, or set afterwards:
```ruby
  nab_account = NabComAu::Account.new(username: nab_id, password: password)
  nab_account.username, nab_account.password = nab_id, password
```
Where either is missing, `login` raises ArgumentError before starting the browser, naming every one missing. `bpay` does the same for the payment's details and the password.

NAB then sends a code by SMS, which is entered in the browser: `login` waits up to three minutes for it, and for the accounts to appear, so the browser can't be headless.

### The browser

The browser is WebAccount's: Chrome, unless `browser: :firefox` is given. Given a `profile_directory`, it's started with that profile, kept between runs; without one, each run has a new, temporary profile.
```ruby
  NabComAu::Account.new(profile_directory: '~/path/to/profile')
  NabComAu::Account.new(browser: :firefox, profile_directory: '~/path/to/firefox-profile')
```
`headless:`, `window_size:` and `user_agent:` are passed to WebAccount too.

## Limitations

Transfers aren't made yet: `transfer` raises NotImplementedError.

The selectors were taken from the live site, and a change to it will break them. Each key of `NabComAu::Account::PAGE_SELECTORS` is also a keyword of `new`, and has a setter, either of which wins over NAB's, so as a selector which has changed can be given without waiting for a new version:
```ruby
  NabComAu::Account.new(login_page_submit_button_selector: {id: 'loginButton'})
  nab_account.logged_out_selector = {xpath: "//*[contains(text(), 'logged out')]"}
```

The tests cover only what doesn't depend on NAB's site, and never submit a payment.

## Contributing

1. Fork it: https://github.com/thoran/nab_com_au/fork
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new pull request
