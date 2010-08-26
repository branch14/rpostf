# Rpostf

Generate PostFinance (Swiss Post) URLs and vaildate responses.

## Example

    pf = Rpostf.new(:login => 'your_login', :secret => 'your_secret', :local_host => 'your_domain')
    p params = pf.params_for_post(:orderID => rand(1_000_000), :amount => 42)
    p form = pf.form_for_post(:orderID => rand(1_000_000), :amount => 43)
    p url = pf.url_for_get(:orderID => rand(1_000_000), :amount => 44)

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
