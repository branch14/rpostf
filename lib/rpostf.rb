require 'logger'

require File.join(File.dirname(__FILE__), %w(string))
require File.join(File.dirname(__FILE__), %w(hash))
require File.join(File.dirname(__FILE__), %w(rpostf params))

# Rpostf -- Ruby POST Finance
# a ruby library for the "Post Finance (SWISS POST)" payment gateway 
#
# usage:
#
#  pf = Rpostf.new(:login => 'asdf', :secret => 'xxxx', :local_host => 'http://bogus.net')
#  url = pf.url_for_get(:orderID => bogus_id,
#                       :amount => suspicious_amount)
#
#  # in rails something like
#  form_tag url
#
#  # or as a link
#  link_to 'Checkout', url, :method => :post
#
# as of EPay Docs +url+ should be used in a form with POST and iso-8859-1
#
class Rpostf

  class MissingParameter < StandardError
    
    def initialize(param, logger=nil)
      @param = param
      @log = logger || Logger.new
    end
    
    def message
      "You have to provide #{@param}."
    end
    
  end
  
  DEFAULT_OPTIONS = {
    #:base_url => 'https://e-payment.postfinance.ch/ncol/test/orderdirect.asp',
    :base_url => 'https://e-payment.postfinance.ch/ncol/test/orderstandard.asp',
    :locale => 'de_DE',
    :currency => 'CHF',
    :local_port => 80,
    :local_protocol => 'https',
    :local_route => '/postfinance_payments'
  }
  
  # mandatory keys for +options+ are
  #  +:login+
  #  +:secret+
  #  +:local_host+
  #
  # optional keys for +options+ are
  #  +:base_url+ default is ''
  #  +:language+ default is 'de_DE'
  #  +:currency+ default is 'CHF'
  #  +:local_port+ default is 80
  #  +:local_protocol+ default is 'https'
  #  +:locale_route+ default is '/postfinance_payments'
  #
  def initialize(options={})
    check_keys options, :login, :secret, :local_host
    @options = options.reverse_merge!(DEFAULT_OPTIONS)
  end

  # returns a string containing a url for a GET
  #
  # hands options over to params_for_post
  def url_for_get(options={})
    options = params_for_post(options)

    parameters = []
    options.each { |p| parameters << p*'=' }

    [@options[:base_url], parameters*'&'].join('?')
  end

  # returns a hash containing the params for a POST
  #
  # mandatory keys for +options+ are
  #  +:orderID+
  #  +:amount+
  #
  # optionsl keys for +options+ are
  #  +:PSPID+
  #  +:currency+
  #  +:language+
  #  +:accepturl+
  #
  def params_for_post(options={})
    check_keys options, :orderID, :amount
    
    options.reverse_merge!({
      :PSPID => @options[:login],
      :currency => @options[:currency],
      :language => @options[:locale],
      :accepturl => [ @options[:local_protocol], '://',
                      @options[:local_host], ':',
                      @options[:local_port],
                      @options[:local_route] ]*''
    })
    options[:SHASign] = Params.new(options).to_digest(@options[:sha1insig])

    options
  end

  # returns a string containing html markup
  # 
  # hands options over to params_for_post
  #
  #  +:submit_value+ is the caption of the submit button
  def form_for_post(options={})
    submit_value = options.delete(:submit_value) || 'Checkout with Post Finance'
    options = params_for_post(options)
    (["<form action=\"#{@options[:base_url]}\" method=\"post\">"] + 
     options.map { |n, v| hidden_field(n, v) } +
     ["<input type=\"submit\" value=\"#{submit_value}\" />", '</form>']) * "\n"
  end

  # verifies a signature
  def signature_valid?(params, sha1sig=nil)
    sha1sig = params.delete('SHASIGN') if sha1sig.nil?
    sha1sig == Params(params).to_digest(@options[:secret]).upcase
  end
  
  # ensures that the passed options hash includes all mandatory keys
  def check_keys(*args)
    options = args.shift
    args.each do |key|
      raise MissingParameter.new(key) unless options.key?(key)
    end
  end

  # build a hidden field html tag
  def hidden_field(name, value)
    "<input type=\"hidden\" name=\"#{name}\" value=\"#{value}\" />"
  end

end

# examples
if $0 == __FILE__

  ### examples ###

  # rpf = Rpostf.new(:login => 'your_login', :secret => 'your_sha1_secret', :local_host => 'your_domain')
  # p params = rpf.params_for_post(:orderID => rand(1_000_000), :amount => 42)
  # puts form = rpf.form_for_post(:orderID => rand(1_000_000), :amount => 43)
  # p url = rpf.url_for_get(:orderID => rand(1_000_000), :amount => 44)

  ### testing ###

  # sample data
  params = Hash[*%w(ACCEPTANCE 1234 amount 15 BRAND VISA CARDNO xxxxxxxxxxxx1111 currency EUR NCERROR 0 orderID 12 PAYID 32100123 PM CreditCard STATUS 9)]
  example_hash = "ACCEPTANCE=1234Mysecretsig1875!?AMOUNT=1500Mysecretsig1875!?BRAND=VISAMysecretsig1875!?CARDNO=xxxxxxxxxxxx1111Mysecretsig1875!?CURRENCY=EURMysecretsig1875!?NCERROR=0Mysecretsig1875!?ORDERID=12Mysecretsig1875!?PAYID=32100123Mysecretsig1875!?PM=CreditCardMysecretsig1875!?STATUS=9Mysecretsig1875!?"
  example_digest = "28B64901DF2528AD100609163BDF73E3EF92F3D4"

  # integrity test
  puts example_hash.sha1 == example_digest ? 'success' : 'failure'

  # testing ruby code
  rpf = Rpostf.new(:login => 'your_login', :secret => 'Mysecretsig1875!?', :local_host => 'your_domain')

  test_hash = rpf.hash_string(params) 
  puts test_hash == example_hash ? 'success: hashes match' : 'failure: hashes differ'

  test_digest = rpf.signature(params)
  puts test_digest == example_digest ? 'success: digests match' : 'failure: digests differ'

  puts rpf.signature_valid?(params, test_digest) ? 'success: verified1' : 'failure'
  puts rpf.signature_valid?(params.merge("SHASIGN" => test_digest)) ? 'success: verified2' : 'failure'

end

