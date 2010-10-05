require 'helper'

class TestRpostf < Test::Unit::TestCase

  context 'generate signatures' do
    setup do
      @rpostf = Rpostf.new(:sha1insig => 'Mysecretsig1875!?')
      @params = %w(amount 1500 currency EUR Operation RES orderID 1234 PSPID MyPSPID)
      @sha1 = 'EB52902BCC4B50DC1250E5A7C1068ECF97751256'
    end

    should "for in" do
      sig = @rpostf.signature(@params, :sha1insig)
      assert_equal @sha1, sig
    end

    should "for in by default" do
      sig = @rpostf.signature(@params)
      assert_equal @sha1, sig
    end

    should "for out" do
      @rpostf = Rpostf.new(:sha1outsig => 'Mysecretsig1875!?')
      sig = @rpostf.signature(@params, :sha1outsig)
      assert_equal @sha1, sig
    end

    should "with given passwd" do
      sig = Rpostf.new.signature(@params, "Mysecretsig1875!?")
      assert_equal @sha1, sig
    end
  end

  context 'rpostf' do
    setup do
      @rpostf = Rpostf.new(:login => 'MyPSPID',
                           :sha1insig => 'Mysecretsig1875!?',
                           :sha1outsig => 'SomeOtherPass',
                           :currency => 'EUR')
      @sha1out = 'EB52902BCC4B50DC1250E5A7C1068ECF97751256'
    end

    should "generate params_for_post" do
      params = @rpostf.params_for_post(:orderID => '1234',
                                       :amount => 1500,
                                       :Operation => 'RES')
      assert_equal '1234', params[:orderID]
      assert_equal 'MyPSPID', params[:PSPID]
      assert_equal @digest, params[:SHASIGN]
    end

    should "generate url_for_get" do
      url = @rpostf.url_for_get(:orderID => 1234,
                                :amount => 1500,
                                :Operation => 'RES')
      assert url.include?('orderID=1234')
      assert url.include?('PSPID=MyPSPID')
      assert url.include?("SHASign=#{@sha1out}")
    end

    should "generate form_for_post" do
      form = @rpostf.form_for_post(:orderID => 1234,
                                   :amount => 1500,
                                   :Operation => 'RES')
      assert form.include?('input type="hidden" name="orderID" value="1234"')
      assert form.include?('input type="hidden" name="PSPID" value="MyPSPID"')
      assert form.include?('input type="hidden" name="SHASign" value="' + @sha1out + '"')
    end
  end

  context 'validating signatures' do
    setup do
      @rpostf = Rpostf.new(:sha1outsig => 'Mysecretsig1875!?')
    end

    should "check if signature_valid?" do
      params = %w(amount 1500 currency EUR Operation RES orderID 1234 PSPID MyPSPID)
      params << 'SHASIGN'
      params << 'EB52902BCC4B50DC1250E5A7C1068ECF97751256'
      assert @rpostf.signature_valid?(Hash[params.chunk])
    end
  end

end
