# Rpostf

Rpostf is a Ruby library to the e-Payment API (v4.4) provided by PostFinance (Swiss Post).

Generate Params/URLs/Forms and validate their responses.

The approach this library is used for works much like 'Google Checkout' or 'Paypal Express'.

More Documentation

 * https://e-payment.postfinance.ch/

This library has been written in context of building webshops on top of
[Spree](http://spreecommerce.com) at [Panter LLC](http://panter.ch), Zurich.

## Install

    gem install rpostf

## Example

    pf = Rpostf.new(:login => 'your_login',
                    :sha1outsig => 'somepasswith16digit',
                    :sha1insig => 'someotherpasswith16digits')

    p params = pf.params_for_post(:orderID => rand(1_000_000), :amount => 42)
    p form = pf.form_for_post(:orderID => rand(1_000_000), :amount => 43)
    p url = pf.url_for_get(:orderID => rand(1_000_000), :amount => 44)

## Rpostf & Rails

This is just a suggestion.

config/rpostf.yml
    development:
      login: yourpspidTEST
      sha1insig: someotherpasswith16digits
      sha1outsig: somepasswith16digits
      currency : CHF
      base_url: https://e-payment.postfinance.ch/ncol/test/orderstandard.asp
      accepturl: http://your-dev-deployment/route-to-accept-postfinance-requests
    
    production:
      login: youpspid
      sha1insig: someotherpasswith16digits
      sha1outsig: somepasswith16digits
      currency : CHF
      base_url: https://e-payment.postfinance.ch/ncol/prod/orderstandard.asp
      accepturl: http://your-production-deployment/route-to-accept-postfinance-requests

config/initializers/rpostf.rb
    config_filename = File.join(RAILS_ROOT, %w(config rpostf.yml))
    config = File.open(config_filename) { |f| YAML::load(f) }
    RPOSTF = Rpostf.new(config[RAILS_ENV])

And in the view you might want to add something like...

vender/extensions/your_theme/app/views/checkouts/_payment.html.haml
    -ps = { 'orderID' => @order.number,           |
            'amount' => (@order.total*100).to_i } |
    -url = RPOSTF.url_for_get(ps)
    =link_to t(:checkout_with_postfinance), url, :method => :post

## Note on Patches/Pull Requests
 
 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests for it. This is important so I don't break it in a
   future version unintentionally.
 * Commit, do not mess with rakefile, version, or history. (if you
   want to have your own version, that is fine but bump version in a
   commit by itself I can ignor e when I pull)
 * Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Phil Hofmann <pho at panter dot ch>. See LICENSE for details.
