# coding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'rdf/ll1/scanner'

describe RDF::LL1::Scanner do
  describe ".new" do
    it "initializes with an #read" do
      thing = File.open(__FILE__)
      thing.should_receive(:gets).at_least(1).times.and_return("line1\n")
      thing.should_receive(:eof?).at_least(1).times.and_return(false)
      scanner = RDF::LL1::Scanner.open(thing)
      scanner.rest.should == "line1\n"
      scanner.scan(/.*/).should == "line1"
      scanner.scan(/\s*/m).should == "\n"
      scanner.eos?.should be_false
    end

    it "initializes with a StringIO" do
      scanner = RDF::LL1::Scanner.open(StringIO.new("line1\nline2\n"))
      scanner.rest.should == "line1\n"
      scanner.eos?.should be_false
    end

    it "initializes with a filename" do
      File.should_receive(:open).with("foo").and_return(StringIO.new("foo"))
      scanner = RDF::LL1::Scanner.open("foo")
    end
  end
  
  describe "#eos?" do
    it "returns true if at both eos and eof" do
      scanner = RDF::LL1::Scanner.open(StringIO.new(""))
      scanner.eos?.should be_true
    end
  end
  
  describe "#rest" do
    it "returns remaining scanner contents if not at eos" do
      scanner = RDF::LL1::Scanner.open(StringIO.new("foo\n"))
      scanner.rest.should == "foo\n"
    end
    
    it "returns next line from file if at eos" do
      scanner = RDF::LL1::Scanner.open(StringIO.new("\nfoo\n"))
      scanner.rest.should == "\n"
      scanner.scan(/\s*/m)
      scanner.rest.should == "foo\n"
    end
    
    it "returns \"\" if at eos and eof" do
      scanner = RDF::LL1::Scanner.open(StringIO.new(""))
      scanner.rest.should == ""
    end
  end
  
  describe "#scan" do
    context "simple terminals" do
      it "returns a word" do
        scanner = RDF::LL1::Scanner.open(StringIO.new("foo bar"))
        scanner.scan(/\w+/).should == "foo"
      end
      
      it "returns a STRING_LITERAL1" do
        scanner = RDF::LL1::Scanner.open(StringIO.new("'string' foo"))
        scanner.scan(/'((?:[^\x27\x5C\x0A\x0D])*)'/).should == "'string'"
      end
      
      it "returns a STRING_LITERAL_LONG1" do
        scanner = RDF::LL1::Scanner.open(StringIO.new("'''\nstring\nstring''' foo"), :ml_start => /'''|"""/)
        scanner.scan(/'''((?:(?:'|'')?(?:[^'\\])+)*)'''/m).should == "'''\nstring\nstring'''"
      end
    end
  end
end