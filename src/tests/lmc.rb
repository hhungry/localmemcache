$DIR=File.dirname(__FILE__)
['.', '..', '../ruby-binding/'].each {|p| $:.unshift File.join($DIR, p) }

require 'bacon'
require 'localmemcache'

Bacon.summary_on_exit

LocalMemCache.drop :namespace => "test", :force => true
$lm = LocalMemCache.new :namespace=>"test", :size_mb => 20

LocalMemCache.drop :namespace => "test-small", :force => true
$lms = LocalMemCache.new :namespace=>"test-small", :size_mb => 0.20;

describe 'LocalMemCache' do

  it 'should allow to set and query keys' do
    $lm.get("non-existant").should.be.nil
    $lm.set("foo", "1")
    $lm.get("foo").should.equal "1"
  end

  it 'should support the [] and []= operators' do
    $lm["boo"] = "2"
    $lm["boo"].should.equal "2"
  end

  it 'should allow deletion of keys' do
    $lm["deleteme"] = "blah"
    $lm["deleteme"].should.not.be.nil
    $lm.delete("deleteme")
    $lm["deleteme"].should.be.nil
    $lm.delete("non-existant")
  end

  it 'should return a list of keys' do
    $lm.keys().size.should.equal 2
  end

  it 'should support each_pair' do 
    $lm.each_pair {|k, v| }
  end

  it 'should support \0 in values and keys' do
    $lm["null"] = "foo\0goo"
    $lm["null"].should.equal "foo\0goo"
  end

  it 'should support random_pair' do
    $lm.random_pair.size.should.equal 2
    ll = LocalMemCache.new :namespace => :empty
    ll.random_pair.should.be.nil
  end

  it 'should throw an exception when accessing a closed pool' do
    $lm.close
    should.raise(LocalMemCache::MemoryPoolClosed) { $lm.keys }
  end

  it 'should throw exception if pool is full' do
    $lms["one"] = "a";
    should.raise(LocalMemCache::MemoryPoolFull) { $lms["two"] = "b" * 8000000; }
  end


  it 'should support clearing of hashes' do
    ($lms.keys.size > 0).should.be.true
    $lms.clear
    $lms.keys.size.should.equal 0
  end

  it 'should support checking of namespaces' do 
    LocalMemCache.check :namespace => "test"
  end


  it 'should support dropping of namespaces' do
    LocalMemCache.drop :namespace => "test"
  end

  it 'should support filename parameters' do
    LocalMemCache.drop :filename => ".tmp.a.lmc", :force => true
    lm = LocalMemCache.new :filename => ".tmp.a.lmc", :size_mb => 0.20
    lm[:boo] = 1
    lm.keys.size.should.equal 1
    File.exists?(".tmp.a.lmc").should.be.true
    LocalMemCache.check :filename => ".tmp.a.lmc"
    LocalMemCache.drop :filename => ".tmp.a.lmc"
  end


end

LocalMemCache.drop :namespace => "test-shared-hash", :force => true
$lmsh = LocalMemCache::SharedHash.new :namespace=>"test-shared-hash", 
    :size_mb => 20

p $lmsh

describe 'LocalMemCache::SharedHash' do
  it 'should allow to set and query for ruby objects' do
    $lmsh["non-existant"].should.be.nil
    $lmsh["array"] = [:foo, :boo]
    $lmsh["array"].should.be.kind_of? Array
  end
end

