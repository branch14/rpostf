require 'logger'

require File.join(File.dirname(__FILE__), %w(string))
require File.join(File.dirname(__FILE__), %w(nil_class))
require File.join(File.dirname(__FILE__), %w(hash))
require File.join(File.dirname(__FILE__), %w(array))
require File.join(File.dirname(__FILE__), %w(rpostf params))

# Rpostf -- Ruby POST Finance
# a ruby library for the "Post Finance (SWISS POST)" payment gateway 
#
# usage:
#
#  pf = Rpostf.new(:login => 'asdf', :local_protocol => 'http',
#                                    :local_host     => 'shop.example.com',
#                                    :local_port     => '80',
#                                    :local_route    => '/shopping',
#                                    :sha1outsig     => 'ssBbun8fiZ0oksjh',
#                                    :sha1insig      => 'Qh4lihxMpglu9Hxl' )
#
#       # The :local_* parameters are used to compose the 'accepturl' (in
#       # Postfinance speak), which is the jump back address from Postfinance
#       # back to the shop.
#
#       # Alternatively they can also be set via the :accepturl parameter to the
#       # 'url_for_get' method below
#
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
      @log = logger || Logger.new(STDOUT)
    end
    
    def message
      "You have to provide #{@param}."
    end
    
  end
  
  attr_accessor :config

  DEFAULT_OPTIONS = {
    :base_url => 'https://e-payment.postfinance.ch/ncol/test/orderstandard.asp'
    #:base_url => 'https://e-payment.postfinance.ch/ncol/test/orderdirect.asp',
    #:locale => 'de_DE',
    #:currency => 'CHF',
    #:local_port => 80,
    #:local_protocol => 'https',
    #:local_route => '/postfinance_payments'
  }
  
  # mandatory keys for +options+ are
  #  +:login+
  #
  # mandatory keys for +options+ if you want to do transactions
  #
  # +:sha1outsig+ is what is used to sign requests that come from postfinance
  # +:sha1insig+ is what is used to sign request that go to postfinance
  #
  # optional keys for +options+ are
  #  +:base_url+ default is ''
  #  +:language+ default is 'de_DE'
  #  +:currency+ default is 'CHF'
  #  +:local_host+ default is ''
  #  +:local_port+ default is 80
  #  +:local_protocol+ default is 'https'
  #  +:locale_route+ default is '/postfinance_payments'
  #
  def initialize(options={})
    options.symbolize_keys!
    #check_keys options, :login
    self.config = DEFAULT_OPTIONS.merge(options)
  end

  # returns a string containing a url for a GET
  #
  # hands options over to params_for_post
  def url_for_get(options={})
    options.symbolize_keys!
    options = params_for_post(options)
    parameters = []
    options.each { |p| parameters << p * '=' }
    [config[:base_url], parameters * '&'] * '?'
  end

  # generates a signature for the given parameters
  def signature(params, passwd=:sha1insig)
    passwd = config[passwd] if passwd.is_a?(Symbol)
    Params.new(params).to_digest(passwd).upcase
  end

  def debug(params, passwd=:sha1insig)
    passwd = config[passwd] if passwd.is_a?(Symbol)
    params = Hash[params] if params.is_a?(Array)
    Params.new(params).debug(passwd)
  end

  # returns a hash with merge_hash merged into default options 
  def default_options(merge_hash={})
    defaults = config.dup
    defaults[:PSPID] = defaults.delete(:login)
    %w(sha1insig sha1outsig base_url).each { |s| defaults.delete(s.to_sym) }
    defaults.merge(merge_hash)
  end

  # returns a hash containing the params for a POST
  #
  # mandatory keys for +options+ are
  #  +:orderID+
  #  +:amount+
  #
  # optional keys for +options+ are
  #  +:PSPID+
  #  +:currency+
  #  +:language+
  #  +:accepturl+
  #
  def params_for_post(options={})
    options.symbolize_keys!
    #check_keys options, :orderID, :amount
    opts = default_options(options)
    opts[:SHASign] = signature(opts)
    opts
  end

  # returns a string containing html markup
  # 
  # hands options over to params_for_post
  #
  #  +:submit_value+ is the caption of the submit button
  def form_for_post(options={})
    options.symbolize_keys!
    submit_value = options.delete(:submit_value) || 'Checkout with Post Finance'
    options = params_for_post(options)
    (["<form action=\"#{config[:base_url]}\" method=\"post\">"] + 
     options.map { |n, v| hidden_field(n, v) } +
     ["<input type=\"submit\" value=\"#{submit_value}\" />", '</form>']) * "\n"
  end

  # verifies a signature
  def signature_valid?(params, sha1out=nil)
    ps = params.dup
    ps.symbolize_keys!
    sha1out = ps.delete(:SHASIGN) if sha1out.nil?
    sha1out == signature(ps, :sha1outsig)
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

