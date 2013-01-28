# encoding:utf-8
require 'spec_helper'

describe WadokuSearchAPI do

  def app
    @app ||= WadokuSearchAPI
  end

  def last_json
    Yajl::Parser.parse(last_response.body)
  end

  describe JsonEntry do
    it 'should have a picture property iff one is present in the entry' do
      hash = JsonEntry.new(Entry.get(617)).to_hash
      hash[:picture].should_not be_nil
      hash = JsonEntry.new(Entry.get(1871)).to_hash
      hash[:picture].should be_nil
    end
  end

  describe "API v1" do

    describe "searches" do
      it 'should give a total amount of results' do
        get '/api/v1/search?query=japan'
        last_json["total"].should be 77
      end

      it 'should not contain errored entries' do
        get '/api/v1/search?query=japan'
        last_json["entries"].each {|entry| entry["error"].should be_nil}
      end
    end

    describe "entries" do
      it 'should return a representation of an entry when given a valid wadoku id' do
        get '/api/v1/entry/0946913'
        last_json["writing"].should eq "アナクロニズム"
      end

      it 'should return an error for an invalid wadoku id' do
        get '/api/v1/entry/invalid'
        last_json["error"].should_not be_nil
      end
    end
  end

end
