require 'helper'

class TestRpostfParams < Test::Unit::TestCase

  context 'initialize' do
    setup do
      @data = [[:a, 1], [:b, 2]]
    end

    should 'with array' do
      assert_same_elements @data, Rpostf::Params.new([[:a, 1], [:b, 2]]).data
    end

    should 'with flat array' do
      assert_same_elements @data, Rpostf::Params.new([:a, 1, :b, 2]).data
    end

    should 'with hash' do
      assert_same_elements @data, Rpostf::Params.new({ :a => 1, :b => 2 }).data
    end
  end

  context 'according to PostFinance_e-Com-ADV_DE.pdf (v4.4)' do
    setup do
      @params = %w(amount 1500 currency EUR Operation RES orderID 1234 PSPID MyPSPID)
      @sha1outsig = 'Mysecretsig1875!?'
    end

    should "generate valid signature (P. 41)" do
      hash = 'AMOUNT=1500Mysecretsig1875!?CURRENCY=EURMysecretsig1875!?OPERATION=RES' +
        'Mysecretsig1875!?ORDERID=1234Mysecretsig1875!?PSPID=MyPSPIDMysecretsig1875!?'
      digest = 'EB52902BCC4B50DC1250E5A7C1068ECF97751256'
      rpostf_params = Rpostf::Params.new(@params)
      assert_equal = hash, rpostf_params.to_hash(@sha1outsig)
      assert_equal = digest, rpostf_params.to_digest(@sha1outsig)
    end
  end

  context 'basic functions' do
    setup do
      @params = Rpostf::Params.new(:a => 1, :c => nil, :b => '')
      @passwd = 'abcdef'
    end

    should "calculate digest" do
      assert_equal Digest::SHA1.hexdigest('A=1abcdef'), @params.to_digest(@passwd)
    end

    should "calculate hash" do
      assert_equal 'A=1abcdef', @params.to_hash(@passwd)
    end

    should "upcase keys" do
      assert_same_elements  [['A', 1], ['C', nil], ['B', '']], @params.upcased.data
    end

    should "filter blanks" do
      assert_equal  [[:a, 1]], @params.non_blank.data
    end

    should "sort by keys" do
      assert_equal  [[:a, 1], [:b, ''], [:c, nil]], @params.sorted.data
    end

    should "concatinate" do
      assert_equal 'a=1abcdefb=abcdefc=abcdef', @params.sorted.concatinated(@passwd)
    end
  end

end
