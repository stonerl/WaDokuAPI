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
      hash = JsonEntry.new(Entry.get(616)).to_hash
      hash[:picture].should_not be_nil
      hash = JsonEntry.new(Entry.get(1870)).to_hash
      hash[:picture].should be_nil
    end

    it 'should have an audio property iff one is present in the entry' do
      hash = JsonEntry.new(Entry.get(4)).to_hash
      hash[:audio].should_not be_nil
      hash = JsonEntry.new(Entry.get(3)).to_hash
      hash[:audio].should be_nil
    end

    it 'should contain a field with subentries' do
      hash = JsonEntry.new(Entry.get(5372)).to_hash
      hash[:sub_entries].should_not be_empty

      hash = JsonEntry.new(Entry.get(1)).to_hash
      hash[:sub_entries].should be_empty
    end

    it 'should group subentries' do
      hash = JsonEntry.new(Entry.get(5372)).to_hash
      hash[:sub_entries].size.should be 3
    end
  end

  describe "API v1" do

    describe "direct Picky" do
      it 'should answer direct picky queries' do
        get "/api/v1/picky?query=japan"
        last_json["total"].should_not be_nil
      end

    end
    describe "searches" do
      it 'should give a total amount of results' do
        get '/api/v1/search?query=japan'
        last_json["total"].should be 77
      end

      it 'should not contain errored entries' do
        get '/api/v1/search?query=japan'
        last_json["entries"].each {|entry| entry["error"].should be_nil}
      end

      it 'should return different definition fields depending on the format' do
        # HTML is the default
        get '/api/v1/search?query=japan'
        last_json["entries"].first["definition"].should include('span class=')

        get '/api/v1/search?query=japan&format=plain'
        last_json["entries"].first["definition"].should_not include('span class=')

        get '/api/v1/search?query=japan&format=html'
        last_json["entries"].first["definition"].should include('span class=')
      end

      it 'should wrap the entries with a callback when given the parameter' do
        get '/api/v1/search?query=japan&callback=rspec'
        last_response.body.to_s.should start_with('rspec(')
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

      it 'should return different definition fields depending on the format' do
        # HTML is the default
        get '/api/v1/entry/6843503'
        last_json["definition"].should include('span class=')

        get '/api/v1/entry/6843503?format=plain'
        last_json["definition"].should_not include('span class=')

        get '/api/v1/entry/6843503?format=html'
        last_json["definition"].should include('span class=')
      end

      it 'should wrap the entries with a callback when given the parameter' do
        get '/api/v1/entry/6843503?callback=rspec'
        last_response.body.to_s.should start_with('rspec(')
      end
    end
  end

end
